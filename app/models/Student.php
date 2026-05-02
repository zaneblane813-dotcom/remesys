<?php
class Student extends Model {
    public function create(array $data): int {
        $sql = "INSERT INTO students (tenant_id, admission_no, global_student_uuid, full_name, guardian_name, guardian_mobile)
                VALUES (:tenant_id, :admission_no, :global_student_uuid, :full_name, :guardian_name, :guardian_mobile)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        return (int)$this->db->lastInsertId();
    }
}
