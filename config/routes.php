<?php
return [
    'GET' => [
        '/' => ['CommunicationController', 'index'],
        '/course/catalog' => ['CourseController', 'catalog'],
    ],
    'POST' => [
        '/communication/process-queue' => ['CommunicationController', 'processQueue'],
        '/student/create' => ['StudentController', 'create'],
        '/communication/queue-email' => ['CommunicationController', 'queueEmail'],
        '/course/sync' => ['CourseController', 'syncFromBody'],
    ]
];
