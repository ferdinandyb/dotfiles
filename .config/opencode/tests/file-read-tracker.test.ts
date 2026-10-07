import { expect, test } from "bun:test"
import fs from "node:fs"
import os from "node:os"
import path from "node:path"
import plugin from "../plugins/file-read-tracker"

test("v2 file guard rejects unread and stale writes, and accepts rereads", async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), "opencode-read-tracker-"))
  const oldState = process.env.XDG_STATE_HOME
  process.env.XDG_STATE_HOME = root
  const hooks: Record<string, (event: any) => Promise<void>> = {}
  let cleanup: Awaited<ReturnType<typeof plugin.setup>>
  try {
    cleanup = await plugin.setup({
      tool: { hook: async (name: string, fn: typeof hooks[string]) => { hooks[name] = fn } },
      session: { get: async () => ({ location: { directory: root } }) },
      event: { subscribe: async function* () {} },
    } as any)
    const file = path.join(root, "sample.txt")
    fs.writeFileSync(file, "original")
    const event = { sessionID: "test", input: { path: "sample.txt" } }
    const write = () => hooks["execute.before"]({ ...event, tool: "write" })
    const read = () => hooks["execute.after"]({ ...event, tool: "read", status: "completed" })
    await expect(write()).rejects.toThrow(/must read/)
    await hooks["execute.after"]({ ...event, tool: "read", status: "error" })
    await expect(write()).rejects.toThrow(/must read/)
    await read()
    await expect(write()).resolves.toBeUndefined()
    fs.writeFileSync(file, "external change")
    await expect(write()).rejects.toThrow(/changed on disk/)
    await read()
    await expect(write()).resolves.toBeUndefined()
    fs.writeFileSync(file, "agent change")
    await hooks["execute.after"]({ ...event, tool: "write", status: "completed" })
    await expect(write()).resolves.toBeUndefined()
  } finally {
    await cleanup!?.()
    if (oldState === undefined) delete process.env.XDG_STATE_HOME
    else process.env.XDG_STATE_HOME = oldState
    fs.rmSync(root, { recursive: true, force: true })
  }
})
