<?php
return [
    'GET' => [
        '/' => ['CommunicationController', 'index'],
        '/course/catalog' => ['CourseController', 'catalog'],
    ],
    'POST' => [
        '/student/create' => ['StudentController', 'create'],
        '/communication/queue-email' => ['CommunicationController', 'queueEmail'],
        '/course/sync' => ['CourseController', 'syncFromBody'],
    ]
];
