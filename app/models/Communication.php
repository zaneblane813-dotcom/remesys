<?php
require_once __DIR__ . '/../../core/Model.php';
class Communication extends Model {
    public function queue(array $data): int {
        $sql = "INSERT INTO communications (tenant_id,user_id,module,type,subject,message,attachment_path,status)
                VALUES (:tenant_id,:user_id,:module,:type,:subject,:message,:attachment_path,'queued')";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        return (int)$this->db->lastInsertId();
    }
}
