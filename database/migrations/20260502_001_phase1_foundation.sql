SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS tenants (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(60) NOT NULL UNIQUE,
  domain VARCHAR(190) NULL,
  status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  role ENUM('super_admin','admin','teacher','accountant','student','parent','franchise_manager') NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  mobile VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  last_login_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_tenant_email (tenant_id, email),
  KEY idx_users_tenant_role (tenant_id, role),
  CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  course_code VARCHAR(40) NOT NULL,
  name VARCHAR(180) NOT NULL,
  slug VARCHAR(200) NOT NULL,
  stream_level ENUM('basic','intermediate','advanced','advanced_diploma','custom') NOT NULL DEFAULT 'custom',
  nsqf_level TINYINT UNSIGNED NOT NULL,
  duration_months SMALLINT UNSIGNED NOT NULL,
  total_hours SMALLINT UNSIGNED NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_courses_tenant_code (tenant_id, course_code),
  UNIQUE KEY uq_courses_tenant_slug (tenant_id, slug),
  KEY idx_courses_tenant_nsqf (tenant_id, nsqf_level),
  CONSTRAINT fk_courses_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT chk_courses_nsqf CHECK (nsqf_level BETWEEN 1 AND 10)
) ENGINE=InnoDB;

INSERT INTO courses (tenant_id, course_code, name, slug, stream_level, nsqf_level, duration_months, total_hours)
VALUES
(1,'ITI-COPA','COPA (ITI)','copa-iti','intermediate',4,12,1200),
(1,'ROBO-OP','Robotic Operator','robotic-operator','intermediate',4,6,480)
ON DUPLICATE KEY UPDATE name=VALUES(name);

CREATE TABLE IF NOT EXISTS students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  global_student_uuid CHAR(36) NOT NULL,
  admission_no VARCHAR(50) NOT NULL,
  full_name VARCHAR(160) NOT NULL,
  dob DATE NULL,
  gender ENUM('male','female','other') NULL,
  guardian_name VARCHAR(160) NULL,
  guardian_mobile VARCHAR(20) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_students_uuid (global_student_uuid),
  UNIQUE KEY uq_students_tenant_adm (tenant_id, admission_no),
  KEY idx_students_tenant_name (tenant_id, full_name),
  CONSTRAINT fk_students_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS batches (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  trainer_user_id BIGINT UNSIGNED NULL,
  capacity SMALLINT UNSIGNED NULL,
  status ENUM('planned','running','completed','cancelled') DEFAULT 'planned',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_batches_tenant_course (tenant_id, course_id),
  CONSTRAINT fk_batches_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_batches_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_batches_trainer FOREIGN KEY (trainer_user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_invoices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  invoice_no VARCHAR(60) NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  gst_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
  gst_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL,
  due_date DATE NOT NULL,
  status ENUM('draft','issued','partial','paid','overdue','cancelled') NOT NULL DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fee_invoice_no (tenant_id, invoice_no),
  KEY idx_fee_invoice_due (tenant_id, due_date, status),
  CONSTRAINT fk_fee_invoices_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_fee_invoices_student FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  invoice_id BIGINT UNSIGNED NOT NULL,
  receipt_no VARCHAR(60) NOT NULL,
  installment_no SMALLINT UNSIGNED NOT NULL,
  payment_date DATE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  mode ENUM('cash','upi','bank','online') NOT NULL,
  reference_no VARCHAR(120) NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fee_receipt (tenant_id, receipt_no),
  KEY idx_fee_payments_invoice (invoice_id, payment_date),
  CONSTRAINT fk_fee_payments_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_fee_payments_invoice FOREIGN KEY (invoice_id) REFERENCES fee_invoices(id),
  CONSTRAINT fk_fee_payments_created_by FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS communications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  module VARCHAR(60) NOT NULL,
  type ENUM('email','sms','whatsapp') NOT NULL,
  subject VARCHAR(255) NULL,
  message TEXT NOT NULL,
  attachment_path VARCHAR(255) NULL,
  status ENUM('queued','processing','sent','failed') NOT NULL DEFAULT 'queued',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_comm_queue (tenant_id, status, type),
  KEY idx_comm_module (tenant_id, module),
  CONSTRAINT fk_comm_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_comm_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS email_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  communication_id BIGINT UNSIGNED NULL,
  sender_email VARCHAR(190) NOT NULL,
  recipient_email VARCHAR(190) NOT NULL,
  subject VARCHAR(255) NULL,
  body MEDIUMTEXT NOT NULL,
  smtp_host VARCHAR(190) NOT NULL DEFAULT 'mail.remesys.in',
  smtp_port SMALLINT UNSIGNED NOT NULL DEFAULT 465,
  encryption ENUM('ssl','tls') NOT NULL DEFAULT 'ssl',
  status ENUM('sent','failed') NOT NULL,
  error_message TEXT NULL,
  sent_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_email_logs_status (tenant_id, status, created_at),
  CONSTRAINT fk_email_logs_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_email_logs_comm FOREIGN KEY (communication_id) REFERENCES communications(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notification_queue (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  communication_id BIGINT UNSIGNED NOT NULL,
  channel ENUM('email','sms','whatsapp') NOT NULL,
  payload JSON NOT NULL,
  retry_count SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  max_retry SMALLINT UNSIGNED NOT NULL DEFAULT 5,
  next_attempt_at DATETIME NULL,
  status ENUM('queued','processing','sent','failed','dead_letter') NOT NULL DEFAULT 'queued',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_notif_dispatch (tenant_id, status, next_attempt_at),
  CONSTRAINT fk_notif_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_notif_comm FOREIGN KEY (communication_id) REFERENCES communications(id)
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;
