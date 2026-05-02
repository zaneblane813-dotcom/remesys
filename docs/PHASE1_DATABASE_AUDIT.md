# PHASE 1 - Database Audit & Fixed Schema

## Scope Done
- Multi-tenant baseline tables added.
- Course schema normalized with `course_code`, `slug`, `nsqf_level`.
- Communication hub tables added: `communications`, `email_logs`, `notification_queue`.
- Core indexing and foreign keys added for production-grade query paths.

## Legacy Audit Checklist (execute on existing DB before migration)
1. Identify duplicate course names with case-insensitive compare.
2. Validate orphan enrollment records.
3. Detect null emails for active users.
4. Validate student IDs uniqueness across tenant.

## Migration Order
1. `2026_05_02_000001_phase1_core_schema.sql`
2. `2026_05_02_000002_phase1_courses_seed.sql`

## Integration Readiness
- `common_student_id` created for cross-system sync.
- Use API gateway/SSO service in next phase for `learn.remesys.in`, `crm.remesys.in`, etc.
