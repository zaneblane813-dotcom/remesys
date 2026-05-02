<?php
class Autoloader {
    public static function register(): void {
        spl_autoload_register(function (string $class): void {
            $paths = [
                __DIR__ . '/../app/controllers/' . $class . '.php',
                __DIR__ . '/../app/models/' . $class . '.php',
                __DIR__ . '/' . $class . '.php',
                __DIR__ . '/Http/' . $class . '.php',
            ];

            foreach ($paths as $path) {
                if (is_file($path)) {
                    require_once $path;
                    return;
                }
            }
        });
    }
}
