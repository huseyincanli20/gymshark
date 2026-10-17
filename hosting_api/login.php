<?php
/**
 * GymTrack - Kullanıcı Giriş API'si
 * İstek: POST (JSON veya form-data)
 * Parametreler: email, password
 */

require_once 'db.php';

// Gelen JSON verisini çöz
$rawInput = trim(file_get_contents("php://input"));
if (substr($rawInput, 0, 3) === "\xEF\xBB\xBF") {
    $rawInput = substr($rawInput, 3);
}
$input = json_decode($rawInput, true);

if (!$input || !is_array($input)) {
    $input = $_POST;
}

$email = trim(strtolower($input['email'] ?? ''));
$password = $input['password'] ?? '';

// Doğrulamalar
if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Lütfen e-posta ve şifrenizi girin."
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    // Kullanıcıyı e-posta ile bul
    $stmt = $conn->prepare("
        SELECT user_id, name, email, password_hash, created_at, metadata 
        FROM users 
        WHERE email = :email 
        LIMIT 1
    ");
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch();

    if (!$user) {
        http_response_code(401);
        echo json_encode([
            "success" => false,
            "message" => "Hatalı e-posta veya şifre! Lütfen bilgilerinizi kontrol edin."
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // Hashlenmiş şifreyi doğrula
    if (!password_verify($password, $user['password_hash'])) {
        http_response_code(401);
        echo json_encode([
            "success" => false,
            "message" => "Hatalı e-posta veya şifre! Lütfen bilgilerinizi kontrol edin."
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // Giriş Başarılı
    http_response_code(200);
    echo json_encode([
        "success" => true,
        "message" => "Giriş başarılı! Hoş geldiniz.",
        "user" => [
            "id" => $user['user_id'],
            "name" => $user['name'],
            "email" => $user['email'],
            "createdAt" => $user['created_at'],
            "metadata" => $user['metadata'] ? json_decode($user['metadata'], true) : []
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Giriş işlemi sırasında veritabanı hatası oluştu.",
        "error_detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
