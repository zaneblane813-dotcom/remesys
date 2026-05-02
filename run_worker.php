<?php
require_once __DIR__ . '/core/Autoloader.php';
Autoloader::register();
$result = (new NotificationWorker())->run();
echo json_encode($result, JSON_PRETTY_PRINT) . PHP_EOL;
