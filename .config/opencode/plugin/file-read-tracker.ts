/**
 * file-read-tracker — opencode plugin
 *
 * Re-implements the file-staleness guard that opencode carried internally as
 * `FileTime` (deleted in commit 76a141090, April 2026).
 *
 * Tracks a content hash of every file each session reads or writes, persisted
 * across restarts in a SQLite database. Before any `write` or `edit`, checks
 * that:
 *   1. This session has previously read the file (no record → must read first).
 *   2. The file has not changed on disk since this session last saw it
 *      (hash mismatch → stale in-memory copy, must re-read).
 *
 * Throwing in `tool.execute.before` surfaces as a tool error to the model,
 * which then re-reads the file before retrying — identical to the mechanism
 * the old FileTime.assert relied on.
 *
 * Storage: ~/.local/state/opencode/file-read-tracker.sqlite
 *   PRIMARY KEY (session_id, path)  — one row per file per session
 *
 * Pruning: on `session.deleted` event, rows for that session are deleted.
 *   No age-based backstop (intentional).
 *
 * apply_patch (GPT-5-family only, mutually exclusive with write/edit):
 *   Not guarded in this version. Extension point marked below.
 */

import type { Plugin } from "@opencode-ai/plugin"
import { Database } from "bun:sqlite"
import * as fs from "fs"
import * as os from "os"
import * as path from "path"

const PLUGIN_ID = "file-read-tracker"

// ── Database ──────────────────────────────────────────────────────────────────

function openDb(stateDir: string) {
  const db = new Database(path.join(stateDir, `${PLUGIN_ID}.sqlite`))
  db.run("PRAGMA journal_mode=WAL")
  db.run("PRAGMA busy_timeout=5000")
  db.run(`
    CREATE TABLE IF NOT EXISTS file_stamp (
      session_id TEXT    NOT NULL,
      path       TEXT    NOT NULL,
      hash       TEXT    NOT NULL,
      size       INTEGER NOT NULL,
      mtime_ms   INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      PRIMARY KEY (session_id, path)
    )
  `)
  return db
}

// ── Hashing ───────────────────────────────────────────────────────────────────

async function hashFile(absPath: string): Promise<{ hash: string; size: number; mtimeMs: number } | null> {
  const file = Bun.file(absPath)
  const stat = await file.stat().catch(() => null)
  if (!stat || !stat.isFile()) return null
  // Fast-path: if size and mtime match the stored stamp, the file is almost
  // certainly unchanged. The caller can use this to skip the read+hash when
  // doing the guard check. The final decision is always hash-based.
  const bytes = await file.arrayBuffer().catch(() => null)
  if (!bytes) return null
  return {
    hash: Bun.hash(new Uint8Array(bytes)).toString(),
    size: stat.size,
    mtimeMs: stat.mtimeMs,
  }
}

// ── Queries ───────────────────────────────────────────────────────────────────

function makeQueries(db: Database) {
  const upsert = db.prepare(`
    INSERT INTO file_stamp (session_id, path, hash, size, mtime_ms, updated_at)
    VALUES ($session_id, $path, $hash, $size, $mtime_ms, $updated_at)
    ON CONFLICT (session_id, path) DO UPDATE SET
      hash       = excluded.hash,
      size       = excluded.size,
      mtime_ms   = excluded.mtime_ms,
      updated_at = excluded.updated_at
  `)

  const select = db.prepare<{ hash: string; size: number; mtime_ms: number }, [string, string]>(
    "SELECT hash, size, mtime_ms FROM file_stamp WHERE session_id = ? AND path = ?",
  )

  const deleteSession = db.prepare("DELETE FROM file_stamp WHERE session_id = ?")

  return { upsert, select, deleteSession }
}

// ── Plugin ────────────────────────────────────────────────────────────────────

export default (async ({ directory }) => {
  // Compute the state dir directly — mirrors packages/core/src/global.ts.
  // Must not call client.path.get() here: plugins initialize during server
  // bootstrap before the HTTP server is ready, so any client call deadlocks.
  const stateDir = path.join(
    process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local", "state"),
    "opencode",
  )
  fs.mkdirSync(stateDir, { recursive: true })
  const db = openDb(stateDir)
  const q = makeQueries(db)

  function record(sessionId: string, absPath: string, stamp: { hash: string; size: number; mtimeMs: number }) {
    q.upsert.run({
      $session_id: sessionId,
      $path: absPath,
      $hash: stamp.hash,
      $size: stamp.size,
      $mtime_ms: stamp.mtimeMs,
      $updated_at: Date.now(),
    })
  }

  async function guard(sessionId: string, absPath: string) {
    // File missing → new-file creation, allow.
    const current = await hashFile(absPath)
    if (!current) return

    const stored = q.select.get(sessionId, absPath)

    if (!stored) {
      throw new Error(
        `[${PLUGIN_ID}] You must read ${absPath} in this session before writing it. Use the Read tool first.`,
      )
    }

    // Fast-path: size and mtime both match → almost certainly unchanged, skip
    // recomputing hash (hash was already computed above in hashFile — use it).
    if (stored.hash !== current.hash) {
      throw new Error(
        `[${PLUGIN_ID}] File ${absPath} has changed on disk since this session last read it — ` +
          `your in-memory copy is stale. Read it again before writing.`,
      )
    }
  }

  return {
    // ── After read: record baseline ──────────────────────────────────────────
    "tool.execute.after": async (input, _output) => {
      if (input.tool === "read") {
        const filePath: string | undefined = input.args?.filePath
        if (!filePath) return
        const absPath = path.resolve(directory, filePath)
        const stamp = await hashFile(absPath)
        if (!stamp) return // directory or missing — skip
        record(input.sessionID, absPath, stamp)
        return
      }

      // After write/edit: refresh baseline to the post-formatter on-disk state
      // so consecutive agent writes to the same file are not falsely blocked.
      if (input.tool === "write" || input.tool === "edit") {
        const filePath: string | undefined = input.args?.filePath
        if (!filePath) return
        const absPath = path.resolve(directory, filePath)
        const stamp = await hashFile(absPath)
        if (!stamp) return
        record(input.sessionID, absPath, stamp)
      }

      // apply_patch (GPT-5-family only, mutually exclusive with write/edit):
      // Extension point — parse patchText to extract affected file paths,
      // then refresh each file's stamp here and guard them in before hook below.
    },

    // ── Before write/edit: guard ─────────────────────────────────────────────
    "tool.execute.before": async (input, output) => {
      if (input.tool === "write" || input.tool === "edit") {
        const filePath: string | undefined = output.args?.filePath
        if (!filePath) return
        const absPath = path.resolve(directory, filePath)
        await guard(input.sessionID, absPath)
      }

      // apply_patch extension point: parse output.args.patchText for file paths
      // and call guard() on each affected existing file.
    },

    // ── Pruning: delete stamps when a session is removed ─────────────────────
    event: async ({ event }) => {
      if (event.type === "session.deleted") {
        const sessionId = (event.properties as any)?.info?.id
        if (sessionId) q.deleteSession.run(sessionId)
      }
    },
  }
}) satisfies Plugin
