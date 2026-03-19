#!/usr/bin/env python3
"""
Rolling-window engineering metrics for a git repo. Weekly data points, 12-week rolling average.

Plots:
  - *Commits/contributor* — git commits per unique author, split code-only / doc-only / total
  - *Team size* — unique authors per week (all commits vs code-only)
  - *Lines added/deleted per contributor* — total lines changed ÷ unique authors
  - *Review time & PR lifetime (days)* — time from ready-for-review to merge; first commit to merge
  - *Avg reviewers & commenters per PR* — unique non-author participants per merged PR

Usage: python repo_stats.py <repo_path> <start_date> [--avg-weeks N]
"""

import argparse
import json
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from statistics import mean
from typing import Optional

import matplotlib
import pandas as pd
from tqdm import tqdm

matplotlib.use("Agg")
import matplotlib.dates
import matplotlib.pyplot as plt

# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

_PR_NUMBER_RE = re.compile(r"\(#(\d+)\)$")
_BATCH_SIZE = 10


@dataclass
class FileChange:
    path: str
    added: int
    deleted: int


@dataclass
class CommitRecord:
    sha: str
    author_email: str
    author_name: str
    date: datetime
    files: list[FileChange] = field(default_factory=list)

    # derived
    category: str = ""
    doc_added: int = 0
    doc_deleted: int = 0
    non_doc_added: int = 0
    non_doc_deleted: int = 0


@dataclass
class PRRecord:
    number: int
    author_login: str
    created_at: Optional[datetime]
    merged_at: Optional[datetime]
    ready_for_review_at: Optional[datetime]
    first_commit_date: Optional[datetime]
    # Each entry is (login, author_type) where author_type is "Bot", "User", etc.
    review_authors: list[tuple[str, Optional[str]]]
    comment_authors: list[tuple[str, Optional[str]]]


# ---------------------------------------------------------------------------
# Excludes
# ---------------------------------------------------------------------------


def _parse_jsonc(text: str) -> dict:
    """Strip // line comments and /* block comments */ then parse as JSON."""
    import re as _re

    text = _re.sub(r"/\*.*?\*/", "", text, flags=_re.DOTALL)
    text = _re.sub(r"//[^\n]*", "", text)
    return json.loads(text)


def load_excludes(repo_name: str) -> tuple[set[int], set[str], set[str]]:
    """Load optional exclude list from <repo_name>_exclude.jsonc in CWD.

    Returns (excluded_prs, excluded_commits, extra_bot_logins).
    """
    path = Path(f"{repo_name}_exclude.jsonc")
    if not path.exists():
        # fall back to .json for backwards compatibility
        path = Path(f"{repo_name}_exclude.json")
    if not path.exists():
        return set(), set(), set()
    data = _parse_jsonc(path.read_text())
    excluded_prs: set[int] = set(data.get("exclude_prs", []))
    excluded_commits: set[str] = set(data.get("exclude_commits", []))
    extra_bot_logins: set[str] = set(data.get("bot_logins", []))
    print(
        f"Excluding {len(excluded_prs)} PR(s) and {len(excluded_commits)} commit(s)"
        f" per {path.name}."
    )
    if extra_bot_logins:
        print(f"  Extra bot logins from config: {sorted(extra_bot_logins)}")
    return excluded_prs, excluded_commits, extra_bot_logins


def _is_bot_reviewer(
    login: str, author_type: Optional[str], extra_bot_logins: set[str]
) -> bool:
    """Return True if this reviewer login should be classified as a bot."""
    if author_type == "Bot":
        return True
    if login.endswith("[bot]"):
        return True
    return login in extra_bot_logins


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------

_DOC_EXTENSIONS = {".md", ".rst", ".txt"}


def _run(cmd: list[str], cwd: Optional[str] = None, check: bool = True) -> str:
    try:
        result = subprocess.run(
            cmd, capture_output=True, text=True, cwd=cwd, check=check
        )
    except subprocess.CalledProcessError as exc:
        stderr = exc.stderr.strip() if exc.stderr else "(no stderr)"
        print(
            f"Command {exc.cmd!r} failed (exit {exc.returncode}): {stderr}",
            file=sys.stderr,
        )
        raise
    return result.stdout


