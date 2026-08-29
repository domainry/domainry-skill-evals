import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient, type RuntimeReportExportScope } from '../src/index.ts'

test('prepareReportExport accepts an asynchronous governed job above the server threshold', async () => {
  const originalFetch = globalThis.fetch
  let requestBody: Record<string, unknown> | undefined
  globalThis.fetch = async (_input, init) => {
    requestBody = JSON.parse(String(init?.body)) as Record<string, unknown>
    return new Response(JSON.stringify({
      id: 'job-1', batch_job_id: 'job-1', audit_id: 'audit-1', report_key: 'orders', object_key: 'order',
      status: 'accepted', pages_completed: 0, rows_exported: 0, total: 1001, created_at: '2026-08-10T10:00:00Z', updated_at: '2026-08-10T10:00:00Z',
    }), { status: 202, headers: { 'content-type': 'application/json', location: '/report-exports/job-1' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    const scope: RuntimeReportExportScope = {
      query_key: 'current', tags: ['high_value', 'reviewed'],
      analysis_key: 'lead_time',
      filters: [{ dimension_key: 'status', operator: 'in', values: ['paid', 'fulfilled'] }],
      date_range: { dimension_key: 'day', from: '2026-08-01', to: '2026-08-10' }, timezone: 'Asia/Shanghai',
      tags: ['priority', 'reviewed'], tag_match: 'all',
      field_projection: ['status', 'orders'], purpose: 'month close evidence',
      metric_definitions: [{ key: 'orders', version: `sha256:${'b'.repeat(64)}` }], freshness: { mode: 'realtime' },
      role_key: 'finance', data_scopes: { order: 'department' },
    }
    const result = await client.prepareReportExportRouted('orders', 'order', 'audit-1', { idempotencyKey: 'prepare-1', reason: 'month close', scope })
    assert.deepEqual(requestBody, { audit_id: 'audit-1', scope })
    assert.equal(result.status, 'accepted')
    assert.equal(result.batch_job_id, 'job-1')
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('prepareReportExport returns the governed synchronous artifact through 1000 rows', async () => {
  const originalFetch = globalThis.fetch
  globalThis.fetch = async () => new Response('id\n1\n', {
    status: 200,
    headers: {
      'content-type': 'text/csv',
      'content-disposition': 'attachment; filename="orders.csv"',
      'x-report-export-artifact-id': 'download-1',
      'x-content-sha256': 'abc123',
      'x-report-export-download-token': 'token-1',
      'x-report-export-row-count': '1',
      'x-report-export-expires-at': '2026-08-17T00:00:00Z',
    },
  })
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    const result = await client.prepareReportExportRouted('orders', 'order', 'audit-1', { idempotencyKey: 'prepare-1', reason: 'small export' })
    assert.ok('blob' in result)
    if ('blob' in result) {
      assert.equal(await result.blob.text(), 'id\n1\n')
      assert.equal(result.filename, 'orders.csv')
      assert.equal(result.artifact_id, 'download-1')
      assert.equal(result.content_sha256, 'abc123')
    }
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('getReportSummary serializes the same allowlisted query and repeated tag selectors as export scope', async () => {
  const originalFetch = globalThis.fetch
  let requestURL = ''
  globalThis.fetch = async (input) => {
    requestURL = String(input)
    return new Response(JSON.stringify({
      key: 'orders', rows: [], row_count: 0, source_row_count: 0, execution_mode: 'realtime',
      page_size: 125, next_cursor: 'next', truncated: true, total: 126, total_semantics: 'at_least',
    }), { status: 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    const result = await client.getReportSummary('orders', { mode: 'realtime', queryKey: ' current ', tags: [' reviewed ', 'high_value'], pageSize: 125, cursor: ' opaque ' })
    const url = new URL(requestURL)
    assert.equal(url.searchParams.get('query_key'), 'current')
    assert.deepEqual(url.searchParams.getAll('tags'), ['reviewed', 'high_value'])
    assert.equal(url.searchParams.get('page_size'), '125')
    assert.equal(url.searchParams.get('cursor'), 'opaque')
    assert.equal(result.total_semantics, 'at_least')
    assert.equal(result.truncated, true)
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('queryReportObjectSQL posts only typed parameters and returns the formal result schema', async () => {
  const originalFetch = globalThis.fetch
  let requestURL = ''
  let requestBody: unknown
  globalThis.fetch = async (input, init) => {
    requestURL = String(input)
    requestBody = JSON.parse(String(init?.body))
    return new Response(JSON.stringify({
      key: 'sales.sql', rows: [{ dimensions: { status: 'paid' }, measures: { revenue: '12.50' } }],
      row_count: 1, source_row_count: -1, execution_mode: 'object_sql_v1',
      result_schema: [{ key: 'status', type: 'text', kind: 'dimension' }, { key: 'revenue', type: 'currency', kind: 'measure', precision: 19, scale: 2 }],
    }), { status: 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    const result = await client.queryReportObjectSQL('sales.sql', { from: '2026-08-01T00:00:00+08:00', minimum: '12.50', active: true }, { pageSize: 50, cursor: 'next' })
    assert.equal(new URL(requestURL).pathname, '/reports/sales.sql/query')
    assert.deepEqual(requestBody, { parameters: { from: '2026-08-01T00:00:00+08:00', minimum: '12.50', active: true }, page_size: 50, cursor: 'next' })
    assert.equal(result.execution_mode, 'object_sql_v1')
    assert.equal(result.result_schema?.[1]?.scale, 2)
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('report export status and cancellation stay on Report-owned requester routes', async () => {
  const originalFetch = globalThis.fetch
  const calls: Array<{ url: string; method: string }> = []
  globalThis.fetch = async (input, init) => {
    calls.push({ url: String(input), method: init?.method ?? 'GET' })
    return new Response(JSON.stringify({ id: 'job-1', batch_job_id: 'job-1', audit_id: 'audit-1', report_key: 'orders', object_key: 'order', status: 'cancelled', pages_completed: 1, rows_exported: 200, total: 500, created_at: '', updated_at: '' }), { status: 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    await client.getReportExportJob('job-1')
    await client.cancelReportExport('job-1', { idempotencyKey: 'cancel-1' })
    assert.deepEqual(calls.map(({ url, method }) => [new URL(url).pathname, method]), [['/report-exports/job-1', 'GET'], ['/report-exports/job-1/cancel', 'POST']])
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('prepareReportExportRouted maps callers to an explicit realtime purpose scope', async () => {
  const originalFetch = globalThis.fetch
  let requestBody: Record<string, unknown> | undefined
  globalThis.fetch = async (_input, init) => {
    requestBody = JSON.parse(String(init?.body)) as Record<string, unknown>
    return new Response(JSON.stringify({}), { status: 201, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    await client.prepareReportExportRouted('orders', 'order', 'audit-1', { idempotencyKey: 'prepare-1', reason: 'Legacy export' })
    assert.deepEqual(requestBody, { audit_id: 'audit-1', scope: { purpose: 'Legacy export', freshness: { mode: 'realtime' } } })
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('legacy prepareReportExport returns governed metadata and replays the already prepared 200 file', async () => {
  const originalFetch = globalThis.fetch
  let calls = 0
  globalThis.fetch = async () => {
    calls += 1
    return new Response('id\n1\n', { status: 200, headers: {
      'content-type': 'text/csv', 'content-disposition': 'attachment; filename="orders.csv"',
      'x-report-export-artifact-id': 'download-1', 'x-content-sha256': 'abc123',
      'x-report-export-download-token': 'token-1', 'x-report-export-row-count': '1',
      'x-report-export-expires-at': '2026-08-17T00:00:00Z',
    } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    const prepared = await client.prepareReportExport('orders', 'order', 'audit-1', { idempotencyKey: 'prepare-1', reason: 'legacy export' })
    assert.equal(prepared.token, 'token-1')
    assert.equal(prepared.row_count, 1)
    const file = await client.downloadReportExport(prepared.token)
    assert.equal(await file.blob.text(), 'id\n1\n')
    assert.equal(calls, 1)
  } finally {
    globalThis.fetch = originalFetch
  }
})
