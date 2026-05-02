<?php
class App {
    public function run(): void {
        $request = new Request();
        $routes = require __DIR__ . '/../config/routes.php';
        $method = $request->method();
        $path = $request->path();

        if (!isset($routes[$method][$path])) {
            Response::json(['error' => 'Route not found', 'path' => $path, 'method' => $method], 404);
            return;
        }

        [$controllerName, $action] = $routes[$method][$path];
        $controller = new $controllerName();
        $controller->$action($request);
    }
}
