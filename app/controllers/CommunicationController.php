<?php
require_once __DIR__ . '/../../core/Controller.php';
require_once __DIR__ . '/../models/Communication.php';

class CommunicationController extends Controller {
    public function index(): void {
        $this->json(['message' => 'Communication Hub API']);
    }

    public function queueEmail(): void {
        $model = new Communication();
        $id = $model->queue([
            'tenant_id' => 1,
            'user_id' => null,
            'module' => 'fees',
            'type' => 'email',
            'subject' => 'Fee Receipt',
            'message' => '<p>Your receipt is attached.</p>',
            'attachment_path' => '/storage/receipts/REC-2026-0001.pdf'
        ]);
        $this->json(['queued_id' => $id], 201);
    }
}
