# Remesys ERP/LMS SaaS Deployment Guide (cPanel + SSH)

## 1) Package Build
Run from repo root:

```bash
./scripts/package_release.sh
```

This creates `release/remesys-<timestamp>.tar.gz`.

## 2) Upload to Server
Upload package to cPanel home directory (File Manager or SCP).

Example with SCP:

```bash
scp release/remesys-20260502-120000.tar.gz user@server:/home/user/
```

## 3) SSH Deploy

```bash
ssh user@server
mkdir -p /home/user/remesys_app
bash /home/user/remesys_app/scripts/deploy_cpanel_steps.sh /home/user/remesys-20260502-120000.tar.gz /home/user/remesys_app
```

If script path not available yet, run manually:

```bash
cd /home/user/remesys_app
tar -xzf /home/user/remesys-20260502-120000.tar.gz -C /home/user/remesys_app
cp public/.htaccess .htaccess
```

## 4) cPanel Domain/Document Root
Set your domain/subdomain document root to:

- `/home/user/remesys_app/public` (recommended)

If cPanel forces root at app dir, keep `.htaccess` in app root and forward to `public/index.php`.

## 5) Database Setup
1. Create MySQL DB/user in cPanel.
2. Update `config/config.php`:
   - `db.host`
   - `db.port`
   - `db.name`
   - `db.user`
   - `db.pass`

3. Run migrations in order:

```sql
SOURCE database/migrations/20260502_001_phase1_foundation.sql;
SOURCE database/migrations/20260502_002_phase2_course_standardization.sql;
SOURCE database/migrations/20260502_003_phase4_academic_modules.sql;
SOURCE database/migrations/20260502_004_phase5_compliance_integration.sql;
```

## 6) Environment Security
Set API key in shell profile (or cPanel app env if available):

```bash
export REMESYS_API_KEY='replace-with-strong-key'
```

Current app reads it in `config/config.php`.

## 7) Worker Cron Setup
Queue processing worker:

```bash
* * * * * /usr/bin/php /home/user/remesys_app/run_worker.php >> /home/user/remesys_app/storage/worker.log 2>&1
```

## 8) Endpoint Smoke Checks
Use API key header:

```bash
curl -X POST https://yourdomain.com/communication/queue-email \
  -H 'Content-Type: application/json' \
  -H 'X-API-KEY: replace-with-strong-key' \
  -d '{"tenant_id":1,"module":"fees","sender_email":"admin@remesys.in","recipient_email":"student@example.com","subject":"Test","message":"<p>Hello</p>"}'
```

```bash
curl -X POST https://yourdomain.com/communication/process-queue \
  -H 'X-API-KEY: replace-with-strong-key'
```

## 9) Go-Live Checklist
- [ ] DB migrations completed
- [ ] DB credentials updated
- [ ] API key exported
- [ ] Cron worker enabled
- [ ] SMTP delivery verified
- [ ] Write permissions on `storage/`
- [ ] HTTPS active

## 10) Known Current Limits
- SMTP transport currently uses `mail()` fallback in `SmtpMailer`; replace with authenticated SMTP transport for strict production policy.
- PDF generator for invoice/certificate/marksheet still pending.
