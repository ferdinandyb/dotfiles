import { Message } from "@opencode/ai"
import { expect, test } from "bun:test"
import plugin from "../plugins/taskagent-plan-allow"

test("Plan exceptions preserve the system prefix and persist once per mode entry", async () => {
  let hook!: (event: any) => Promise<void>
  const persisted: { sessionID: string; text: string; resume: boolean }[] = []
  await plugin.setup({
    session: {
      hook: async (_name: string, fn: typeof hook) => { hook = fn },
      synthetic: async (input: typeof persisted[number]) => { persisted.push(input) },
    },
  } as any)
  const enter = Message.user("<system-reminder>\nYou are in Plan mode.\n</system-reminder>")
  const leave = Message.user("<system-reminder>\nYou are NO LONGER in Plan mode.\n</system-reminder>")
  const user = Message.user("Inspect the code")
  const prefix = [Message.user("Existing history"), enter]
  const event = {
    sessionID: "ses_fixture", agent: "plan", system: [{ type: "text", text: "Stable system prompt" }],
    messages: [...prefix, user],
  }
  const system = structuredClone(event.system)

  await hook(event)
  expect(event.system).toEqual(system)
  expect(event.messages.slice(0, prefix.length)).toEqual(prefix)
  expect(event.messages.at(-1)).toBe(user)
  expect(persisted).toHaveLength(1)
  expect(persisted[0]).toMatchObject({ sessionID: event.sessionID, resume: false })
  const reminder = persisted[0].text
  expect(event.messages.at(-2)).toEqual(Message.user(reminder))
  expect(reminder).toContain("remain forbidden in Plan Mode")

  await hook(event)
  expect(persisted).toHaveLength(1)
  event.messages = [...prefix, user, Message.user(reminder), Message.assistant("Analysis")]
  await hook(event)
  expect(persisted).toHaveLength(1)

  event.agent = "build"
  event.messages.push(leave, Message.user("Implement"))
  const buildHistory = [...event.messages]
  await hook(event)
  expect(event.system).toEqual(system)
  expect(event.messages).toEqual(buildHistory)
  expect(persisted).toHaveLength(1)

  event.agent = "plan"
  event.messages.push(enter, user)
  const reentryPrefix = event.messages.slice(0, -1)
  await hook(event)
  expect(event.messages.slice(0, reentryPrefix.length)).toEqual(reentryPrefix)
  expect(persisted).toHaveLength(2)
  await hook(event)
  expect(persisted).toHaveLength(2)

  event.messages = [Message.user("Compacted history"), enter]
  await hook(event)
  expect(persisted).toHaveLength(3)
  await hook(event)
  expect(persisted).toHaveLength(3)
  expect(event.system).toEqual(system)
})
