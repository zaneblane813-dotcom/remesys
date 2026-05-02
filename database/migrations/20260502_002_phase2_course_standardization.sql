SET NAMES utf8mb4;

-- Ensure base tenant exists for seed data usage
INSERT INTO tenants (id, name, code, status)
VALUES (1, 'Remesys Default Tenant', 'REMESYS', 'active')
ON DUPLICATE KEY UPDATE name = VALUES(name), status = VALUES(status);

CREATE TABLE IF NOT EXISTS course_catalog (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  course_code VARCHAR(40) NOT NULL UNIQUE,
  name VARCHAR(180) NOT NULL,
  slug VARCHAR(200) NOT NULL UNIQUE,
  category VARCHAR(80) NOT NULL,
  stream_level ENUM('basic','intermediate','advanced','advanced_diploma') NOT NULL,
  nsqf_level TINYINT UNSIGNED NOT NULL,
  duration_months SMALLINT UNSIGNED NOT NULL,
  total_hours SMALLINT UNSIGNED NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_catalog_nsqf CHECK (nsqf_level BETWEEN 1 AND 10)
) ENGINE=InnoDB;

INSERT INTO course_catalog (course_code, name, slug, category, stream_level, nsqf_level, duration_months, total_hours) VALUES
('BAS-COM-001','Computer Fundamentals','computer-fundamentals','IT','basic',3,3,180),
('INT-COPA-001','COPA (ITI)','copa-iti','ITI','intermediate',4,12,1200),
('INT-ROB-001','Robotic Operator','robotic-operator','Automation','intermediate',4,6,480),
('ADV-WEB-001','Advanced Web Development','advanced-web-development','IT','advanced',5,6,420),
('ADIP-DS-001','Advanced Diploma in Data Science','advanced-diploma-data-science','IT','advanced_diploma',6,12,900)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), category=VALUES(category), stream_level=VALUES(stream_level),
  nsqf_level=VALUES(nsqf_level), duration_months=VALUES(duration_months), total_hours=VALUES(total_hours), is_active=1;

-- De-duplication helper table stores merge operations for audit
CREATE TABLE IF NOT EXISTS course_merge_audit (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  source_course_id BIGINT UNSIGNED NOT NULL,
  target_course_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NOT NULL,
  merged_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  merged_by BIGINT UNSIGNED NULL,
  KEY idx_merge_tenant (tenant_id, merged_at),
  CONSTRAINT fk_merge_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_merge_source FOREIGN KEY (source_course_id) REFERENCES courses(id),
  CONSTRAINT fk_merge_target FOREIGN KEY (target_course_id) REFERENCES courses(id),
  CONSTRAINT fk_merge_user FOREIGN KEY (merged_by) REFERENCES users(id)
) ENGINE=InnoDB;

-- Sync canonical catalog into tenant courses (idempotent)
INSERT INTO courses (tenant_id, course_code, name, slug, stream_level, nsqf_level, duration_months, total_hours, is_active)
SELECT 1, cc.course_code, cc.name, cc.slug, cc.stream_level, cc.nsqf_level, cc.duration_months, cc.total_hours, cc.is_active
FROM course_catalog cc
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  slug = VALUES(slug),
  stream_level = VALUES(stream_level),
  nsqf_level = VALUES(nsqf_level),
  duration_months = VALUES(duration_months),
  total_hours = VALUES(total_hours),
  is_active = VALUES(is_active);