def get_remote_owner_repo(repo_path: str) -> str:
    """Derive 'owner/repo' from the origin remote URL."""
    url = _run(["git", "remote", "get-url", "origin"], cwd=repo_path).strip()
    m = re.match(r"git@[^:]+:(.+?)(?:\.git)?$", url)
    if m:
        return m.group(1)
    m = re.match(r"https?://[^/]+/(.+?)(?:\.git)?$", url)
    if m:
        return m.group(1)
    sys.exit(f"Cannot parse remote URL: {url}")


def _is_doc_file(path: str) -> bool:
    return any(path.endswith(ext) for ext in _DOC_EXTENSIONS)


def classify_commit(
    files: list[FileChange],
) -> tuple[str, int, int, int, int]:
    """Return (category, doc_added, doc_deleted, non_doc_added, non_doc_deleted)."""
    doc_added = sum(f.added for f in files if _is_doc_file(f.path))
    doc_deleted = sum(f.deleted for f in files if _is_doc_file(f.path))
    non_doc_added = sum(f.added for f in files if not _is_doc_file(f.path))
    non_doc_deleted = sum(f.deleted for f in files if not _is_doc_file(f.path))

    has_doc = doc_added + doc_deleted > 0
    has_code = non_doc_added + non_doc_deleted > 0

    if has_doc and has_code:
        category = "mixed"
    elif has_doc:
        category = "doc_only"
    else:
        category = "code_only"

    return category, doc_added, doc_deleted, non_doc_added, non_doc_deleted


def parse_git_log(
    repo_path: str, since_date: str, exclude_commits: set[str] | None = None
) -> list[CommitRecord]:
    """Parse git log into CommitRecord list."""
    raw = _run(
        [
            "git",
            "log",
            "--no-merges",
            f"--since={since_date}",
            "--format=COMMIT:%H\t%ae\t%an\t%aI",
            "--numstat",
            "origin/HEAD",
        ],
        cwd=repo_path,
    )

    exclude_commits = exclude_commits or set()
    commits: list[CommitRecord] = []
    current: Optional[CommitRecord] = None

    for line in raw.splitlines():
        if line.startswith("COMMIT:"):
            if current is not None:
                cat, da, dd, nda, ndd = classify_commit(current.files)
                current.category = cat
                current.doc_added = da
                current.doc_deleted = dd
                current.non_doc_added = nda
                current.non_doc_deleted = ndd
                commits.append(current)
            parts = line[7:].split("\t")
            sha, email, name, date_str = parts[0], parts[1], parts[2], parts[3]
            if sha in exclude_commits:
                current = None  # skip this commit and its numstat lines
                continue
            dt = datetime.fromisoformat(date_str)
            if dt.tzinfo is None:
                dt = dt.replace(tzinfo=timezone.utc)
            current = CommitRecord(
                sha=sha, author_email=email, author_name=name, date=dt
            )
        elif current is not None and line.strip():
            parts = line.split("\t")
            if len(parts) == 3:
                added_str, deleted_str, path = parts
                if added_str == "-" or deleted_str == "-":
                    continue  # binary file
                try:
                    current.files.append(
                        FileChange(
                            path=path,
                            added=int(added_str),
                            deleted=int(deleted_str),
                        )
                    )
                except ValueError:
                    pass

    if current is not None:
        cat, da, dd, nda, ndd = classify_commit(current.files)
        current.category = cat
        current.doc_added = da
        current.doc_deleted = dd
        current.non_doc_added = nda
        current.non_doc_deleted = ndd
        commits.append(current)

    return commits


def parse_pr_numbers_from_git_log(repo_path: str, since_date: str) -> list[int]:
    """Extract PR numbers from commit subjects using the '(#NNN)' convention."""
    raw = _run(
        ["git", "log", f"--since={since_date}", "--format=%s", "origin/HEAD"],
        cwd=repo_path,
    )
    numbers: list[int] = []
    seen: set[int] = set()
    for line in raw.splitlines():
        m = _PR_NUMBER_RE.search(line.strip())
        if m:
            n = int(m.group(1))
            if n not in seen:
                seen.add(n)
                numbers.append(n)
    return numbers


# ---------------------------------------------------------------------------
# GitHub helpers
# ---------------------------------------------------------------------------


