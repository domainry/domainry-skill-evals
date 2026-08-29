import assert from 'node:assert/strict'
import test from 'node:test'

import { RuntimeClient, type RuntimeWorkforceApplicationItem } from '../src/index.ts'

test('Workforce application projection exposes typed effective role summaries', async () => {
  const originalFetch = globalThis.fetch
  const expected: RuntimeWorkforceApplicationItem = {
    profile: {
      id: 'worker', organization_id: 'org', identity_user_id: 'user', worker_no: 'E-1',
      worker_type: 'employee', work_status: 'active', version: 1,
    },
    display_name: 'Sales Manager',
    roles: [{ id: 'role-sales-manager', key: 'sales_manager', label: 'Sales Manager' }],
  }
  globalThis.fetch = async () => new Response(JSON.stringify({
    items: [expected], page: 1, page_size: 1, total: 1, has_next: false,
  }), { status: 200, headers: { 'content-type': 'application/json' } })

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1',
      surface: 'business_workspace', getAccessToken: () => 'token',
    })
    const page = await client.listWorkforce()
    assert.deepEqual(page.items[0].roles, expected.roles)
  } finally {
    globalThis.fetch = originalFetch
  }
})

test('Foundation reads use formal Runtime contracts and keep Surface as request context', async () => {
  const requests: Array<{ url: string; surface: string | null }> = []
  const originalFetch = globalThis.fetch
  globalThis.fetch = async (input, init) => {
    const headers = new Headers(init?.headers)
    requests.push({ url: String(input), surface: headers.get('X-Domainry-Product-Surface') })
    const payload = String(input).includes('/identity/departments')
      ? []
      : { items: [], total: 0 }
    return new Response(JSON.stringify(payload), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    })
  }

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'https://runtime.example.test',
      workspaceId: 'workspace-1',
      surface: 'business_workspace',
      getAccessToken: () => 'token',
    })
    await client.listWorkforce()
    await client.listDepartments()
    await client.listJobs()
    await client.listPositions()
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.deepEqual(requests, [
    { url: 'https://runtime.example.test/identity/workforce?projection=application', surface: 'business_workspace' },
    { url: 'https://runtime.example.test/identity/departments', surface: 'business_workspace' },
    { url: 'https://runtime.example.test/foundation/jobs', surface: 'business_workspace' },
    { url: 'https://runtime.example.test/foundation/positions', surface: 'business_workspace' },
  ])
})

test('Authentication requests do not carry Surface context', async () => {
  const requests: Array<{ url: string; surface: string | null }> = []
  const originalFetch = globalThis.fetch
  globalThis.fetch = async (input, init) => {
    const headers = new Headers(init?.headers)
    requests.push({ url: String(input), surface: headers.get('X-Domainry-Product-Surface') })
    return new Response(JSON.stringify({ access_token: 'access', refresh_token: 'refresh' }), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    })
  }

  try {
    const client = new RuntimeClient({
      apiBaseUrl: 'https://runtime.example.test',
      workspaceId: 'workspace-1',
      surface: 'business_workspace',
      getAccessToken: () => 'token',
    })
    await client.login('admin', '123456')
    await client.refresh('refresh')
    await client.me()
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.deepEqual(requests, [
    { url: 'https://runtime.example.test/auth/login', surface: null },
    { url: 'https://runtime.example.test/auth/refresh', surface: null },
    { url: 'https://runtime.example.test/auth/me', surface: null },
  ])
})

