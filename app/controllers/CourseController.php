<?php
require_once __DIR__ . '/../../core/Controller.php';
require_once __DIR__ . '/../models/Course.php';

class CourseController extends Controller {
    public function catalog(): void {
        $model = new Course();
        $this->json(['data' => $model->listCatalog()]);
    }

    public function sync(string $tenantId = '1'): void {
        $model = new Course();
        $affected = $model->syncCatalogToTenant((int)$tenantId);
        $this->json(['synced_rows' => $affected]);
    }
}
