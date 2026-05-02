<?php
class Auth {
    public static function requireApiKey(Request $request): ?array {
        $config = require __DIR__ . '/../../config/config.php';
        $expected = $config['app']['api_key'] ?? '';
        $provided = $_SERVER['HTTP_X_API_KEY'] ?? '';
        if ($expected === '' || hash_equals($expected, $provided)) {
            return null;
        }
        return ['error' => 'Unauthorized'];
    }
}
