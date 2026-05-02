SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS enrollments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  batch_id BIGINT UNSIGNED NOT NULL,
  enrolled_on DATE NOT NULL,
  status ENUM('active','completed','dropped','hold') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_enrollment (tenant_id, student_id, batch_id),
  KEY idx_enrollment_tenant_status (tenant_id, status),
  CONSTRAINT fk_enroll_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES students(id),
  CONSTRAINT fk_enroll_batch FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attendance (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  enrollment_id BIGINT UNSIGNED NOT NULL,
  attendance_date DATE NOT NULL,
  status ENUM('present','absent','leave','late') NOT NULL,
  marked_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_attendance_day (enrollment_id, attendance_date),
  KEY idx_attendance_tenant_date (tenant_id, attendance_date),
  CONSTRAINT fk_att_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_att_enroll FOREIGN KEY (enrollment_id) REFERENCES enrollments(id),
  CONSTRAINT fk_att_marked_by FOREIGN KEY (marked_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exams (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  course_id BIGINT UNSIGNED NOT NULL,
  batch_id BIGINT UNSIGNED NULL,
  exam_type ENUM('online','printable','ocr_design') NOT NULL,
  title VARCHAR(180) NOT NULL,
  exam_date DATE NULL,
  total_marks SMALLINT UNSIGNED NOT NULL,
  pass_marks SMALLINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY idx_exams_tenant_date (tenant_id, exam_date),
  CONSTRAINT fk_exam_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_exam_course FOREIGN KEY (course_id) REFERENCES courses(id),
  CONSTRAINT fk_exam_batch FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exam_results (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tenant_id BIGINT UNSIGNED NOT NULL,
  exam_id BIGINT UNSIGNED NOT NULL,
  student_id BIGINT UNSIGNED NOT NULL,
  marks_obtained DECIMAL(6,2) NOT NULL,
  grade VARCHAR(8) NULL,
  status ENUM('pass','fail','absent') NOT NULL,
  published_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_result_exam_student (exam_id, student_id),
  KEY idx_result_tenant_status (tenant_id, status),
  CONSTRAINT fk_result_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT fk_result_exam FOREIGN KEY (exam_id) REFERENCES exams(id),
  CONSTRAINT fk_result_student FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;
