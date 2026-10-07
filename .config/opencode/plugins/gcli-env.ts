import { Plugin } from "@opencode/plugin"

export default Plugin.define({
  id: "gcli-env",
  async setup(ctx) {
    await ctx.shell.hook("create.before", (event) => {
    // gcli's markdown renderer silently strips underscores from identifiers.
    // Set here rather than as a --no-markdown flag: gcli only accepts global
    // flags before the subcommand, which would defeat every "gcli <sub> ..."
    // permission pattern.
    event.env.GCLI_RENDER_MARKDOWN = "0"
    })
  },
})
