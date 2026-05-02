#!/usr/bin/env bash
set -euo pipefail
php -l core/App.php
php -l app/controllers/StudentController.php
php -l app/models/Student.php
php -l app/controllers/CourseController.php
php -l app/controllers/CommunicationController.php
echo "SMOKE_OK"
