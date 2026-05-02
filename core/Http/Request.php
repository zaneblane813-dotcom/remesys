<?php
class Request {
    public function method(): string {
        return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    }

    public function path(): string {
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        $clean = strtok($uri, '?') ?: '/';
        return '/' . trim($clean, '/');
    }

    public function input(string $key, mixed $default = null): mixed {
        return $_POST[$key] ?? $_GET[$key] ?? $default;
    }

    public function json(): array {
        $raw = file_get_contents('php://input') ?: '';
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }
}
