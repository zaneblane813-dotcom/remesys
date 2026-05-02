<?php
class NotificationWorker {
    public function run(): array {
        $queue = new NotificationQueue();
        $logger = new EmailLog();
        $mailer = new EmailService();
        $config = require __DIR__ . '/../../config/config.php';
        $smtp = $config['smtp'];

        $jobs = $queue->fetchPendingEmailJobs(25);
        $processed = 0;
        foreach ($jobs as $job) {
            $payload = json_decode($job['payload'], true) ?: [];
            $result = $mailer->send([
                'sender_email' => (string)($payload['sender_email'] ?? $smtp['from'][0]),
                'recipient_email' => (string)($payload['recipient_email'] ?? ''),
            ]);

            $status = $result['ok'] ? 'sent' : 'failed';
            $next = $result['ok'] ? null : date('Y-m-d H:i:s', time() + 300);
            $queue->mark((int)$job['id'], $status, $next);

            $logger->create([
                'tenant_id' => (int)$job['tenant_id'],
                'communication_id' => (int)$job['communication_id'],
                'sender_email' => (string)($payload['sender_email'] ?? $smtp['from'][0]),
                'recipient_email' => (string)($payload['recipient_email'] ?? ''),
                'subject' => (string)($job['subject'] ?? ''),
                'body' => (string)($job['message'] ?? ''),
                'smtp_host' => (string)$smtp['host'],
                'smtp_port' => (int)$smtp['port'],
                'encryption' => (string)$smtp['encryption'],
                'status' => $result['ok'] ? 'sent' : 'failed',
                'error_message' => $result['error'] ?? null,
                'sent_at' => $result['ok'] ? date('Y-m-d H:i:s') : null,
            ]);
            $processed++;
        }

        return ['processed' => $processed, 'fetched' => count($jobs)];
    }
}
