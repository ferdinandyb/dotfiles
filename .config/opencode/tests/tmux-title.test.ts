import { expect, test } from "bun:test"
import { extractTmuxLabel, isResumeLaunch } from "../plugins/tmux-title-label"
import * as pluginMod from "../plugins/tmux-title"

test("plugin exports are all functions", () => {
  const values = Object.values(pluginMod)
  expect(values.length).toBeGreaterThan(0)
  for (const value of values) expect(typeof value).toBe("function")
})

test("extractTmuxLabel extracts clean prefix label up to 15 chars", () => {
  expect(extractTmuxLabel("tmux-title | Short tmux titles")).toBe("tmux-title")
  expect(extractTmuxLabel("bg3-act2 | Shadow-Cursed Lands quest")).toBe("bg3-act2")
  expect(extractTmuxLabel("mjölnir | Drop parsing and use Mjölnir values")).toBe("mjölnir")
  expect(extractTmuxLabel("my-super-long-tag | description")).toBe("my-super-long-t")
  expect(extractTmuxLabel("user-auth-fix | description")).toBe("user-auth-fix")
  expect(extractTmuxLabel("Foo Bar | x")).toBe("foo-bar")
  expect(extractTmuxLabel("foo_bar | x")).toBe("foo-bar")
  expect(extractTmuxLabel("label | title | extra")).toBe("label")
})

test("isResumeLaunch only matches continue/session flags", () => {
  expect(isResumeLaunch(["opencode", "--port", "0"])).toBe(false)
  expect(isResumeLaunch(["opencode", "-c"])).toBe(true)
  expect(isResumeLaunch(["opencode", "--continue", "--port", "0"])).toBe(true)
  expect(isResumeLaunch(["opencode", "-s", "ses_123"])).toBe(true)
  expect(isResumeLaunch(["opencode", "--session=ses_123"])).toBe(true)
})

test("extractTmuxLabel uses undelimited user titles and skips defaults", () => {
  expect(extractTmuxLabel("hotfix")).toBe("hotfix")
  expect(extractTmuxLabel("Requesting reviewers for project")).toBe("requesting-revi")
  expect(extractTmuxLabel("New session - 2026-09-24T12:00:00.000Z")).toBeNull()
  expect(extractTmuxLabel("Child session - 2026-09-24T12:00:00.000Z")).toBeNull()
  expect(extractTmuxLabel(undefined)).toBeNull()
  expect(extractTmuxLabel("   | description")).toBeNull()
})
