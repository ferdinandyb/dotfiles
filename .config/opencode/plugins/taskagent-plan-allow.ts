import type { Plugin } from "@opencode-ai/plugin"

const MARKER = "Plan Mode - System Reminder"
const ADDENDUM = [
  "<system-reminder>",
  "Exception: `taskagent add ...` is allowed. Append-only to task DB,",
  "equivalent to writing the plan file. No other taskagent subcommands.",
  "</system-reminder>",
].join("\n")

export default (async () => ({
  "experimental.chat.messages.transform": async (_input, output) => {
    const last = output.messages.at(-1)
    if (!last || last.info.role !== "user") return
    const reminder = last.parts.findLast(
      (p) => p.type === "text" && p.text.includes(MARKER),
    )
    if (!reminder || reminder.type !== "text") return
    last.parts.push({
      id: reminder.id + ".tg",
      sessionID: reminder.sessionID,
      messageID: reminder.messageID,
      type: "text",
      text: ADDENDUM,
      synthetic: true,
    })
  },
})) satisfies Plugin
