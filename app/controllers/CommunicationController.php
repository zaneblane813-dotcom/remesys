<?php

namespace App\Controllers;

use App\Services\EmailService;
use PDO;

class CommunicationController
{
    public function __construct(private PDO $db, private EmailService $emailService)
    {
    }

    public function sendStudentFeeReceipt(array $request): array
    {
        $sql = 'INSERT INTO communications
                (tenant_id, user_id, student_id, module, type, subject, message, attachment_path, status, scheduled_at)
                VALUES
                (:tenant_id, :user_id, :student_id, :module, :type, :subject, :message, :attachment_path, :status, NOW())';

        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            ':tenant_id' => $request['tenant_id'],
            ':user_id' => $request['user_id'] ?? null,
            ':student_id' => $request['student_id'] ?? null,
            ':module' => 'fees',
            ':type' => 'email',
            ':subject' => $request['subject'],
            ':message' => $request['html'],
            ':attachment_path' => $request['attachment_path'] ?? null,
            ':status' => 'queued',
        ]);

        $communicationId = (int) $this->db->lastInsertId();

        $sent = $this->emailService->send([
            'tenant_id' => $request['tenant_id'],
            'communication_id' => $communicationId,
            'sender_key' => $request['sender_key'] ?? 'admin',
            'to' => $request['to'],
            'subject' => $request['subject'],
            'html' => $request['html'],
            'attachment_path' => $request['attachment_path'] ?? null,
        ]);

        $upd = $this->db->prepare('UPDATE communications SET status = :status, sent_at = :sent_at WHERE id = :id');
        $upd->execute([
            ':status' => $sent ? 'sent' : 'failed',
            ':sent_at' => $sent ? date('Y-m-d H:i:s') : null,
            ':id' => $communicationId,
        ]);

        return ['success' => $sent, 'communication_id' => $communicationId];
    }
}
