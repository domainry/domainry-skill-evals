import { RuntimeClient } from '../src/index'

export async function compileLegacyReportAdapter(client: RuntimeClient) {
  const prepared = await client.prepareReportExport('daily_sales', 'sale', 'audit-1', {
    idempotencyKey: 'prepare-1',
    reason: 'legacy adapter compile fixture',
  })
  const file = await client.downloadReportExport(prepared.token)
  const legacy = await client.exportReportObject('accounting_export', 'accounting_journal')
  return {
    token: prepared.token,
    rowCount: prepared.row_count,
    expiresAt: prepared.expires_at,
    filename: file.filename ?? legacy.filename,
  }
}
