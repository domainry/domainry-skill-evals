SELECT
  l.company_name AS company_name,
  l.contact_name AS contact_name,
  l.contact_phone AS contact_phone,
  l.expected_amount AS expected_amount,
  l.source AS source,
  l.status AS status,
  l.owner_user AS owner_user,
  l.owner_department_id AS owner_department_id,
  l.status_changed_at AS status_changed_at
FROM `lead` AS l
ORDER BY l.status_changed_at DESC, l.company_name DESC, l.contact_name DESC
LIMIT 10000
