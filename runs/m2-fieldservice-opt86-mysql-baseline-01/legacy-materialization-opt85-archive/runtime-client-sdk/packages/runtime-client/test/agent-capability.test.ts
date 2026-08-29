import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient } from '../src/index.ts'

test('runAgent binds workspace, Surface, idempotency and trusted context', async () => {
  const originalFetch = globalThis.fetch
  let requestURL = ''
  let requestHeaders: Headers | undefined
  let requestBody: unknown
  globalThis.fetch = async (input, init) => {
    requestURL = String(input)
    requestHeaders = new Headers(init?.headers)
    requestBody = JSON.parse(String(init?.body))
    return new Response(JSON.stringify({
      run: { id: 'interactive_run_1', workspace_id: 'workspace-1', session_id: 'session-1', user_id: 'operator', role_key: 'operator', agent_key: 'customer_agent', entrypoint_key: 'assistant.customer', context_revision: 'context-1', context: {}, authorization: {}, surface: 'business_workspace', route_key: 'business.customers.detail', status: 'completed', tool_call_count: 0, idempotency_key: 'agent-1', revision: 2, created_at: '2026-08-15T00:00:00Z', updated_at: '2026-08-15T00:00:01Z' },
      result: { structured: { summary: 'ok' } },
    }), { status: 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    const result = await client.runAgent({ message: 'summarize', context: { entrypoint_key: 'assistant.customer', route_key: 'business.customers.detail', object_key: 'customer', record_id: 'customer-1' } }, { idempotencyKey: 'agent-1' })
    assert.equal(new URL(requestURL).pathname, '/agent-dialog/runs')
    assert.equal(requestHeaders?.get('Idempotency-Key'), 'agent-1')
    assert.equal(requestHeaders?.get('X-Workspace-ID'), 'workspace-1')
    assert.equal(requestHeaders?.get('X-Domainry-Product-Surface'), 'business_workspace')
    assert.deepEqual(requestBody, { message: 'summarize', context: { entrypoint_key: 'assistant.customer', route_key: 'business.customers.detail', object_key: 'customer', record_id: 'customer-1' } })
    assert.equal(result.run.status, 'completed')
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('Agent convenience methods use only Business routes and unwrap scoped lists', async () => {
  const originalFetch = globalThis.fetch
  const paths: string[] = []
  globalThis.fetch = async (input) => {
    const path = new URL(String(input)).pathname
    paths.push(path)
    if (path.endsWith('/sessions')) return new Response(JSON.stringify({ sessions: [{ external_session_id: 'session-1', title: 'Review', archived: false, created_at: 1, updated_at: 1 }] }), { status: 200, headers: { 'content-type': 'application/json' } })
    if (path.endsWith('/proposals')) return new Response(JSON.stringify({ proposals: [{ proposal_id: 'proposal-1', status: 'draft', created_at: 1, updated_at: 1, audited: true }] }), { status: 200, headers: { 'content-type': 'application/json' } })
    return new Response(JSON.stringify({ id: 'task-1', task_key: 'customer.summarize', task_version: '1.0.0', status: 'succeeded', reconciliation_required: false, identity: { mode: 'inherit', execution_user_id: 'operator', execution_role_key: 'operator' }, attempt: 1, max_attempts: 3, revision: 2, created_at: '2026-08-15T00:00:00Z', updated_at: '2026-08-15T00:00:01Z' }), { status: 200, headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    assert.equal((await client.listAgentSessions()).length, 1)
    assert.equal((await client.listAgentProposals()).length, 1)
    assert.equal((await client.getAgentTaskRun('task-1')).status, 'succeeded')
    assert.deepEqual(paths, ['/agent-dialog/sessions', '/agent-dialog/proposals', '/agent-dialog/task-runs/task-1'])
    assert.equal(paths.some((path) => path.startsWith('/operations/agent/')), false)
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('Agent stream, governed analysis, and report handoff use typed Business contracts', async () => {
  const originalFetch = globalThis.fetch
  const requests: Array<{ path: string; method: string; accept: string | null; idempotency: string | null; lastEventID: string | null }> = []
  globalThis.fetch = async (input, init) => {
    const path = new URL(String(input)).pathname
    const headers = new Headers(init?.headers)
    requests.push({ path, method: init?.method ?? 'GET', accept: headers.get('Accept'), idempotency: headers.get('Idempotency-Key'), lastEventID: headers.get('Last-Event-ID') })
    if (path.endsWith('/runs/stream')) {
      return new Response([
        'id: agent-test:1', 'event: accepted', 'data: {"status":"running"}', '',
        'id: agent-test:2', 'event: result', 'data: {"run":{"id":"run-1","status":"completed"},"result":{"summary":"ok"}}', '', '',
      ].join('\n'), { status: 200, headers: { 'content-type': 'text/event-stream' } })
    }
    if (path.endsWith('/analysis/query')) {
      return new Response(JSON.stringify({ query_ref: 'query-1', status: 'completed', execution_mode: 'dry_run', scope_note: 'principal', workspace_id: 'workspace-1', role: 'operator', truncated: false, audit_event_key: 'audit-1' }), { headers: { 'content-type': 'application/json' } })
    }
    return new Response(JSON.stringify(path.endsWith('/prepare')
      ? { query_ref: 'query-1', status: 'prepared_for_report_center', handoff: 'report_center_export_download', report_query_run: {}, report_export_audit: {}, download_task: {}, scope: 'server_principal_scoped', next_step: 'export' }
      : { query_ref: 'query-1', status: 'completed', created_at: 1 }), { headers: { 'content-type': 'application/json' } })
  }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    const accepted: string[] = []
    const streamed = await client.runAgentStream({ message: 'summarize', context: { entrypoint_key: 'assistant.customer', route_key: 'business.customers' } }, { idempotencyKey: 'stream-1', onAccepted: (value) => accepted.push(String(value.status)) })
    assert.equal(streamed.result.summary, 'ok')
    assert.deepEqual(accepted, ['running'])
    assert.equal((await client.queryAgentAnalysis({ intent: 'customers', dry_run: true })).query_ref, 'query-1')
    await client.getAgentReportQueryRun('query-1')
    await client.getAgentReportExportAudit('query-1')
    await client.getAgentReportDownloadTask('query-1')
    assert.equal((await client.prepareAgentReportHandoff('query-1')).status, 'prepared_for_report_center')
    assert.deepEqual(requests.map(({ path }) => path), [
      '/agent-dialog/runs/stream', '/agent-dialog/analysis/query', '/agent-dialog/report-query-runs/query-1',
      '/agent-dialog/report-export-audits/query-1', '/agent-dialog/download-tasks/query-1', '/agent-dialog/download-tasks/query-1/prepare',
    ])
    assert.equal(requests[0].accept, 'text/event-stream')
    assert.equal(requests[0].idempotency, 'stream-1')
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('Agent stream reconnects with Last-Event-ID and does not duplicate accepted', async () => {
  const originalFetch = globalThis.fetch
  const cursors: Array<string | null> = []
  let calls = 0
  globalThis.fetch = async (_input, init) => {
    calls += 1
    const headers = new Headers(init?.headers)
    cursors.push(headers.get('Last-Event-ID'))
    if (calls === 1) {
      return new Response(['id: agent-resume:1', 'event: accepted', 'data: {"status":"running"}', '', ''].join('\n'), { status: 200, headers: { 'content-type': 'text/event-stream' } })
    }
    return new Response(['id: agent-resume:2', 'event: result', 'data: {"run":{"id":"run-1","status":"completed"},"result":{"summary":"resumed"}}', '', ''].join('\n'), { status: 200, headers: { 'content-type': 'text/event-stream' } })
  }
  try {
    const accepted: string[] = []
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace' })
    const result = await client.runAgentStream({ message: 'resume' }, { idempotencyKey: 'resume-1', reconnectDelayMs: 0, onAccepted: (value) => accepted.push(String(value.status)) })
    assert.equal(result.result.summary, 'resumed')
    assert.deepEqual(accepted, ['running'])
    assert.deepEqual(cursors, [null, 'agent-resume:1'])
  } finally {
    globalThis.fetch = originalFetch
  }
})
