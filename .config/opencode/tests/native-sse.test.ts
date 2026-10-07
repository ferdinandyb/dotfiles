import { expect, test } from "bun:test"
import { Effect, Stream } from "effect"
import { sseWithDone } from "@opencode/ai/route/framing"

test("v2's native parser discards Vertex partner keepalives without a plugin", async () => {
  const encoder = new TextEncoder()
  const bytes = Stream.fromIterable([
    "data: : keep", "alive\n\ndata: {\"choices\":[]}\n\n", "data: [DONE]\n\n",
  ].map((text) => encoder.encode(text)))
  const events = await Effect.runPromise(Stream.runCollect(sseWithDone.frame(bytes)))
  expect(events).toEqual(['{"choices":[]}', "[DONE]"])
})
