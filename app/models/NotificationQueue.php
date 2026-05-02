<?php
class NotificationQueue extends Model {
    public function enqueue(array $data): int {
        $sql = "INSERT INTO notification_queue (tenant_id, communication_id, channel, payload, retry_count, max_retry, next_attempt_at, status)
                VALUES (:tenant_id,:communication_id,:channel,:payload,0,:max_retry,:next_attempt_at,'queued')";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($data);
        return (int)$this->db->lastInsertId();
    }

    public function fetchPendingEmailJobs(int $limit = 20): array {
        $sql = "SELECT nq.*, c.subject, c.message, c.attachment_path
                FROM notification_queue nq
                JOIN communications c ON c.id = nq.communication_id
                WHERE nq.channel = 'email' AND nq.status IN ('queued','failed')
                  AND (nq.next_attempt_at IS NULL OR nq.next_attempt_at <= NOW())
                ORDER BY nq.id ASC
                LIMIT :lim";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':lim', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function mark(int $id, string $status, ?string $nextAttemptAt = null): void {
        $sql = "UPDATE notification_queue SET status=:status, retry_count = retry_count + IF(:status='failed',1,0), next_attempt_at=:next_attempt_at WHERE id=:id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['id' => $id, 'status' => $status, 'next_attempt_at' => $nextAttemptAt]);
    }
}
