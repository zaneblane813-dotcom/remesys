<?php
class TemplateRenderer {
    public function render(string $templateName, array $vars): string {
        $path = __DIR__ . '/../../../storage/templates/' . basename($templateName) . '.html';
        if (!is_file($path)) {
            return '<p>Template not found.</p>';
        }

        $html = file_get_contents($path) ?: '';
        foreach ($vars as $k => $v) {
            $html = str_replace('{{' . $k . '}}', htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'), $html);
        }
        return $html;
    }
}
