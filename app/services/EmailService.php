<?php
class EmailService {
    private array $cfg;
    private MailerInterface $mailer;
    private TemplateRenderer $renderer;

    public function __construct() {
        $config = require __DIR__ . '/../../config/config.php';
        $this->cfg = $config['smtp'];
        $this->mailer = new SmtpMailer($this->cfg);
        $this->renderer = new TemplateRenderer();
    }

    public function validateSender(string $sender): bool {
        return in_array($sender, $this->cfg['from'], true);
    }

    public function send(array $mail): array {
        if (!$this->validateSender($mail['sender_email'] ?? '')) {
            return ['ok' => false, 'error' => 'Invalid sender email'];
        }

        if (!empty($mail['attachment_path']) && !is_file(__DIR__ . '/../../' . ltrim($mail['attachment_path'], '/'))) {
            return ['ok' => false, 'error' => 'Attachment not found'];
        }

        $html = $mail['html'] ?? null;
        if ($html === null && !empty($mail['template'])) {
            $html = $this->renderer->render((string)$mail['template'], $mail['template_vars'] ?? []);
        }

        return $this->mailer->send([
            'sender_email' => (string)$mail['sender_email'],
            'recipient_email' => (string)$mail['recipient_email'],
            'subject' => (string)($mail['subject'] ?? 'Notification'),
            'html' => (string)($html ?? '<p>Notification</p>'),
        ]);
    }
}
