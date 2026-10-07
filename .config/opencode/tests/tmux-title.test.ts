import { expect, test } from "bun:test"
import { extractTmuxLabel, isResumeLaunch, resolveTmuxPane } from "../plugins/lib/tmux-title-label"

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

test("resolveTmuxPane resolves pane ID even when TMUX is stripped in embedded terminals", () => {
  expect(resolveTmuxPane({})).toBeNull()
  expect(resolveTmuxPane({ TMUX: "/tmp/tmux-502/default,1,0", TMUX_PANE: "%12" })).toBe("%12")
  expect(resolveTmuxPane({ TMUX_PANE: "%42" })).toBe("%42")
})
