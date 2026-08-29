import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('Web Push self-service SDK uses the closed business boundary and redacted projections', async () => {
  const originalFetch = globalThis.fetch
  const calls: Array<{ url: string; method?: string; headers: Headers; body?: string }> = []
  const responses = [
    { ready: true, public_key: 'public-vapid-key', connection_key: 'push', status: 'verified' },
    { subscriptions: [{ id: 'sub/1', user_id: 'user', endpoint_hash: 'hash', status: 'active', created_at: 'created', updated_at: 'updated' }], count: 1 },
    { id: 'sub/1', user_id: 'user', endpoint_hash: 'hash', status: 'active', created_at: 'created', updated_at: 'updated' },
    { id: 'sub/1', user_id: 'user', endpoint_hash: 'hash', status: 'revoked', created_at: 'created', updated_at: 'updated', revoked_at: 'updated' },
  ]
  globalThis.fetch = (async (input, init) => {
    calls.push({ url: String(input), method: init?.method, headers: new Headers(init?.headers), body: init?.body?.toString() })
    return new Response(JSON.stringify(responses[calls.length - 1]), { status: 200, headers: { 'Content-Type': 'application/json' } })
  }) as typeof fetch

  try {
    const client = new RuntimeClient({ apiBaseUrl: 'http://runtime.test/api', workspaceId: 'workspace-a', surface: 'business_workspace', getAccessToken: () => 'token' })
    const readiness = await client.getWebPushReadiness()
    assert.equal(readiness.public_key, 'public-vapid-key')
    assert.equal('private_key' in readiness, false)
    const listed = await client.listWebPushSubscriptions()
    assert.equal(listed.count, 1)
    assert.equal('endpoint' in listed.subscriptions[0], false)
    await client.upsertWebPushSubscription('sub/1', { endpoint: 'https://push.example/sub', p256dh: 'p256-secret', auth: 'auth-secret' }, { idempotencyKey: 'upsert-1', requestId: 'request-upsert' })
    await client.revokeWebPushSubscription('sub/1', { idempotencyKey: 'revoke-1', requestId: 'request-revoke' })
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.deepEqual(calls.map((call) => [call.method ?? 'GET', call.url]), [
    ['GET', 'http://runtime.test/api/business/notifications/web-push/readiness'],
    ['GET', 'http://runtime.test/api/business/notifications/web-push/subscriptions'],
    ['PUT', 'http://runtime.test/api/business/notifications/web-push/subscriptions/sub%2F1'],
    ['POST', 'http://runtime.test/api/business/notifications/web-push/subscriptions/sub%2F1/revoke'],
  ])
  for (const call of calls) {
    assert.equal(call.headers.get('X-Domainry-Product-Surface'), 'business_workspace')
    assert.equal(call.headers.get('X-Workspace-ID'), 'workspace-a')
    assert.equal(call.headers.get('Authorization'), 'Bearer token')
  }
  assert.equal(calls[2].headers.get('Idempotency-Key'), 'upsert-1')
  assert.equal(calls[2].headers.get('X-Request-ID'), 'request-upsert')
  assert.deepEqual(JSON.parse(calls[2].body ?? '{}'), { endpoint: 'https://push.example/sub', p256dh: 'p256-secret', auth: 'auth-secret' })
  assert.equal(calls[3].headers.get('Idempotency-Key'), 'revoke-1')
})

test('Web Push self-service SDK fails closed outside business_workspace and without idempotency keys', () => {
  for (const surface of ['admin_console', 'consumer_portal'] as const) {
    const client = new RuntimeClient({ surface })
    assert.throws(() => client.getWebPushReadiness(), /business_workspace/)
    assert.throws(() => client.listWebPushSubscriptions(), /business_workspace/)
    assert.throws(() => client.upsertWebPushSubscription('sub', { endpoint: 'https://example.test', p256dh: 'p', auth: 'a' }, { idempotencyKey: 'key' }), /business_workspace/)
    assert.throws(() => client.revokeWebPushSubscription('sub', { idempotencyKey: 'key' }), /business_workspace/)
  }
  const client = new RuntimeClient({ surface: 'business_workspace' })
  assert.throws(() => client.upsertWebPushSubscription('', { endpoint: 'https://example.test', p256dh: 'p', auth: 'a' }, { idempotencyKey: 'key' }), /subscriptionID is required/)
  assert.throws(() => client.upsertWebPushSubscription('sub', { endpoint: 'https://example.test', p256dh: 'p', auth: 'a' }, { idempotencyKey: ' ' }), /Idempotency-Key is required/)
  assert.throws(() => client.revokeWebPushSubscription('sub', { idempotencyKey: '' }), /Idempotency-Key is required/)
})
