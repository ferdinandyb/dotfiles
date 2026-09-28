import type { Plugin } from "@opencode-ai/plugin"

export default (async () => ({
  "shell.env": async (_input, output) => {
    // gcli's markdown renderer silently strips underscores from identifiers.
    // Set here rather than as a --no-markdown flag: gcli only accepts global
    // flags before the subcommand, which would defeat every "gcli <sub> ..."
    // permission pattern.
    output.env.GCLI_RENDER_MARKDOWN = "0"
  },
})) satisfies Plugin
