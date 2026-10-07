#!/usr/bin/env python3
"""Read-only introspection for opencode sessions: cost, tokens, wall-clock vs
engaged time, and permission/clarification interruption counts.

Data sources (both read-only, never mutated):
  - SQLite DB   ~/.local/share/opencode/opencode.db   (session/message/part)
  - Rolling log ~/.local/share/opencode/log/opencode.log (permission/question asks)

See SKILL.md in this directory for the full methodology and gotchas.

Usage:
  introspect.py --session ses_abc123
  introspect.py --session ses_abc123 ses_def456 --combine
  introspect.py --dir FEL-395 --combine --markdown
"""
import argparse
import bisect
import json
import re
import sqlite3
from datetime import datetime, timezone

DEFAULT_DB = "~/.local/share/opencode/opencode.db"
DEFAULT_LOG = "~/.local/share/opencode/log/opencode.log"
TS_RE = re.compile(r"timestamp=([0-9T:.-]+)Z")
SESSION_RE = re.compile(r"session\.id=(ses_[A-Za-z0-9]+)")
RUN_RE = re.compile(r"\brun=([0-9a-f]+)\b")


def hm(seconds):
    seconds = int(seconds)
    sign = "-" if seconds < 0 else ""
    seconds = abs(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h:
        return f"{sign}{h}h{m:02d}m"
    if m:
        return f"{sign}{m}m{s:02d}s"
    return f"{sign}{s}s"


def clock(ts):
    return datetime.fromtimestamp(ts).strftime("%m-%d %H:%M")


def descendants(db, root):
    """BFS over parent_id to collect a session and all its subagent sessions."""
    out = [root]
    frontier = [root]
    while frontier:
        qs = ",".join("?" * len(frontier))
        kids = [
            r["id"]
            for r in db.execute(
                f"SELECT id FROM session WHERE parent_id IN ({qs})", frontier
            )
        ]
        out += kids
        frontier = kids
    return out


def resolve_roots(db, session_ids=None, directory_substr=None):
    """Return [(title, root_id), ...] for the requested scope."""
    if session_ids:
        roots = []
        for sid in session_ids:
            row = db.execute(
                "SELECT id, title FROM session WHERE id=?", (sid,)
            ).fetchone()
            if not row:
                raise SystemExit(f"session not found: {sid}")
            roots.append((row["title"], row["id"]))
        return roots
    if directory_substr:
        rows = db.execute(
            "SELECT id, title FROM session WHERE directory LIKE ? "
            "AND (parent_id IS NULL OR parent_id='') ORDER BY time_created",
            (f"%{directory_substr}%",),
        ).fetchall()
        if not rows:
            raise SystemExit(f"no root sessions matched directory: {directory_substr}")
        return [(r["title"], r["id"]) for r in rows]
    raise SystemExit("must pass --session or --dir")


def tree_metrics(db, tree_ids):
    qs = ",".join("?" * len(tree_ids))
    row = db.execute(
        f"""SELECT sum(cost) cost, sum(tokens_input) tin, sum(tokens_output) tout,
                   sum(tokens_reasoning) treason, sum(tokens_cache_read) cread,
                   sum(tokens_cache_write) cwrite
            FROM session WHERE id IN ({qs})""",
        tree_ids,
    ).fetchone()
    return dict(row)


def merged_timeline(db, tree_ids):
    """All message + part timestamps across the tree, seconds, sorted."""
    qs = ",".join("?" * len(tree_ids))
    ts = set()
    for r in db.execute(
        f"SELECT data FROM message WHERE session_id IN ({qs})", tree_ids
    ):
        d = json.loads(r["data"])
        ts.add(d["time"]["created"])
        if d["time"].get("completed"):
            ts.add(d["time"]["completed"])
    for r in db.execute(
        f"SELECT time_created FROM part WHERE session_id IN ({qs})", tree_ids
    ):
        ts.add(r["time_created"])
    return sorted(t / 1000 for t in ts)


def tool_spans(db, tree_ids):
    """[(start_sec, end_sec, tool_name), ...] for tool parts with a real span."""
    qs = ",".join("?" * len(tree_ids))
    spans = []
    for r in db.execute(
        f"SELECT data FROM part WHERE session_id IN ({qs}) "
        f"AND json_extract(data,'$.type')='tool'",
        tree_ids,
    ):
        d = json.loads(r["data"])
        t = (d.get("state") or {}).get("time") or {}
        if t.get("start") and t.get("end"):
            spans.append((t["start"] / 1000, t["end"] / 1000, d.get("tool")))
    return spans


def rejection_count(db, tree_ids):
    qs = ",".join("?" * len(tree_ids))
    return db.execute(
        f"SELECT count(*) n FROM part WHERE session_id IN ({qs}) "
        f"AND data LIKE '%rejected permission%'",
        tree_ids,
    ).fetchone()["n"]


def scan_log(log_path, tree_id_sets):
    """Single pass over the log. Returns per-tree-name dict of:
    perm_asks, clar_asks, clar_replied, clar_dismissed (lists of ts),
    plus the earliest timestamp seen (for coverage warnings).
    tree_id_sets: {tree_name: set(session_ids)}
    """
    id_to_tree = {}
    for name, ids in tree_id_sets.items():
        for i in ids:
            id_to_tree[i] = name

    result = {
        name: {"perm": [], "clar_asked": [], "clar_replied": [], "clar_dismissed": []}
        for name in tree_id_sets
    }
    current_session_by_run = {}
    earliest = None

    try:
        f = open(log_path)
    except FileNotFoundError:
        return result, None

    with f:
        for line in f:
            m = TS_RE.match(line)
            if not m:
                continue
            # log timestamps are UTC ("Z" suffix); .timestamp() on a naive
            # datetime assumes LOCAL time, so this must be tagged tzinfo=utc
            # or every log ts silently shifts by the local UTC offset.
            ts = (
                datetime.strptime(m.group(1), "%Y-%m-%dT%H:%M:%S.%f")
                .replace(tzinfo=timezone.utc)
                .timestamp()
            )
            if earliest is None:
                earliest = ts
            run_m = RUN_RE.search(line)
            run = run_m.group(1) if run_m else None

            sess_m = SESSION_RE.search(line)
            if sess_m and run:
                current_session_by_run[run] = sess_m.group(1)

            if "message=asking id=per_" not in line and \
               "message=asking id=que_" not in line and \
               "message=replied requestID=que_" not in line and \
               "message=rejected requestID=que_" not in line:
                continue

            cur = current_session_by_run.get(run)
            tree = id_to_tree.get(cur)
            if not tree:
                continue
            if "message=asking id=per_" in line:
                result[tree]["perm"].append(ts)
            elif "message=asking id=que_" in line:
                result[tree]["clar_asked"].append(ts)
            elif "message=replied requestID=que_" in line:
                result[tree]["clar_replied"].append(ts)
            elif "message=rejected requestID=que_" in line:
                result[tree]["clar_dismissed"].append(ts)

    return result, earliest


def big_gaps(timeline, threshold):
    return [(a, b) for a, b in zip(timeline, timeline[1:]) if b - a > threshold]


def implicit_wait_events(db, root_id):
    """Root-session-ONLY (never subagents -- a subagent's own 'stop' just
    means it finished and is handing its result back to the calling agent,
    not to the human). An assistant message that ends its turn with no
    pending tool call (finish != 'tool-calls'), immediately followed by a
    user message, is the agent stopping and waiting for direction -- this
    catches plain-text clarification/handoffs ("push now, or hold off?")
    that never went through the `question` tool and so are invisible to the
    log-based signal. Excludes the session's last message (that's just EOF,
    not an observed wait) and any message missing a completion time
    (in-flight/aborted, no real end point to measure)."""
    msgs = [
        json.loads(r["data"])
        for r in db.execute(
            "SELECT data FROM message WHERE session_id=? ORDER BY time_created",
            (root_id,),
        )
    ]
    events = []
    for i, m in enumerate(msgs):
        if m["role"] != "assistant" or m.get("finish") == "tool-calls":
            continue
        if not m["time"].get("completed"):
            continue
        if i + 1 >= len(msgs) or msgs[i + 1]["role"] != "user":
            continue
        events.append((m["time"]["completed"] / 1000, msgs[i + 1]["time"]["created"] / 1000))
    return events


def annotate_gap(a, b, asks, tools, stops):
    """Find an ask/implicit-stop near the gap's start, and the longest tool
    span overlapping it. Priority PERM/QUES (log-verified) over STOP
    (DB-inferred) in the unlikely case both land in the same gap."""
    ask_hit = ""
    for ts, kind in asks:
        if a - 5 <= ts <= a + 120:
            ask_hit = kind
            break
    if not ask_hit:
        for stop_start, _stop_end in stops:
            if abs(stop_start - a) <= 5:
                ask_hit = "STOP"
                break
    best = (0, "")
    for tstart, tend, name in tools:
        overlap = min(b, tend) - max(a, tstart)
        if overlap > best[0]:
            best = (overlap, name)
    return ask_hit, best


def analyze_tree(db, title, root_id, log_asks_by_tree, tree_name, gap_threshold):
    tree_ids = descendants(db, root_id)
    metrics = tree_metrics(db, tree_ids)
    root_cost = db.execute(
        "SELECT cost c FROM session WHERE id=?", (root_id,)
    ).fetchone()["c"]
    timeline = merged_timeline(db, tree_ids)
    if not timeline:
        return None
    wall = timeline[-1] - timeline[0]
    gaps = big_gaps(timeline, gap_threshold)
    engaged = sum(b - a for a, b in zip(timeline, timeline[1:]) if b - a <= gap_threshold)
    waiting = wall - engaged
    tools = tool_spans(db, tree_ids)

    log_data = log_asks_by_tree.get(tree_name, {})
    perm_asks = sorted(log_data.get("perm", []))
    clar_asked = sorted(log_data.get("clar_asked", []))
    clar_replied = len(log_data.get("clar_replied", []))
    clar_dismissed = len(log_data.get("clar_dismissed", []))
    all_asks = [(t, "PERM") for t in perm_asks] + [(t, "QUES") for t in clar_asked]
    rejections = rejection_count(db, tree_ids)
    stops = implicit_wait_events(db, root_id)
    stop_time = sum(e - s for s, e in stops)

    gap_rows = []
    for a, b in sorted(gaps, key=lambda g: -(g[1] - g[0])):
        ask_hit, (tool_dur, tool_name) = annotate_gap(a, b, all_asks, tools, stops)
        gap_rows.append((a, b - a, ask_hit, tool_dur, tool_name))

    return {
        "title": title,
        "root_id": root_id,
        "n_sessions": len(tree_ids),
        "span": (timeline[0], timeline[-1]),
        "wall": wall,
        "engaged": engaged,
        "waiting": waiting,
        "cost_total": metrics["cost"] or 0.0,
        "cost_root": root_cost or 0.0,
        "tokens": metrics,
        "perm_asks": len(perm_asks),
        "perm_rejections": rejections,
        "clar_asks": len(clar_asked),
        "clar_replied": clar_replied,
        "clar_dismissed": clar_dismissed,
        "stop_count": len(stops),
        "stop_time": stop_time,
        "gap_rows": gap_rows,
        "gap_threshold": gap_threshold,
        "activity_intervals": [(a, b) for a, b in zip(timeline, timeline[1:]) if b - a <= gap_threshold],
        "stop_intervals": stops,
        "permission_times": perm_asks,
        "question_times": clar_asked,
    }


def render_text(result, markdown=False):
    lines = []
    h = lambda s: lines.append(f"## {s}" if markdown else f"=== {s} ===")
    t0, t1 = result["span"]
    h(f"{result['title']} ({result['root_id']})")
    lines.append(
        f"- sessions in tree: {result['n_sessions']}"
        if markdown
        else f"  sessions in tree: {result['n_sessions']}"
    )
    span_line = f"span: {clock(t0)} -> {clock(t1)}   wall clock: {hm(result['wall'])}"
    lines.append(f"- {span_line}" if markdown else f"  {span_line}")
    cost_line = (
        f"cost: ${result['cost_total']:.2f} "
        f"(root ${result['cost_root']:.2f} + subagents ${result['cost_total']-result['cost_root']:.2f})"
    )
    lines.append(f"- {cost_line}" if markdown else f"  {cost_line}")
    tk = result["tokens"]
    tok_line = (
        f"tokens: in={tk['tin']:,} out={tk['tout']:,} "
        f"cache_read={tk['cread']:,} cache_write={tk['cwrite']:,}"
    )
    lines.append(f"- {tok_line}" if markdown else f"  {tok_line}")
    thr_m = result["gap_threshold"] // 60
    eng_pct = 100 * result["engaged"] / result["wall"] if result["wall"] else 0
    wait_pct = 100 - eng_pct
    time_line = (
        f"engaged (gaps<={thr_m}min): {hm(result['engaged'])} ({eng_pct:.0f}%)   "
        f"waiting/big-gaps: {hm(result['waiting'])} ({wait_pct:.0f}%)"
    )
    lines.append(f"- {time_line}" if markdown else f"  {time_line}")
    interrupt_line = (
        f"permission asks: {result['perm_asks']} (rejected: {result['perm_rejections']})   "
        f"clarification asks: {result['clar_asks']} "
        f"(answered: {result['clar_replied']}, dismissed: {result['clar_dismissed']})"
    )
    lines.append(f"- {interrupt_line}" if markdown else f"  {interrupt_line}")
    stop_line = (
        f"+ implicit stop-and-wait (no question tool, just ended the turn): "
        f"{result['stop_count']}, totaling {hm(result['stop_time'])}   "
        f"=> waiting-for-direction total: {result['clar_asks'] + result['stop_count']}"
    )
    lines.append(f"- {stop_line}" if markdown else f"  {stop_line}")

    if result["gap_rows"]:
        lines.append("")
        if markdown:
            lines.append("| gap start | dur | ask | longest overlapping tool |")
            lines.append("|---|---|---|---|")
            for a, dur, ask, tdur, tname in result["gap_rows"]:
                tool_str = f"{hm(tdur)} {tname}" if tdur else ""
                lines.append(f"| {clock(a)} | {hm(dur)} | {ask} | {tool_str} |")
        else:
            lines.append(f"  {'gap start':>11} {'dur':>7}  ask   longest-overlapping-tool")
            for a, dur, ask, tdur, tname in result["gap_rows"]:
                tool_str = f"{hm(tdur)} {tname}" if tdur else ""
                lines.append(f"  {clock(a):>11} {hm(dur):>7}  {ask:>4}  {tool_str}")
    lines.append("")
    return "\n".join(lines)


def render_combined(results, markdown=False):
    wall = sum(r["wall"] for r in results)
    engaged = sum(r["engaged"] for r in results)
    cost = sum(r["cost_total"] for r in results)
    perm = sum(r["perm_asks"] for r in results)
    perm_rej = sum(r["perm_rejections"] for r in results)
    clar = sum(r["clar_asks"] for r in results)
    stops = sum(r["stop_count"] for r in results)
    h = "## COMBINED" if markdown else "=== COMBINED ==="
    eng_pct = 100 * engaged / wall if wall else 0
    body = (
        f"wall clock: {hm(wall)}   engaged: {hm(engaged)} ({eng_pct:.0f}%)   "
        f"cost: ${cost:.2f}   permission asks: {perm} (rejected {perm_rej})   "
        f"waiting-for-direction: {clar + stops} (question tool: {clar}, implicit stop: {stops})"
    )
    return f"{h}\n{'- ' if markdown else '  '}{body}\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--session", nargs="+", help="explicit root session id(s)")
    ap.add_argument("--dir", help="directory substring; analyzes every matching root session")
    ap.add_argument("--gap-threshold", type=int, default=300, help="seconds; default 300 (5min)")
    ap.add_argument("--combine", action="store_true", help="also print a combined summary row")
    ap.add_argument("--markdown", action="store_true", help="emit markdown instead of plain text")
    ap.add_argument("--json", action="store_true", help="export timing, interruptions, gaps, and activity intervals as JSON; recorded costs are not prices")
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--log", default=DEFAULT_LOG)
    args = ap.parse_args()

    db_path = args.db.replace("~", __import__("os").path.expanduser("~"))
    log_path = args.log.replace("~", __import__("os").path.expanduser("~"))

    db = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    db.row_factory = sqlite3.Row

    roots = resolve_roots(db, args.session, args.dir)
    tree_id_sets = {rid: set(descendants(db, rid)) for title, rid in roots}

    log_asks_by_tree, earliest_log = scan_log(log_path, tree_id_sets)

    results = []
    for title, root_id in roots:
        res = analyze_tree(db, title, root_id, log_asks_by_tree, root_id, args.gap_threshold)
        if res:
            if earliest_log and res["span"][0] < earliest_log:
                res["log_coverage_warning"] = (
                    f"session started {clock(res['span'][0])}, before earliest log "
                    f"entry {clock(earliest_log)} -- permission/clarification counts "
                    f"for this tree are UNDERCOUNTED"
                )
            results.append(res)

    db.close()
    if args.json:
        print(json.dumps({"earliest_log": earliest_log, "results": results}, ensure_ascii=False, indent=2))
        return

    for res in results:
        print(render_text(res, args.markdown))
        if res.get("log_coverage_warning"):
            print(f"WARNING: {res['log_coverage_warning']}\n")

    if args.combine and len(results) > 1:
        print(render_combined(results, args.markdown))


if __name__ == "__main__":
    main()
