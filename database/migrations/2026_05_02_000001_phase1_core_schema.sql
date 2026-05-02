-- PHASE 1: Database Audit + Fixed Production Schema (MySQL 8+)
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS tenants (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_uuid CHAR(36) NOT NULL UNIQUE,
  tenant_code VARCHAR(40) NOT NULL UNIQUE,
  legal_name VARCHAR(190) NOT NULL,
  brand_name VARCHAR(190) NOT NULL,
  domain VARCHAR(190) NULL,
  timezone VARCHAR(60) NOT NULL DEFAULT 'Asia/Kolkata',
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status ENUM('active','inactive','suspended') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_tenant_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  role ENUM('super_admin','admin','accountant','teacher','parent','student','franchise_manager') NOT NULL,
  full_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) NOT NULL,
  phone VARCHAR(20) NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  last_login_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_tenant_email (tenant_id, email),
  KEY idx_user_tenant_role (tenant_id, role),
  CONSTRAINT fk_users_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS courses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  course_code VARCHAR(40) NOT NULL,
  title VARCHAR(220) NOT NULL,
  slug VARCHAR(240) NOT NULL,
  duration_months SMALLINT UNSIGNED NOT NULL,
  level_type ENUM('basic','intermediate','advanced','advanced_diploma') NOT NULL,
  nsqf_level TINYINT UNSIGNED NOT NULL,
  is_iti TINYINT(1) NOT NULL DEFAULT 0,
  description TEXT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_tenant_course_code (tenant_id, course_code),
  UNIQUE KEY uk_tenant_course_slug (tenant_id, slug),
  KEY idx_course_nsqf (tenant_id, nsqf_level),
  KEY idx_course_level_type (tenant_id, level_type),
  CONSTRAINT fk_courses_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_nsqf CHECK (nsqf_level BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS students (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  student_uuid CHAR(36) NOT NULL,
  common_student_id VARCHAR(40) NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  full_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(20) NULL,
  dob DATE NULL,
  gender ENUM('male','female','other') NULL,
  status ENUM('lead','active','alumni','dropout') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_student_uuid (student_uuid),
  UNIQUE KEY uk_tenant_common_student (tenant_id, common_student_id),
  KEY idx_student_tenant_status (tenant_id, status),
  CONSTRAINT fk_students_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS student_enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  batch_code VARCHAR(60) NULL,
  enrollment_date DATE NOT NULL,
  expected_end_date DATE NULL,
  final_grade VARCHAR(10) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_student_course_once (tenant_id, student_id, course_id),
  KEY idx_enrollment_course (tenant_id, course_id),
  CONSTRAINT fk_enr_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_enr_course FOREIGN KEY (course_id) REFERENCES courses(id)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS communications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  student_id BIGINT UNSIGNED NULL,
  module VARCHAR(60) NOT NULL,
  type ENUM('email','sms','whatsapp') NOT NULL,
  subject VARCHAR(220) NULL,
  message MEDIUMTEXT NOT NULL,
  attachment_path VARCHAR(255) NULL,
  provider_ref VARCHAR(120) NULL,
  status ENUM('queued','processing','sent','failed','cancelled') NOT NULL DEFAULT 'queued',
  scheduled_at DATETIME NULL,
  sent_at DATETIME NULL,
  failed_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_comm_tenant_status (tenant_id, status),
  KEY idx_comm_module_type (tenant_id, module, type),
  CONSTRAINT fk_comm_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_comm_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_comm_student FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS email_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  communication_id BIGINT UNSIGNED NULL,
  sender_email VARCHAR(190) NOT NULL,
  recipient_email VARCHAR(190) NOT NULL,
  cc_emails VARCHAR(600) NULL,
  bcc_emails VARCHAR(600) NULL,
  subject VARCHAR(220) NOT NULL,
  body_html MEDIUMTEXT NOT NULL,
  attachment_path VARCHAR(255) NULL,
  smtp_host VARCHAR(120) NOT NULL,
  smtp_port SMALLINT UNSIGNED NOT NULL,
  smtp_encryption ENUM('ssl','tls') NOT NULL DEFAULT 'ssl',
  status ENUM('sent','failed') NOT NULL,
  error_message TEXT NULL,
  attempt_no SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  sent_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_email_tenant_status (tenant_id, status),
  KEY idx_email_recipient (recipient_email),
  CONSTRAINT fk_email_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_email_comm FOREIGN KEY (communication_id) REFERENCES communications(id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notification_queue (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  communication_id BIGINT UNSIGNED NOT NULL,
  channel ENUM('email','sms','whatsapp') NOT NULL,
  payload JSON NOT NULL,
  priority TINYINT UNSIGNED NOT NULL DEFAULT 5,
  next_retry_at DATETIME NULL,
  retry_count TINYINT UNSIGNED NOT NULL DEFAULT 0,
  max_retries TINYINT UNSIGNED NOT NULL DEFAULT 5,
  status ENUM('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_queue_status_retry (status, next_retry_at),
  KEY idx_queue_tenant_channel (tenant_id, channel),
  CONSTRAINT fk_queue_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_queue_comm FOREIGN KEY (communication_id) REFERENCES communications(id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
