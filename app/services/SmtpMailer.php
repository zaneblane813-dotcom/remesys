<?php
class SmtpMailer implements MailerInterface {
    private array $cfg;
    public function __construct(array $smtpConfig) {
        $this->cfg = $smtpConfig;
    }

    public function send(array $mail): array {
        $to = $mail['recipient_email'] ?? '';
        $subject = $mail['subject'] ?? '';
        $html = $mail['html'] ?? '';
        $from = $mail['sender_email'] ?? '';

        if (!filter_var($to, FILTER_VALIDATE_EMAIL)) {
            return ['ok' => false, 'error' => 'Invalid recipient email'];
        }

        $headers = [
            'MIME-Version: 1.0',
            'Content-type: text/html; charset=UTF-8',
            'From: ' . $from,
            'Reply-To: ' . $from,
            'X-Mailer: PHP/' . phpversion(),
        ];

        $ok = @mail($to, $subject, $html, implode("\r\n", $headers));
        return $ok
            ? ['ok' => true, 'provider_message_id' => 'php-mail-' . bin2hex(random_bytes(6))]
            : ['ok' => false, 'error' => 'mail() delivery failed; configure SMTP adapter in production'];
    }
}
