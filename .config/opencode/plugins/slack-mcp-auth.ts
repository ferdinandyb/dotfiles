import type { Plugin } from "@opencode-ai/plugin"
import { readFile, writeFile } from "fs/promises"
import { homedir } from "os"
import { join } from "path"
import { execFile } from "child_process"
import { promisify } from "util"

const execFileAsync = promisify(execFile)

const MCP_AUTH_PATH = join(homedir(), ".local/share/opencode/mcp-auth.json")
const SLACK_SERVER_URL = "https://mcp.slack.com/mcp"
const OAMA_BIN = join(homedir(), "bin/oama")

async function readMcpAuth(): Promise<Record<string, any>> {
  try {
    const content = await readFile(MCP_AUTH_PATH, "utf-8")
    return JSON.parse(content)
  } catch {
    return {}
  }
}

async function writeMcpAuth(data: Record<string, any>): Promise<void> {
  await writeFile(MCP_AUTH_PATH, JSON.stringify(data, null, 2), { mode: 0o600 })
}

async function syncSlackToken(): Promise<void> {
  const auth = await readMcpAuth()

  // oama access auto-renews if expired and returns just the access token
  const { stdout } = await execFileAsync(OAMA_BIN, ["access", "slack-mcp"])
  const accessToken = stdout.trim()

  if (!accessToken) {
    console.error("[slack-mcp-auth] oama returned no access token")
    return
  }

  auth["slack"] = {
    tokens: {
      accessToken,
    },
    clientInfo: {
      clientId: "1601185624273.8899143856786",
    },
    serverUrl: SLACK_SERVER_URL,
  }

  await writeMcpAuth(auth)
}

export const SlackMcpAuth: Plugin = async () => {
  await syncSlackToken().catch((err) => {
    console.error("[slack-mcp-auth] failed to sync token:", err.message)
  })
  return {}
}

export default SlackMcpAuth
