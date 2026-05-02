<?php
class StudentController extends Controller {
    public function create(Request $request): void {
        $payload = $request->json();
        foreach (['tenant_id','admission_no','full_name'] as $required) {
            if (empty($payload[$required])) {
                $this->json(['error' => "Missing field: {$required}"], 422);
                return;
            }
        }

        $model = new Student();
        $id = $model->create([
            'tenant_id' => (int)$payload['tenant_id'],
            'admission_no' => (string)$payload['admission_no'],
            'global_student_uuid' => (string)($payload['global_student_uuid'] ?? self::uuidV4()),
            'full_name' => (string)$payload['full_name'],
            'guardian_name' => (string)($payload['guardian_name'] ?? ''),
            'guardian_mobile' => (string)($payload['guardian_mobile'] ?? ''),
        ]);

        $this->json(['student_id' => $id], 201);
    }

    private static function uuidV4(): string {
        $data = random_bytes(16);
        $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
        $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
