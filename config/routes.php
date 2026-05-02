<?php
return [
    'GET' => [
        '/' => ['CommunicationController', 'index'],
        '/course/catalog' => ['CourseController', 'catalog'],
    ],
    'POST' => [
        '/communication/queue-email' => ['CommunicationController', 'queueEmail'],
        '/course/sync' => ['CourseController', 'syncFromBody'],
    ]
];
