import { expect, test } from "bun:test"
import { Host } from "@opencode/plugin/host"
import path from "node:path"

test("the CLI plugin directory exposes its TUI entrypoint", () => {
  const plugin = Host.resolve({ directory: path.resolve(import.meta.dir, "../cli-plugins/tmux-title") })
  expect(String(plugin.tui)).toContain("tmux-title/tui.ts")
})
