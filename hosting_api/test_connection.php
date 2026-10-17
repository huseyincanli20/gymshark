<?php
/**
 * GymTrack - Hosting & Veritabanı Bağlantı Testi
 * İstek: GET
 * Bu dosyayı tarayıcıdan (örn: https://siteniz.com/api/test_connection.php)
 * açtığınızda veritabanına sorunsuz bağlanıp bağlanmadığını test eder.
 */

require_once 'db.php';

try {
    $stmt = $conn->query("SELECT COUNT(*) as total_users FROM users");
    $row = $stmt->fetch();
    $totalUsers = (int)$row['total_users'];

    http_response_code(200);
    echo json_encode([
        "success" => true,
        "message" => "Tebrikler! GymTrack Hosting API ve Veritabanı başarıyla çalışıyor! 🚀",
        "total_registered_users" => $totalUsers,
        "server_time" => date('Y-m-d H:i:s'),
        "php_version" => phpversion()
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Veritabanına bağlanıldı ancak 'users' tablosu bulunamadı. Lütfen schema.sql dosyasını phpMyAdmin üzerinden içeri aktarın.",
        "error_detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
