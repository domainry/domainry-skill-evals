import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('file scan reads the Runtime-owned exact file identity contract', async () => {
  const originalFetch = globalThis.fetch
  let requested = ''
  globalThis.fetch = (async (input: string | URL | Request) => {
    requested = String(input)
    return new Response(JSON.stringify({ file_id: 'file/1', content_sha256: 'abc', size: 7, status: 'pending' }), { status: 200, headers: { 'Content-Type': 'application/json' } })
  }) as typeof fetch
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.test/api', workspaceId: 'workspace-a', surface: 'business_workspace' })
    const evidence = await client.getFileScan('file/1')
    assert.equal(requested, 'https://runtime.test/api/files/file%2F1/scan')
    assert.equal(evidence.status, 'pending')
    assert.equal(evidence.scan_receipt, undefined)
  } finally {
    globalThis.fetch = originalFetch
  }
})