def _parse_gh_datetime(s: Optional[str]) -> Optional[datetime]:
    if not s:
        return None
    dt = datetime.fromisoformat(s.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt


def load_cache(path: Path) -> dict[int, dict]:
    """Load JSONL cache; returns dict keyed by PR number."""
    cache: dict[int, dict] = {}
    if not path.exists():
        return cache
    with path.open() as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            cache[obj["number"]] = obj
    return cache


def save_cache(path: Path, cache: dict[int, dict]) -> None:
    """Write entire cache to JSONL (overwrite)."""
    with path.open("w") as f:
        for obj in cache.values():
            f.write(json.dumps(obj) + "\n")


def fetch_pr_details_batch(owner_repo: str, pr_numbers: list[int]) -> dict[int, dict]:
    """
    Fetch full details for up to _BATCH_SIZE PRs in a single GraphQL call.

    Uses field aliases (pr_NNN) to batch multiple pullRequest lookups.
    Returns a dict keyed by PR number; omits PRs that returned null (deleted).
    """
    owner, repo = owner_repo.split("/", 1)

    def _pr_fragment(n: int) -> str:
        return f"""
        pr_{n}: pullRequest(number: {n}) {{
          number
          author {{ __typename login }}
          createdAt
          mergedAt
          reviews(first: 100) {{ nodes {{ author {{ __typename login }} }} }}
          comments(first: 100) {{ nodes {{ author {{ __typename login }} }} }}
          commits(first: 250) {{ nodes {{ commit {{ committedDate }} }} }}
          timelineItems(first: 10, itemTypes: [READY_FOR_REVIEW_EVENT]) {{
            nodes {{ ... on ReadyForReviewEvent {{ createdAt }} }}
          }}
        }}"""

    fragments = "\n".join(_pr_fragment(n) for n in pr_numbers)
    query = f"""
    {{
      repository(owner: "{owner}", name: "{repo}") {{
        {fragments}
      }}
    }}
    """
    try:
        raw = _run(["gh", "api", "graphql", "-f", f"query={query}"])
    except subprocess.CalledProcessError:
        return {}

    data = json.loads(raw)
    repo_data = data.get("data", {}).get("repository", {}) or {}
    results: dict[int, dict] = {}

    for n in pr_numbers:
        pr = repo_data.get(f"pr_{n}")
        if not pr:
            continue

        # ready_for_review_at: first READY_FOR_REVIEW_EVENT, or None (never draft)
        rfr_nodes = (pr.get("timelineItems") or {}).get("nodes", [])
        ready_for_review_at: Optional[str] = None
        for node in rfr_nodes:
            if node and node.get("createdAt"):
                ready_for_review_at = node["createdAt"]
                break

        # first_commit_date: min committedDate across all commits
        commit_nodes = (pr.get("commits") or {}).get("nodes", [])
        commit_dates = [
            nd["commit"]["committedDate"]
            for nd in commit_nodes
            if nd.get("commit", {}).get("committedDate")
        ]
        first_commit_date: Optional[str] = min(commit_dates) if commit_dates else None

        reviews = [
            {
                "author": {
                    "login": nd["author"]["login"],
                    "author_type": nd["author"].get("__typename"),
                }
            }
            for nd in (pr.get("reviews") or {}).get("nodes", [])
            if nd.get("author")
        ]
        comments = [
            {
                "author": {
                    "login": nd["author"]["login"],
                    "author_type": nd["author"].get("__typename"),
                }
            }
            for nd in (pr.get("comments") or {}).get("nodes", [])
            if nd.get("author")
        ]

        results[n] = {
            "number": n,
            "author": pr.get("author"),
            "createdAt": pr.get("createdAt"),
            "mergedAt": pr.get("mergedAt"),
            "reviews": reviews,
            "comments": comments,
            "first_commit_date": first_commit_date,
            "ready_for_review_at": ready_for_review_at,
            "complete": True,
        }

    return results


def fetch_merged_prs(
    owner_repo: str,
    repo_path: str,
    since_date: str,
    cache_path: Path,
    exclude_prs: set[int] | None = None,
) -> list[PRRecord]:
    """Fetch all merged PRs (with caching) and return PRRecord list.

    PR numbers are driven from the local git log — no bulk GitHub list call needed.
    Only PRs not already in cache are fetched, in batches of _BATCH_SIZE.
    """
    cache = load_cache(cache_path)
    since_dt = datetime.fromisoformat(since_date).replace(tzinfo=timezone.utc)

    exclude_prs = exclude_prs or set()
    print(f"Extracting PR numbers from git log since {since_date}…")
    pr_numbers = [
        n
        for n in parse_pr_numbers_from_git_log(repo_path, since_date)
        if n not in exclude_prs
    ]
    print(f"  Found {len(pr_numbers)} PR numbers in git log.")

    def _needs_refetch(entry: dict) -> bool:
        if not entry.get("complete"):
            return True
        # Re-fetch if any review/comment author is missing author_type (old cache format)
        for r in entry.get("reviews", []):
            if r.get("author") and r["author"].get("author_type") is None:
                return True
        for c in entry.get("comments", []):
            if c.get("author") and c["author"].get("author_type") is None:
                return True
        return False

    missing = [n for n in pr_numbers if _needs_refetch(cache.get(n, {}))]
    if missing:
        batches = [
            missing[i : i + _BATCH_SIZE] for i in range(0, len(missing), _BATCH_SIZE)
        ]
        for batch in tqdm(batches, desc="Fetching PR details", unit="batch"):
            batch_results = fetch_pr_details_batch(owner_repo, batch)
            for number, entry in batch_results.items():
                cache[number] = entry
            failed = [n for n in batch if n not in batch_results]
            if failed:
                tqdm.write(
                    f"  Warning: failed to fetch PR(s) {failed}; will retry next run."
                )
            save_cache(cache_path, cache)
            time.sleep(0.3)
    else:
        print(f"All {len(pr_numbers)} PRs already cached — no API calls needed.")

    total_cached = sum(1 for n in pr_numbers if cache.get(n, {}).get("complete"))
    no_rfr = sum(
        1
        for n in pr_numbers
        if cache.get(n, {}).get("complete")
        and cache[n].get("ready_for_review_at") is None
    )
    if total_cached:
        print(
            f"  {total_cached} PRs cached; "
            f"{no_rfr} were never drafts (using createdAt as review-time baseline)."
        )

    records: list[PRRecord] = []
    for number in pr_numbers:
        entry = cache.get(number)
        if not entry:
            continue
        merged_at = _parse_gh_datetime(entry.get("mergedAt"))
        if merged_at is None or merged_at < since_dt:
            continue

        created_at = _parse_gh_datetime(entry.get("createdAt"))
        rfr_str = entry.get("ready_for_review_at")
        ready_for_review_at = _parse_gh_datetime(rfr_str) if rfr_str else created_at
        first_commit_date = _parse_gh_datetime(entry.get("first_commit_date"))

        review_authors = [
            (r["author"]["login"], r["author"].get("author_type"))
            for r in entry.get("reviews", [])
            if r.get("author") and r["author"].get("login")
        ]
        comment_authors = [
            (c["author"]["login"], c["author"].get("author_type"))
            for c in entry.get("comments", [])
            if c.get("author") and c["author"].get("login")
        ]
        author_login = (entry.get("author") or {}).get("login", "")

        records.append(
            PRRecord(
                number=number,
                author_login=author_login,
                created_at=created_at,
                merged_at=merged_at,
                ready_for_review_at=ready_for_review_at,
                first_commit_date=first_commit_date,
                review_authors=review_authors,
                comment_authors=comment_authors,
            )
        )

    return records


# ---------------------------------------------------------------------------
# Metric computation
# ---------------------------------------------------------------------------


def compute_window_metrics(
    commits: list[CommitRecord],
    prs: list[PRRecord],
    window_start: datetime,
    window_end: datetime,
    bot_logins: set[str] | None = None,
) -> dict:
    """Compute all metrics for a single window."""
    win_commits = [c for c in commits if window_start <= c.date < window_end]
    win_prs = [
        p
        for p in prs
        if p.merged_at is not None and window_start <= p.merged_at < window_end
    ]

    row: dict = {
        "window_start": window_start.date().isoformat(),
        "window_end": window_end.date().isoformat(),
    }

    all_authors = {c.author_email for c in win_commits}
    code_authors = {
        c.author_email for c in win_commits if c.category in ("code_only", "mixed")
    }
    num_contributors_all = len(all_authors)
    num_contributors_code = len(code_authors)
    row["num_contributors_all"] = num_contributors_all
    row["num_contributors_code"] = num_contributors_code

    if num_contributors_all == 0:
        for col in [
            "commits_total_per_contrib",
            "commits_code_only_per_contrib",
            "commits_mixed_per_contrib",
            "commits_doc_only_per_contrib",
            "lines_added_per_contrib",
            "lines_added_code_only_per_contrib",
            "lines_added_doc_only_per_contrib",
            "lines_deleted_per_contrib",
            "lines_deleted_code_only_per_contrib",
            "lines_deleted_doc_only_per_contrib",
        ]:
            row[col] = float("nan")
    else:
        n = num_contributors_all
        n_code_only = sum(1 for c in win_commits if c.category == "code_only")
        n_mixed = sum(1 for c in win_commits if c.category == "mixed")
        n_doc_only = sum(1 for c in win_commits if c.category == "doc_only")
        row["commits_total_per_contrib"] = (n_code_only + n_mixed + n_doc_only) / n
        row["commits_code_only_per_contrib"] = n_code_only / n
        row["commits_mixed_per_contrib"] = n_mixed / n
        row["commits_doc_only_per_contrib"] = n_doc_only / n
        row["lines_added_per_contrib"] = (
            sum(fc.added for c in win_commits for fc in c.files) / n
        )
        row["lines_added_code_only_per_contrib"] = (
            sum(c.non_doc_added for c in win_commits) / n
        )
        row["lines_added_doc_only_per_contrib"] = (
            sum(c.doc_added for c in win_commits) / n
        )
        row["lines_deleted_per_contrib"] = (
            sum(fc.deleted for c in win_commits for fc in c.files) / n
        )
        row["lines_deleted_code_only_per_contrib"] = (
            sum(c.non_doc_deleted for c in win_commits) / n
        )
        row["lines_deleted_doc_only_per_contrib"] = (
            sum(c.doc_deleted for c in win_commits) / n
        )

    _bot_logins: set[str] = bot_logins or set()

    if not win_prs:
        row["avg_review_time_days"] = float("nan")
        row["avg_pr_lifetime_days"] = float("nan")
        row["avg_non_author_commenters"] = float("nan")
        row["avg_human_reviewers"] = float("nan")
        row["avg_bot_reviewers"] = float("nan")
    else:
        review_times = []
        for p in win_prs:
            if p.ready_for_review_at and p.merged_at:
                delta = (p.merged_at - p.ready_for_review_at).total_seconds() / 86400
                if delta < 0:
                    print(
                        f"  Warning: PR #{p.number} has negative review time "
                        f"({delta:.2f}d); skipping."
                    )
                    continue
                review_times.append(delta)
        row["avg_review_time_days"] = (
            mean(review_times) if review_times else float("nan")
        )

        lifetimes = []
        for p in win_prs:
            if p.first_commit_date and p.merged_at:
                delta = (p.merged_at - p.first_commit_date).total_seconds() / 86400
                if delta < 0:
                    print(
                        f"  Warning: PR #{p.number} has negative PR lifetime "
                        f"({delta:.2f}d); skipping."
                    )
                    continue
                lifetimes.append(delta)
        row["avg_pr_lifetime_days"] = mean(lifetimes) if lifetimes else float("nan")

        non_author_counts = []
        human_counts = []
        bot_counts = []
        for p in win_prs:
            # Combine reviews + comments; each entry is (login, author_type)
            all_participants: dict[str, Optional[str]] = {}
            for login, atype in p.review_authors + p.comment_authors:
                if login and login != p.author_login:
                    # Keep the most informative type seen (Bot beats None)
                    existing = all_participants.get(login)
                    if existing != "Bot":
                        all_participants[login] = atype

            total = len(all_participants)
            bots = sum(
                1
                for login, atype in all_participants.items()
                if _is_bot_reviewer(login, atype, _bot_logins)
            )
            humans = total - bots
            non_author_counts.append(total)
            human_counts.append(humans)
            bot_counts.append(bots)

        row["avg_non_author_commenters"] = mean(non_author_counts)
        row["avg_human_reviewers"] = mean(human_counts)
        row["avg_bot_reviewers"] = mean(bot_counts)

    return row


def compute_all_windows(
    commits: list[CommitRecord],
    prs: list[PRRecord],
    start_date: str,
    avg_weeks: int = 12,
    bot_logins: set[str] | None = None,
) -> pd.DataFrame:
    """Generate weekly windows and compute metrics for each.

    Each data point covers exactly 1 week of activity.
    The rolling average smooths over avg_weeks consecutive weekly data points.
    """
    window_delta = timedelta(weeks=1)
    slide_delta = timedelta(weeks=1)

    start_dt = datetime.fromisoformat(start_date).replace(tzinfo=timezone.utc)
    today = datetime.now(tz=timezone.utc)

    rows = []
    window_start = start_dt
    while True:
        window_end = window_start + window_delta
        if window_end > today:
            break
        row = compute_window_metrics(
            commits, prs, window_start, window_end, bot_logins=bot_logins
        )
        rows.append(row)
        window_start += slide_delta

    df = pd.DataFrame(rows)
    if df.empty:
        return df

    metric_cols = [
        "num_contributors_all",
        "num_contributors_code",
        "commits_total_per_contrib",
        "commits_code_only_per_contrib",
        "commits_mixed_per_contrib",
        "commits_doc_only_per_contrib",
        "lines_added_per_contrib",
        "lines_added_code_only_per_contrib",
        "lines_added_doc_only_per_contrib",
        "lines_deleted_per_contrib",
        "lines_deleted_code_only_per_contrib",
        "lines_deleted_doc_only_per_contrib",
        "avg_review_time_days",
        "avg_pr_lifetime_days",
        "avg_non_author_commenters",
        "avg_human_reviewers",
        "avg_bot_reviewers",
    ]
    for col in metric_cols:
        if col in df.columns:
            df[f"{col}_rolling"] = df[col].rolling(avg_weeks).mean()

    return df


# ---------------------------------------------------------------------------
# Output
# ---------------------------------------------------------------------------


def write_csv(df: pd.DataFrame, path: Path) -> None:
    df.to_csv(path, index=False)
    print(f"Wrote {path}")


def plot_metrics(
    df: pd.DataFrame, path: Path, avg_weeks: int = 12, repo_name: str = ""
) -> None:
    if df.empty:
        print("No data to plot.")
        return

    x = pd.to_datetime(df["window_start"])

    fig, axes = plt.subplots(3, 2, figsize=(14, 14), sharex=False)
    title = f"{repo_name} — Repository Metrics" if repo_name else "Repository Metrics"
    fig.suptitle(title, fontsize=14, y=0.995)
    fig.text(
        0.5,
        0.982,
        f"Faint lines = weekly counts  |  Bold lines = {avg_weeks}-week rolling average",
        ha="center",
        va="top",
        fontsize=9,
        color="gray",
    )

    def _plot_raw_rolling(ax, col, label, color):
        if col in df.columns:
            ax.plot(
                x, df[col], alpha=0.35, linewidth=1, color=color, label=f"{label} (raw)"
            )
        roll_col = f"{col}_rolling"
        if roll_col in df.columns:
            ax.plot(
                x,
                df[roll_col],
                linewidth=2,
                color=color,
                label=f"{label} ({avg_weeks}-week rolling)",
            )

    # (0,0) Commits per contributor
    ax = axes[0, 0]
    _plot_raw_rolling(ax, "commits_total_per_contrib", "total", "steelblue")
    _plot_raw_rolling(ax, "commits_code_only_per_contrib", "code-only", "darkorange")
    _plot_raw_rolling(ax, "commits_doc_only_per_contrib", "doc-only", "seagreen")
    ax.set_title("Commits on origin/HEAD per contributor")
    ax.legend(fontsize=7)
    ax.set_ylabel("commits")

    # (0,1) Team size
    ax = axes[0, 1]
    _plot_raw_rolling(ax, "num_contributors_all", "contributors (all)", "steelblue")
    _plot_raw_rolling(ax, "num_contributors_code", "contributors (code)", "darkorange")
    ax.set_title("Team size")
    ax.legend(fontsize=7)
    ax.set_ylabel("count")

    # (1,0) Lines added per contributor
    ax = axes[1, 0]
    _plot_raw_rolling(ax, "lines_added_per_contrib", "total", "steelblue")
    _plot_raw_rolling(
        ax, "lines_added_code_only_per_contrib", "code-only", "darkorange"
    )
    _plot_raw_rolling(ax, "lines_added_doc_only_per_contrib", "doc-only", "seagreen")
    ax.set_title("Lines added per contributor")
    ax.legend(fontsize=7)
    ax.set_ylabel("lines")

    # (1,1) Lines deleted per contributor
    ax = axes[1, 1]
    _plot_raw_rolling(ax, "lines_deleted_per_contrib", "total", "steelblue")
    _plot_raw_rolling(
        ax, "lines_deleted_code_only_per_contrib", "code-only", "darkorange"
    )
    _plot_raw_rolling(ax, "lines_deleted_doc_only_per_contrib", "doc-only", "seagreen")
    ax.set_title("Lines deleted per contributor")
    ax.legend(fontsize=7)
    ax.set_ylabel("lines")

    # (2,0) Avg review time & PR lifetime (days)
    ax = axes[2, 0]
    _plot_raw_rolling(ax, "avg_review_time_days", "review time", "steelblue")
    _plot_raw_rolling(ax, "avg_pr_lifetime_days", "PR lifetime", "darkorange")
    ax.set_title("Avg review time & PR lifetime (days)")
    ax.legend(fontsize=7)
    ax.set_ylabel("days")

    # (2,1) Avg reviewers & commenters per PR (human / bot / total)
    ax = axes[2, 1]
    _plot_raw_rolling(ax, "avg_non_author_commenters", "total", "steelblue")
    _plot_raw_rolling(ax, "avg_human_reviewers", "human", "darkorange")
    _plot_raw_rolling(ax, "avg_bot_reviewers", "bot", "mediumorchid")
    ax.set_title("Avg reviewers & commenters per PR (non-author)")
    ax.legend(fontsize=7)
    ax.set_ylabel("count")

    # Apply x-axis date formatting to every subplot (no label — dates speak for themselves)
    for ax_row in axes:
        for ax in ax_row:
            ax.xaxis.set_major_formatter(matplotlib.dates.DateFormatter("%Y-%m"))
            plt.setp(
                ax.xaxis.get_majorticklabels(), rotation=45, ha="right", fontsize=7
            )

    plt.tight_layout()
    plt.savefig(path, dpi=150)
    plt.close(fig)
    print(f"Wrote {path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Compute rolling-window Git repository metrics."
    )
    parser.add_argument("repo_path", help="Path to local git clone with origin remote")
    parser.add_argument("start_date", help="ISO date string (e.g. 2025-01-01)")
    parser.add_argument(
        "--avg-weeks",
        type=int,
        default=12,
        help="Width of the trailing rolling average in weeks (default: 12)",
    )
    args = parser.parse_args()

    repo_path = args.repo_path
    start_date = args.start_date
    avg_weeks = args.avg_weeks

    # Validate repo
    result = subprocess.run(
        ["git", "rev-parse", "--git-dir"], capture_output=True, cwd=repo_path
    )
    if result.returncode != 0:
        sys.exit(f"Error: {repo_path} is not a git repository.")

    # Validate origin/HEAD exists
    head_result = subprocess.run(
        ["git", "rev-parse", "--verify", "origin/HEAD"],
        capture_output=True,
        text=True,
        cwd=repo_path,
    )
    if head_result.returncode != 0:
        sys.exit(
            "Error: origin/HEAD is not set. Run:\n"
            "  git remote set-head origin --auto\n"
            "to detect and set it."
        )

    # Validate gh auth
    auth_result = subprocess.run(
        ["gh", "auth", "status"], capture_output=True, text=True
    )
    if auth_result.returncode != 0:
        sys.exit("Error: gh auth status failed. Please run 'gh auth login'.")

    # Derive owner/repo
    owner_repo = get_remote_owner_repo(repo_path)
    repo_name = owner_repo.split("/")[-1]
    print(f"Repository: {owner_repo}")

    # Load excludes
    excluded_prs, excluded_commits, extra_bot_logins = load_excludes(repo_name)

    # Phase 1a: Git data
    print(f"Parsing git log since {start_date}…")
    commits = parse_git_log(repo_path, start_date, excluded_commits)
    print(f"  Found {len(commits)} commits.")

    # Phase 1b: GitHub PR data
    cache_path = Path(f"{repo_name}_pr_cache.jsonl")
    prs = fetch_merged_prs(owner_repo, repo_path, start_date, cache_path, excluded_prs)
    print(f"  Found {len(prs)} merged PRs.")

    # Phase 2: Metrics
    print("Computing metrics…")
    df = compute_all_windows(
        commits, prs, start_date, avg_weeks, bot_logins=extra_bot_logins
    )
    if df.empty:
        print("No complete windows found (window_end > today for all windows).")
        sys.exit(0)
    print(f"  {len(df)} windows computed.")

    # Phase 3: Output
    write_csv(df, Path(f"{repo_name}_stats.csv"))
    plot_metrics(df, Path(f"{repo_name}_stats.png"), avg_weeks, repo_name)

    print("Done.")


if __name__ == "__main__":
    main()
