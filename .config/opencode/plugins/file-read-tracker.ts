import { Plugin } from "@opencode/plugin"
import { Database } from "bun:sqlite"
import fs from "node:fs"
import os from "node:os"
import path from "node:path"

const PLUGIN_ID = "file-read-tracker"

async function hashFile(filePath: string) {
  const file = Bun.file(filePath)
  const stat = await file.stat().catch(() => null)
  if (!stat?.isFile()) return null
  const bytes = await file.arrayBuffer().catch(() => null)
  if (!bytes) return null
  return { hash: Bun.hash(new Uint8Array(bytes)).toString(), size: stat.size, mtimeMs: stat.mtimeMs }
}

export default Plugin.define({
  id: PLUGIN_ID,
  async setup(ctx) {
    const stateDir = path.join(process.env.XDG_STATE_HOME ?? path.join(os.homedir(), ".local/state"), "opencode")
    fs.mkdirSync(stateDir, { recursive: true })
    const db = new Database(path.join(stateDir, `${PLUGIN_ID}.sqlite`))
    db.run("PRAGMA journal_mode=WAL")
    db.run("PRAGMA busy_timeout=5000")
    db.run(`CREATE TABLE IF NOT EXISTS file_stamp (
      session_id TEXT NOT NULL, path TEXT NOT NULL, hash TEXT NOT NULL,
      size INTEGER NOT NULL, mtime_ms INTEGER NOT NULL, updated_at INTEGER NOT NULL,
      PRIMARY KEY (session_id, path)
    )`)
    const upsert = db.prepare(`INSERT INTO file_stamp VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT (session_id, path) DO UPDATE SET
      hash=excluded.hash, size=excluded.size, mtime_ms=excluded.mtime_ms, updated_at=excluded.updated_at`)
    const select = db.prepare<{ hash: string }, [string, string]>(
      "SELECT hash FROM file_stamp WHERE session_id = ? AND path = ?",
    )
    const remove = db.prepare("DELETE FROM file_stamp WHERE session_id = ?")

    await ctx.tool.hook("execute.before", async (event) => {
      if (event.tool !== "write" && event.tool !== "edit") return
      const args = event.input as { path?: string }
      if (!args?.path) return
      const session = await ctx.session.get({ sessionID: event.sessionID })
      const filePath = path.resolve(session.location.directory, args.path)
      const current = await hashFile(filePath)
      if (!current) return
      const stored = select.get(event.sessionID, filePath)
      if (!stored) throw new Error(`[${PLUGIN_ID}] You must read ${filePath} in this session before writing it. Use the read tool first.`)
      if (stored.hash !== current.hash) {
        throw new Error(`[${PLUGIN_ID}] File ${filePath} has changed on disk since this session last read it. Read it again before writing.`)
      }
    })

    await ctx.tool.hook("execute.after", async (event) => {
      if (event.status !== "completed" || !["read", "write", "edit"].includes(event.tool)) return
      const args = event.input as { path?: string }
      if (!args?.path) return
      const session = await ctx.session.get({ sessionID: event.sessionID })
      const filePath = path.resolve(session.location.directory, args.path)
      const stamp = await hashFile(filePath)
      if (stamp) upsert.run(event.sessionID, filePath, stamp.hash, stamp.size, stamp.mtimeMs, Date.now())
    })

    const controller = new AbortController()
    const events = (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        if (event.type === "session.deleted") remove.run(event.data.sessionID)
      }
    })().catch((error) => { if (!controller.signal.aborted) console.error(`[${PLUGIN_ID}]`, error) })
    return async () => { controller.abort(); await events; db.close() }
  },
})
