<?php
class AuditLog extends Model {
    public function add(array $data): void {
        $sql = "INSERT INTO audit_logs (tenant_id, actor_user_id, module, action, entity_type, entity_id, ip_address, user_agent, meta)
                VALUES (:tenant_id,:actor_user_id,:module,:action,:entity_type,:entity_id,:ip_address,:user_agent,:meta)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
    }
}
