<?php
return [
    'app' => [
        'name' => 'Remesys ERP LMS SaaS',
        'base_url' => '/'
    ],
    'db' => [
        'host' => '127.0.0.1',
        'port' => 3306,
        'name' => 'remesys',
        'user' => 'root',
        'pass' => '',
        'charset' => 'utf8mb4'
    ],
    'smtp' => [
        'host' => 'mail.remesys.in',
        'port' => 465,
        'encryption' => 'ssl',
        'auth' => true,
        'password' => 'Malda@732101',
        'from' => [
            'admin@remesys.in','career@remesys.in','contact@remesys.in','crm@remesys.in',
            'franchise@remesys.in','support@remesys.in','workshop@remesys.in'
        ]
    ]
];
