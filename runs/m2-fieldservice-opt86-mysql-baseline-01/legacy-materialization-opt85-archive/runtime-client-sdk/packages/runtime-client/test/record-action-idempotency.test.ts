import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('runRecordAction carries idempotency only in the HTTP header', async () => {
  const originalFetch = globalThis.fetch
  let captured: { headers: Headers; body: unknown } | undefined
  globalThis.fetch = (async (_input, init) => {
    captured = {
      headers: new Headers(init?.headers),
      body: JSON.parse(String(init?.body)),
    }
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  }) as typeof fetch

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'http://runtime.test/api',
      surface: 'business_workspace',
    })
    await client.runRecordAction(
      'leave_request',
      'leave-1',
      'leave_request.submit',
      { comment: 'submit' },
      { idempotencyKey: 'leave-submit-1' },
    )
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.ok(captured)
  assert.equal(captured.headers.get('Idempotency-Key'), 'leave-submit-1')
  assert.deepEqual(captured.body, {
    data: { comment: 'submit' },
  })
})