test('Foundation authoring methods use published routes and carry governed authoring identity', async () => {
  const requests: Array<{ url: string; method: string; idempotency: string | null; expected: string | null }> = []
  const originalFetch = globalThis.fetch
  globalThis.fetch = async (input, init) => {
    const headers = new Headers(init?.headers)
    const rawIdempotency = headers.get('Idempotency-Key')
    requests.push({
      url: String(input), method: init?.method ?? 'GET',
      idempotency: rawIdempotency?.startsWith('web_') ? '<generated>' : rawIdempotency,
      expected: headers.get('Expected-Schema-Hash'),
    })
    return new Response(JSON.stringify({}), {
      status: 200,
      headers: { 'content-type': 'application/json', 'X-Resource-Hash': 'resource-hash' },
    })
  }

  const department = { id: 'sales', name: 'Sales', path: '/sales', ancestor_ids: [], depth: 0, sort_order: 0 }
  const profile = { id: 'worker', organization_id: 'org', identity_user_id: 'user', worker_no: 'E-1', worker_type: 'employee' as const, work_status: 'active' as const, version: 1 }
  const assignment = { id: 'assignment', workforce_profile_id: 'worker', organization_unit_id: 'sales', assignment_type: 'primary' as const, status: 'active' as const, version: 1 }
  try {
    const client = new RuntimeClient({ apiBaseUrl: 'https://runtime.example.test', workspaceId: 'workspace-1', surface: 'business_workspace', getAccessToken: () => 'token' })
    await client.listWorkforce({ page: 2, pageSize: 25, search: 'Alice', departmentId: 'sales', workStatus: 'active' })
    await client.searchWorkforce({ search: 'Alice' })
    await client.getWorkforceProfile('worker')
    await client.createDepartment(department, 'department-create')
    await client.updateDepartment('sales', department)
    await client.validateDepartment('sales', department)
    await client.listDepartmentVersions('sales')
    await client.createWorkforceProfile(profile, 'workforce-create')
    await client.updateWorkforceProfile('worker', profile)
    await client.validateWorkforceProfile('worker', profile)
    await client.onboardWorkforce({
      user: { id: 'user', name: 'Alice', email: 'alice@example.test', status: 'active', version: 1, created_at: '', updated_at: '' },
      profile,
      assignment,
    }, 'workforce-onboard')
    await client.applyWorkforceLifecycle('worker', { operation: 'transfer', profile, assignment }, 'workforce-lifecycle')
    await client.listWorkforceAssignments('worker')
    await client.upsertWorkforceAssignment('worker', assignment, 'assignment-upsert')
    await client.validateWorkforceAssignment('worker', assignment)
    await client.transferWorkforce([{ profile_id: 'worker', previous_assignment_id: 'assignment', assignment, effective_at: '2026-08-01' }], 'workforce-transfer')
    await client.terminateWorkforce('worker', { effective_at: '2026-08-02', reason: 'left' }, { idempotencyKey: 'workforce-terminate' })
    await client.rehireWorkforce('worker', { effective_at: '2026-08-03', assignment, reason: 'returned' }, { idempotencyKey: 'workforce-rehire' })
    await client.listAssignableWorkforceRoles('worker')
    await client.upsertJob('engineer', { id: 'engineer', code: 'ENG', name: 'Engineer', status: 'active' })
    await client.upsertPosition('lead', { id: 'lead', code: 'LEAD', name: 'Lead', job_catalog_item_id: 'engineer', headcount: 1, status: 'active' })
    await client.listEffectiveMenus()
  } finally {
    globalThis.fetch = originalFetch
  }

  assert.deepEqual(requests, [
    { url: 'https://runtime.example.test/identity/workforce?projection=application&page=2&page_size=25&search=Alice&department_id=sales&work_status=active', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/search?search=Alice', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/departments', method: 'POST', idempotency: 'department-create', expected: 'empty' },
    { url: 'https://runtime.example.test/identity/departments/sales', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/departments/sales', method: 'PATCH', idempotency: '<generated>', expected: 'resource-hash' },
    { url: 'https://runtime.example.test/identity/departments/sales/validate', method: 'POST', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/departments/sales/versions', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce', method: 'POST', idempotency: 'workforce-create', expected: 'empty' },
    { url: 'https://runtime.example.test/identity/workforce/worker', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker', method: 'PATCH', idempotency: '<generated>', expected: 'resource-hash' },
    { url: 'https://runtime.example.test/identity/workforce/worker/validate', method: 'POST', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/onboard', method: 'POST', idempotency: 'workforce-onboard', expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/lifecycle', method: 'POST', idempotency: 'workforce-lifecycle', expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/assignments', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/assignments', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/assignments', method: 'POST', idempotency: 'assignment-upsert', expected: 'resource-hash' },
    { url: 'https://runtime.example.test/identity/workforce/worker/assignments/validate', method: 'POST', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/workforce/transfers/batch', method: 'POST', idempotency: 'workforce-transfer', expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/terminate', method: 'POST', idempotency: 'workforce-terminate', expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/rehire', method: 'POST', idempotency: 'workforce-rehire', expected: null },
    { url: 'https://runtime.example.test/identity/workforce/worker/assignable-roles', method: 'GET', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/foundation/jobs/engineer', method: 'PUT', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/foundation/positions/lead', method: 'PUT', idempotency: null, expected: null },
    { url: 'https://runtime.example.test/identity/effective-menus?surface=business_workspace', method: 'GET', idempotency: null, expected: null },
  ])
})
