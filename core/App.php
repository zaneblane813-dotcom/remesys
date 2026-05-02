<?php
class App {
    public function run(): void {
        $route = trim($_GET['url'] ?? '', '/');
        $parts = $route === '' ? ['communication', 'index'] : explode('/', $route);
        $controllerName = ucfirst($parts[0]) . 'Controller';
        $method = $parts[1] ?? 'index';
        $params = array_slice($parts, 2);

        $file = __DIR__ . '/../app/controllers/' . $controllerName . '.php';
        if (!file_exists($file)) {
            http_response_code(404); echo 'Controller not found'; return;
        }
        require_once $file;
        $controller = new $controllerName();
        if (!method_exists($controller, $method)) {
            http_response_code(404); echo 'Method not found'; return;
        }
        call_user_func_array([$controller, $method], $params);
    }
}
