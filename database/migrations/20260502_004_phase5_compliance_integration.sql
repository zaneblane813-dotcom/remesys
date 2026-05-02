SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  actor_user_id BIGINT UNSIGNED NULL,
  module VARCHAR(80) NOT NULL,
  action VARCHAR(120) NOT NULL,
  entity_type VARCHAR(80) NULL,
  entity_id VARCHAR(80) NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  meta JSON NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_tenant_module (tenant_id, module, created_at),
  CONSTRAINT fk_audit_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_audit_actor FOREIGN KEY (actor_user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS legal_documents (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NULL,
  doc_type ENUM('aadhaar','pan','agreement','consent','other') NOT NULL,
  title VARCHAR(180) NOT NULL,
  file_path VARCHAR(255) NOT NULL,
  verified_by BIGINT UNSIGNED NULL,
  verified_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_legal_tenant_doc (tenant_id, doc_type),
  CONSTRAINT fk_legal_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_legal_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_legal_verified_by FOREIGN KEY (verified_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS integration_endpoints (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  system_key ENUM('learn','learn1','crm','workshop','partner','scholarship','test') NOT NULL,
  base_url VARCHAR(255) NOT NULL,
  auth_type ENUM('none','api_key','bearer') NOT NULL DEFAULT 'api_key',
  auth_secret VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_integration_tenant_system (tenant_id, system_key),
  CONSTRAINT fk_integration_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS integration_sync_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  endpoint_id BIGINT UNSIGNED NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id VARCHAR(80) NOT NULL,
  direction ENUM('push','pull') NOT NULL,
  status ENUM('success','failed') NOT NULL,
  request_payload JSON NULL,
  response_payload JSON NULL,
  error_message TEXT NULL,
  synced_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_sync_tenant_status (tenant_id, status, synced_at),
  CONSTRAINT fk_sync_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_sync_endpoint FOREIGN KEY (endpoint_id) REFERENCES integration_endpoints(id)
) ENGINE=InnoDB;
