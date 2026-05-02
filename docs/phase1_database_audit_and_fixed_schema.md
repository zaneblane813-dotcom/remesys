# PHASE 1 — Database Audit, Fixed Schema, and Migration Plan

## ✅ Explanation
This phase converts the legacy Core PHP schema into a production-grade multi-tenant SaaS-ready relational model for ERP + LMS + Finance.

### 1) Audit Findings (Typical Legacy Issues Addressed)
- Missing tenant isolation (`tenant_id`) in transactional tables.
- Weak key design (no foreign keys, text joins).
- Duplicate course naming and inconsistent durations.
- No canonical course code/slug/NSQF fields.
- No communication/audit queue tables.
- Limited indexing for reporting and due alerts.
- Missing general ledger tables for accounting traceability.

### 2) Normalization Strategy
- **1NF/2NF/3NF**: split master and transaction entities.
- Multi-tenant boundary with `tenants.id` foreign keys.
- Strict foreign keys + cascading where appropriate.
- Add domain enums/checks for status consistency.

### 3) Course Standardization Rules Applied
- Mandatory fields: `course_code`, `slug`, `nsqf_level`.
- NSQF mapping:
  - Basic → 3
  - Intermediate → 4
  - Advanced → 5
  - Advanced Diploma → 6
- Includes explicit programs:
  - COPA (ITI) → NSQF 4
  - Robotic Operator → NSQF 4

### 4) Communication Hub (Central)
Adds:
- `communications`
- `email_logs`
- `notification_queue`

Supports module-level communication for student/fees/exam/certificate/franchise and channel types email/sms/whatsapp.

### 5) Integration-Ready Model
Adds cross-system identity and sync:
- `global_student_uuid` in students
- `integration_endpoints`
- `integration_sync_logs`

Supports `learn.remesys.in`, `learn1.remesys.in`, `crm.remesys.in`, `workshop.remesys.in`, `partner.remesys.in`, `scholarship.remesys.in`, `test.remesys.in`.

---

## ✅ SQL / Code
See migration SQL:
- `database/migrations/20260502_001_phase1_foundation.sql`

---

## ✅ Folder Structure
```
/app
  /controllers
    CommunicationController.php
  /models
    Communication.php
  /views
/core
  App.php
  Controller.php
  Model.php
  Database.php
/config
  config.php
/public
  index.php
  .htaccess
/database/migrations
  20260502_001_phase1_foundation.sql
/docs
  phase1_database_audit_and_fixed_schema.md
```

---

## STOP CONTROL
👉 STOPPED AT: **PHASE 1 (Database audit + fixed schema + migration + communication foundation)**

👉 NEXT: **PHASE 2 (Course catalog cleanup using your full final course list, deduplication script, NSQF enforcement + duration correction)**

👉 TO CONTINUE: **say "continue from PHASE 2"**

## PHASE 2 KICKOFF (Implemented)
- Added canonical `course_catalog` table and idempotent sync into tenant `courses`.
- Added `course_merge_audit` for duplicate merge traceability.
- Added MVC `Course` model + `CourseController` endpoints:
  - `/course/catalog`
  - `/course/sync/{tenantId}`
