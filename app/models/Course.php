<?php
require_once __DIR__ . '/../../core/Model.php';

class Course extends Model {
    public function listCatalog(): array {
        $stmt = $this->db->query("SELECT course_code, name, slug, stream_level, nsqf_level, duration_months, total_hours FROM course_catalog WHERE is_active = 1 ORDER BY nsqf_level, name");
        return $stmt->fetchAll();
    }

    public function syncCatalogToTenant(int $tenantId): int {
        $sql = "INSERT INTO courses (tenant_id, course_code, name, slug, stream_level, nsqf_level, duration_months, total_hours, is_active)
                SELECT :tenant_id, cc.course_code, cc.name, cc.slug, cc.stream_level, cc.nsqf_level, cc.duration_months, cc.total_hours, cc.is_active
                FROM course_catalog cc
                ON DUPLICATE KEY UPDATE
                    name = VALUES(name), slug = VALUES(slug), stream_level = VALUES(stream_level),
                    nsqf_level = VALUES(nsqf_level), duration_months = VALUES(duration_months),
                    total_hours = VALUES(total_hours), is_active = VALUES(is_active)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(['tenant_id' => $tenantId]);
        return $stmt->rowCount();
    }
}
