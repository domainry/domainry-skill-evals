import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeApiError, RuntimeClient, subscribeBusinessEvents } from '../src/index.ts'

function sse(chunks: string[]) {
  return new ReadableStream({
    start(controller) {
      for (const chunk of chunks) controller.enqueue(new TextEncoder().encode(chunk))
      controller.close()
    },
  })
}

test('generated-project public API authenticates, filters, and resumes with Last-Event-ID', async () => {
  const originalFetch = globalThis.fetch
  const requests: Array<{ url: string; headers: Headers }> = []
  let calls = 0
  let subscription: ReturnType<typeof subscribeBusinessEvents>
  globalThis.fetch = (async (input, init) => {
    calls++
    requests.push({ url: String(input), headers: new Headers(init?.headers) })
    if (calls === 1) {
      return new Response(sse([
        'id: 7\nevent: business.refresh\ndata: {"id":"7","type":"refresh","object_key":"customer","reason":"mutation","occurred_at":"2026-08-12T00:00:00Z"}\n\n',
      ]), { headers: { 'content-type': 'text/event-stream' } })
    }
    subscription.close()
    return new Response(sse([]), { headers: { 'content-type': 'text/event-stream' } })
  }) as typeof fetch

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'https://runtime.example',
      workspaceId: 'workspace-a',
      surface: 'business_workspace',
      getAccessToken: () => `token-${calls + 1}`,
    })
    const events: string[] = []
    subscription = subscribeBusinessEvents(client, {
      objectKeys: ['customer'], onEvent: (event) => events.push(event.id), initialRetryMs: 250, maxRetryMs: 250,
    })
    await subscription.closed
    assert.deepEqual(events, ['7'])
    assert.equal(subscription.lastEventId(), '7')
    assert.equal(requests[0].headers.get('authorization'), 'Bearer token-1')
    assert.equal(requests[0].headers.get('x-workspace-id'), 'workspace-a')
    assert.equal(requests[1].headers.get('last-event-id'), '7')
    assert.match(requests[0].url, /objects=customer/)
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('resync is surfaced and stable Runtime errors retain request identity', async () => {
  const originalFetch = globalThis.fetch
  const states: string[] = []
  globalThis.fetch = (async () => new Response(sse([
    'event: business.resync\ndata: {"id":"","type":"resync","reason":"replay_unavailable","occurred_at":"2026-08-12T00:00:00Z"}\n\n',
  ]), { headers: { 'content-type': 'text/event-stream' } })) as typeof fetch
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example', workspaceId: 'workspace-a', surface: 'business_workspace' })
    const types: string[] = []
    const subscription = client.subscribeBusinessEvents({
      reconnect: false, onEvent: (event) => types.push(event.type), onStateChange: (state) => states.push(state),
    })
    await subscription.closed
    assert.deepEqual(types, ['resync'])
    assert.deepEqual(states, ['connecting', 'open', 'closed'])
  } finally {
    globalThis.fetch = originalFetch
  }

  const errors: unknown[] = []
  globalThis.fetch = (async () => new Response(JSON.stringify({ code: 'auth.session_expired', message: 'expired' }), {
    status: 401, headers: { 'content-type': 'application/json', 'x-request-id': 'req-1' },
  })) as typeof fetch
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example', surface: 'business_workspace' })
    const subscription = client.subscribeBusinessEvents({ reconnect: false, onEvent() {}, onError: (error) => errors.push(error) })
    await subscription.closed
    assert.ok(errors[0] instanceof RuntimeApiError)
    assert.equal((errors[0] as RuntimeApiError).code, 'auth.session_expired')
    assert.equal((errors[0] as RuntimeApiError).requestId, 'req-1')
  } finally {
    globalThis.fetch = originalFetch
  }
})
