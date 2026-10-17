<?php
/**
 * GymTrack - Kayıtlı Üyeleri Listeleme API'si (JSON)
 * Güvenlik: Admin kontrolü
 */

require_once 'db.php';

// Basit token veya şifre kontrolü
$adminKey = $_GET['admin_key'] ?? $_POST['admin_key'] ?? '';
$adminHeader = $_SERVER['HTTP_X_ADMIN_KEY'] ?? '';

if ($adminKey !== '15715799' && $adminHeader !== '15715799') {
    http_response_code(403);
    echo json_encode([
        "success" => false,
        "message" => "Yetkisiz erişim. Yönetici anahtarı gereklidir."
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    $stmt = $conn->query("
        SELECT id, user_id, name, email, created_at, metadata 
        FROM users 
        ORDER BY id DESC
    ");
    $users = $stmt->fetchAll();

    echo json_encode([
        "success" => true,
        "total" => count($users),
        "users" => $users
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Veritabanı hatası: " . $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
