-- Example standardized catalog seed (deduplicated)
-- NSQF mapping rule:
-- Basic=3, Intermediate=4, Advanced=5, Advanced Diploma=6

INSERT INTO courses (tenant_id, course_code, title, slug, duration_months, level_type, nsqf_level, is_iti, description)
VALUES
(1,'COPA-ITI-001','COPA (ITI)','copa-iti',12,'intermediate',4,1,'Computer Operator and Programming Assistant (ITI)'),
(1,'ROBO-OP-001','Robotic Operator','robotic-operator',6,'intermediate',4,0,'Industrial robotic operation and safety'),
(1,'ADWD-001','Advanced Diploma in Web Development','advanced-diploma-web-development',18,'advanced_diploma',6,0,'Full stack web and deployment'),
(1,'PY-INT-001','Python Programming','python-programming',6,'intermediate',4,0,'Intermediate python programming'),
(1,'ACCT-ADV-001','Advanced Accounting with GST','advanced-accounting-with-gst',9,'advanced',5,0,'Accounting, TDS and GST workflow')
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  duration_months = VALUES(duration_months),
  level_type = VALUES(level_type),
  nsqf_level = VALUES(nsqf_level),
  status = 'active';
