import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('multipart upload and authorized download preserve Runtime scope without forcing JSON content type', async () => {
  const originalFetch = globalThis.fetch
  const requests: Array<{ url: string; method: string; contentType: string | null; body: unknown }> = []
  globalThis.fetch = async (input, init) => {
    const headers = new Headers(init?.headers)
    requests.push({ url: String(input), method: init?.method ?? 'GET', contentType: headers.get('Content-Type'), body: init?.body })
    if ((init?.method ?? 'GET') === 'POST') {
      return new Response(JSON.stringify({ file_id: 'file-1', content_sha256: 'a'.repeat(64), scan_status: 'pending', url: '/uploads/file.txt', filename: 'file.txt', content_type: 'text/plain', size: 5 }), { status: 201, headers: { 'content-type': 'application/json' } })
    }
    return new Response('hello', { headers: { 'content-type': 'text/plain', 'content-disposition': 'inline; filename=file.txt' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    assert.equal((await client.uploadFile(new Blob(['hello'], { type: 'text/plain' }), 'document', 'file_url', { filename: 'note.txt' })).scan_status, 'pending')
    assert.equal((await client.downloadUpload('file.txt', { objectKey: 'document', fieldKey: 'file_url', recordId: 'document-1' })).filename, 'file.txt')
    assert.equal(requests[0].method, 'POST')
    assert.equal(requests[0].contentType, null)
    assert.equal(requests[0].body instanceof FormData, true)
    assert.equal(new URL(requests[1].url).search, '?object_key=document&field_key=file_url&record_id=document-1')
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('record batch SDK covers preview, apply, durable jobs, cancellation, downloads and bulk actions', async () => {
  const originalFetch = globalThis.fetch
  const requests: Array<{ path: string; method: string; idempotency: string | null }> = []
  globalThis.fetch = async (input, init) => {
    const path = new URL(String(input)).pathname
    const method = init?.method ?? 'GET'
    requests.push({ path, method, idempotency: new Headers(init?.headers).get('Idempotency-Key') })
    if (path.endsWith('/download') || (path.endsWith('/export') && method === 'GET')) return new Response('name\nAcme\n', { headers: { 'content-type': 'text/csv' } })
    if (path.endsWith('/preview')) return new Response(JSON.stringify({ object_key: 'customer', rows: [], valid_rows: 0, invalid_rows: 0, duplicate_rows: 0, can_apply: true }), { headers: { 'content-type': 'application/json' } })
    if (path.endsWith('/apply')) return new Response(JSON.stringify({ object_key: 'customer', created: 1, skipped: 0, preview: { object_key: 'customer', rows: [], valid_rows: 1, invalid_rows: 0, duplicate_rows: 0, can_apply: true } }), { headers: { 'content-type': 'application/json' } })
    if (path.endsWith('/bulk')) return new Response(JSON.stringify({ action_key: 'activate', object_key: 'customer', total: 1, succeeded: 1, failed: 0, message: 'ok', items: [] }), { headers: { 'content-type': 'application/json' } })
    return new Response(JSON.stringify({ id: 'job-1', workspace_id: 'workspace-1', kind: 'import', object_key: 'customer', status: 'queued', checkpoint: 0, total: 1, attempt_count: 0, actor_id: 'user-1', role_key: 'operator', created_at: 'now', updated_at: 'now' }), { status: path.endsWith('/jobs') ? 202 : 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    await client.previewRecordImport('customer', 'name\nAcme\n')
    await client.applyRecordImport('customer', 'name\nAcme\n', { idempotencyKey: 'apply-1' })
    await client.enqueueRecordImport('customer', 'name\nAcme\n', { idempotencyKey: 'import-1' })
    await client.exportRecords('customer', { fields: ['name'], reason: 'audit' })
    await client.enqueueRecordExport('customer', { idempotencyKey: 'export-1', fields: ['name'] })
    await client.getRecordBatchJob('job-1')
    await client.cancelRecordBatchJob('job-1', { idempotencyKey: 'cancel-1' })
    await client.downloadRecordBatchJob('job-1')
    await client.runBulkAction('customer', 'activate', { record_ids: ['customer-1'] }, { idempotencyKey: 'bulk-1' })
    assert.deepEqual(requests.filter(({ idempotency }) => idempotency).map(({ idempotency }) => idempotency), ['apply-1', 'import-1', 'export-1', 'cancel-1', 'bulk-1'])
    assert.deepEqual(requests.map(({ path }) => path), [
      '/objects/customer/records/import/preview', '/objects/customer/records/import/apply', '/objects/customer/records/import/jobs',
      '/objects/customer/records/export', '/objects/customer/records/export/jobs', '/record-batch-jobs/job-1',
      '/record-batch-jobs/job-1/cancel', '/record-batch-jobs/job-1/download', '/objects/customer/actions/activate/bulk',
    ])
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('notification SSE refetches durable state before publishing the invalidation', async () => {
  const originalFetch = globalThis.fetch
  const order: string[] = []
  globalThis.fetch = async () => new Response('event: notification.sync\nid: cursor-1\ndata: {"cursor":"cursor-1","unread":3}\n\n', { headers: { 'content-type': 'text/event-stream' } })
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    let close = () => {}
    await new Promise<void>((resolve) => {
      close = client.subscribeNotificationSync(() => {
        order.push('signal')
        close()
        resolve()
      }, { refetch: async () => { order.push('refetch') } })
    })
    assert.deepEqual(order, ['refetch', 'signal'])
  } finally {
    globalThis.fetch = originalFetch
  }
})
