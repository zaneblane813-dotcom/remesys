<?php
class CommunicationController extends Controller {
    public function index(Request $request): void {
        $this->json(['message' => 'Communication Hub API']);
    }

    public function queueEmail(Request $request): void {
        $payload = $request->json();
        foreach (['tenant_id','module','recipient_email','sender_email'] as $required) {
            if (empty($payload[$required])) {
                $this->json(['error' => "Missing field: {$required}"], 422);
                return;
            }
        }

        $comm = new Communication();
        $queue = new NotificationQueue();

        $commId = $comm->queue([
            'tenant_id' => (int)$payload['tenant_id'],
            'user_id' => $payload['user_id'] ?? null,
            'module' => (string)$payload['module'],
            'type' => 'email',
            'subject' => (string)($payload['subject'] ?? 'Notification'),
            'message' => (string)($payload['message'] ?? ''),
            'attachment_path' => $payload['attachment_path'] ?? null
        ]);

        $jobId = $queue->enqueue([
            'tenant_id' => (int)$payload['tenant_id'],
            'communication_id' => $commId,
            'channel' => 'email',
            'payload' => json_encode([
                'sender_email' => (string)$payload['sender_email'],
                'recipient_email' => (string)$payload['recipient_email'],
                'template' => $payload['template'] ?? null,
                'template_vars' => $payload['template_vars'] ?? [],
            ], JSON_UNESCAPED_SLASHES),
            'max_retry' => 5,
            'next_attempt_at' => date('Y-m-d H:i:s'),
        ]);

        $this->json(['communication_id' => $commId, 'queue_id' => $jobId], 201);
    }

    public function processQueue(Request $request): void {
        $result = (new NotificationWorker())->run();
        $this->json($result);
    }
}
