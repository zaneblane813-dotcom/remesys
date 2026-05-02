<?php

namespace App\Services;

use PDO;
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class EmailService
{
    public function __construct(private PDO $db, private array $config)
    {
    }

    public function send(array $payload): bool
    {
        $mail = new PHPMailer(true);

        try {
            $smtp = $this->config['smtp'];
            $mail->isSMTP();
            $mail->Host = $smtp['host'];
            $mail->SMTPAuth = (bool) $smtp['auth'];
            $mail->Port = (int) $smtp['port'];
            $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;

            $fromEmail = $smtp['senders'][$payload['sender_key']] ?? $smtp['senders']['admin'];
            $mail->Username = $fromEmail;
            $mail->Password = $smtp['default_password'];

            $mail->setFrom($fromEmail, 'Remesys ERP');
            $mail->addAddress($payload['to']);
            $mail->isHTML(true);
            $mail->Subject = $payload['subject'];
            $mail->Body = $payload['html'];

            if (!empty($payload['attachment_path'])) {
                $mail->addAttachment($payload['attachment_path']);
            }

            $ok = $mail->send();
            $this->log($payload, $fromEmail, 'sent', null);
            return $ok;
        } catch (Exception $e) {
            $this->log($payload, $fromEmail ?? 'admin@remesys.in', 'failed', $e->getMessage());
            return false;
        }
    }

    private function log(array $payload, string $from, string $status, ?string $error): void
    {
        $sql = 'INSERT INTO email_logs
            (tenant_id, communication_id, sender_email, recipient_email, subject, body_html, attachment_path,
             smtp_host, smtp_port, smtp_encryption, status, error_message, sent_at)
            VALUES
            (:tenant_id, :communication_id, :sender_email, :recipient_email, :subject, :body_html, :attachment_path,
             :smtp_host, :smtp_port, :smtp_encryption, :status, :error_message, :sent_at)';

        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            ':tenant_id' => $payload['tenant_id'],
            ':communication_id' => $payload['communication_id'] ?? null,
            ':sender_email' => $from,
            ':recipient_email' => $payload['to'],
            ':subject' => $payload['subject'],
            ':body_html' => $payload['html'],
            ':attachment_path' => $payload['attachment_path'] ?? null,
            ':smtp_host' => $this->config['smtp']['host'],
            ':smtp_port' => $this->config['smtp']['port'],
            ':smtp_encryption' => $this->config['smtp']['encryption'],
            ':status' => $status,
            ':error_message' => $error,
            ':sent_at' => $status === 'sent' ? date('Y-m-d H:i:s') : null,
        ]);
    }
}
