<?php
class CourseController extends Controller {
    public function catalog(Request $request): void {
        $model = new Course();
        $this->json(['data' => $model->listCatalog()]);
    }

    public function syncFromBody(Request $request): void {
        $payload = $request->json();
        $tenantId = isset($payload['tenant_id']) ? (int)$payload['tenant_id'] : 1;
        $model = new Course();
        $affected = $model->syncCatalogToTenant($tenantId);
        $this->json(['tenant_id' => $tenantId, 'synced_rows' => $affected]);
    }
}
