<?php
/**
 * GymTrack - İçerik API Endpoint'i (get_content.php)
 * Flutter mobil ve web uygulamasının veritabanından en güncel antrenmanları,
 * egzersizleri ve resimli besinleri JSON formatında çekmesini sağlar.
 */

require_once 'db.php';
require_once 'init_tables.php';

// Tablolar yoksa oluştur ve boşsa ilk verileri ekle
init_gymtrack_tables($conn);

$type = isset($_GET['type']) ? strtolower(trim($_GET['type'])) : 'all';

$response = [
    "success" => true,
    "timestamp" => date('Y-m-d H:i:s')
];

try {
    // 1. Egzersizleri Çek
    if ($type === 'all' || $type === 'exercises') {
        $stmt = $conn->query("SELECT exercise_id as id, name, muscle_group as muscleGroup, thumbnail_url as thumbnailUrl, video_url as videoUrl, instructions, tips FROM exercises ORDER BY id ASC");
        $exercises = $stmt->fetchAll();
        $response['exercises'] = $exercises;
    }

    // 2. Antrenman Programlarını Çek
    if ($type === 'all' || $type === 'routines') {
        $stmt = $conn->query("SELECT routine_id as id, name_tr as nameTr, name_en as nameEn, desc_tr as descTr, desc_en as descEn, split_category as splitCategory, level, estimated_minutes as estimatedMinutes, exercise_refs_json FROM workout_routines ORDER BY id ASC");
        $routinesRows = $stmt->fetchAll();
        
        $routines = [];
        foreach ($routinesRows as $r) {
            $exerciseRefs = json_decode($r['exercise_refs_json'], true) ?: [];
            $routines[] = [
                'id' => $r['id'],
                'nameTr' => $r['nameTr'],
                'nameEn' => $r['nameEn'],
                'descTr' => $r['descTr'],
                'descEn' => $r['descEn'],
                'splitCategory' => $r['splitCategory'],
                'level' => $r['level'],
                'estimatedMinutes' => (int)$r['estimatedMinutes'],
                'isCustom' => false,
                'exerciseRefs' => $exerciseRefs
            ];
        }
        $response['routines'] = $routines;
    }

    // 3. Besinleri ve Görsellerini Çek
    if ($type === 'all' || $type === 'foods') {
        $stmt = $conn->query("SELECT food_id as id, name, category, calories, protein, carbs, fat, image_url as imageUrl FROM foods ORDER BY id ASC");
        $foodsRows = $stmt->fetchAll();

        $foods = [];
        foreach ($foodsRows as $f) {
            $foods[] = [
                'id' => $f['id'],
                'name' => $f['name'],
                'category' => $f['category'],
                'calories' => (float)$f['calories'],
                'protein' => (float)$f['protein'],
                'carbs' => (float)$f['carbs'],
                'fat' => (float)$f['fat'],
                'imageUrl' => $f['imageUrl'] ?: ''
            ];
        }
        $response['foods'] = $foods;
    }

    http_response_code(200);
    echo json_encode($response, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
    exit();

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "İçerik yüklenirken hata oluştu: " . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit();
}
