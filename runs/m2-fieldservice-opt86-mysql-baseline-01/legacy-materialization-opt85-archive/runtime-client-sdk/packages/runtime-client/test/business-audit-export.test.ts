import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('business audit export client binds strict server prepare and byte download routes', async () => {
  const originalFetch = globalThis.fetch
  const requests: Array<{ url: string; init?: RequestInit }> = []
  globalThis.fetch = async (input, init) => {
    requests.push({ url: String(input), init })
    if (String(input).includes('/downloads/')) {
      return new Response('audit_id,event\naudit-1,order.completed\n', {
        status: 200,
        headers: { 'content-type': 'text/csv', 'content-disposition': 'attachment; filename="business-audit.csv"' },
      })
    }
    return new Response(JSON.stringify({
      id: 'audexp-1', report_source: 'business_audit_events', filename: 'business-audit.csv',
      content_sha256: 'a'.repeat(64), row_count: 1, audit_identity: 'business_audit_events:audexp-1',
      scope_sha256: 'b'.repeat(64), filters: { event: 'order.completed' }, download_token: 'short-lived-token',
      expires_at: '2026-08-12T00:15:00Z',
    }), { status: 201, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'access-token' })
    const prepared = await client.prepareBusinessAuditEventExport({ filters: { event: 'order.completed' }, format: 'csv' }, { idempotencyKey: 'prepare-1' })
    assert.equal(requests[0]?.url, 'https://runtime.example.test/business/audit-event-exports')
    assert.equal(new Headers(requests[0]?.init?.headers).get('Idempotency-Key'), 'prepare-1')
    assert.deepEqual(JSON.parse(String(requests[0]?.init?.body)), { filters: { event: 'order.completed' }, format: 'csv' })
    assert.equal(prepared.content_sha256.length, 64)

    const downloaded = await client.downloadBusinessAuditEventExport(prepared.download_token)
    assert.equal(requests[1]?.url, 'https://runtime.example.test/business/audit-event-exports/downloads/short-lived-token')
    assert.equal(await downloaded.blob.text(), 'audit_id,event\naudit-1,order.completed\n')
    assert.equal(downloaded.filename, 'business-audit.csv')
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('business audit export client fails closed outside business workspace', () => {
  const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'consumer_portal', getAccessToken: () => 'token' })
  assert.throws(() => client.prepareBusinessAuditEventExport({ filters: {} }, { idempotencyKey: 'prepare-1' }), /business_workspace/)
  assert.throws(() => client.downloadBusinessAuditEventExport('token'), /business_workspace/)
})
