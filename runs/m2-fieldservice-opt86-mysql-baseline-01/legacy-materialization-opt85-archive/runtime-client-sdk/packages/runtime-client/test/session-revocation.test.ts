import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('session revocation SDK methods expose stable paths, authorization, and idempotency headers', async () => {
  const originalFetch = globalThis.fetch
  const calls: Array<{ url: string; method?: string; headers: Headers }> = []
  globalThis.fetch = (async (input, init) => {
    calls.push({ url: String(input), method: init?.method, headers: new Headers(init?.headers) })
    return new Response(JSON.stringify({ revoked_sessions: 1, current_session_id: 'session-current' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
  }) as typeof fetch

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'http://runtime.test/api',
      workspaceId: 'workspace-a',
      surface: 'business_workspace',
      getAccessToken: () => 'admin-token',
    })
    const result = await client.revokeOtherSessions('self-revoke-1', 'self-token')
    assert.equal(result.revoked_sessions, 1)
    assert.equal(result.current_session_id, 'session-current')
    await client.forceLogoutIdentityUser('user/1', 'force-logout-1')
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.equal(calls.length, 2)
  assert.equal(calls[0].url, 'http://runtime.test/api/auth/sessions/revoke-others')
  assert.equal(calls[0].method, 'POST')
  assert.equal(calls[0].headers.get('Authorization'), 'Bearer self-token')
  assert.equal(calls[0].headers.get('Idempotency-Key'), 'self-revoke-1')
  assert.equal(calls[0].headers.get('X-Domainry-Product-Surface'), null)
  assert.equal(calls[1].url, 'http://runtime.test/api/identity/users/user%2F1/force-logout')
  assert.equal(calls[1].headers.get('Authorization'), 'Bearer admin-token')
  assert.equal(calls[1].headers.get('Idempotency-Key'), 'force-logout-1')
  assert.equal(calls[1].headers.get('X-Domainry-Product-Surface'), 'business_workspace')
})

test('session revocation SDK fails locally when its idempotency contract is absent', () => {
  const client = new RuntimeClient({ apiBaseUrl: '/api', surface: 'business_workspace' })
  assert.throws(() => client.revokeOtherSessions(''), /Idempotency-Key is required/)
  assert.throws(() => client.forceLogoutIdentityUser('user-1', '  '), /Idempotency-Key is required/)
  assert.throws(() => client.forceLogoutIdentityUser(' ', 'force-1'), /userID is required/)
})
