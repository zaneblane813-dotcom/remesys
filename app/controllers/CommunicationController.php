<?php
class CommunicationController extends Controller {
    public function index(Request $request): void {
        $this->json(['message' => 'Communication Hub API']);
    }

    public function queueEmail(Request $request): void {
        $payload = $request->json();
        $model = new Communication();

        $id = $model->queue([
            'tenant_id' => (int)($payload['tenant_id'] ?? 1),
            'user_id' => $payload['user_id'] ?? null,
            'module' => (string)($payload['module'] ?? 'fees'),
            'type' => 'email',
            'subject' => (string)($payload['subject'] ?? 'Notification'),
            'message' => (string)($payload['message'] ?? '<p>Message</p>'),
            'attachment_path' => $payload['attachment_path'] ?? null
        ]);
        $this->json(['queued_id' => $id], 201);
    }
}
