<?php
class EmailLog extends Model {
    public function create(array $data): int {
        $sql = "INSERT INTO email_logs
        (tenant_id, communication_id, sender_email, recipient_email, subject, body, smtp_host, smtp_port, encryption, status, error_message, sent_at)
        VALUES
        (:tenant_id,:communication_id,:sender_email,:recipient_email,:subject,:body,:smtp_host,:smtp_port,:encryption,:status,:error_message,:sent_at)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        return (int)$this->db->lastInsertId();
    }
}
