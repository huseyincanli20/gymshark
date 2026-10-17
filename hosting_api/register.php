<?php
/**
 * GymTrack - Kullanıcı Kayıt API'si
 * İstek: POST (JSON veya form-data)
 * Parametreler: name, email, password, metadata (isteğe bağlı)
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

$name = trim($input['name'] ?? '');
$email = trim(strtolower($input['email'] ?? ''));
$password = $input['password'] ?? '';
$metadata = isset($input['metadata']) ? json_encode($input['metadata'], JSON_UNESCAPED_UNICODE) : null;

// Doğrulamalar
if (empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "E-posta ve şifre zorunludur."
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode([
        "success" => false,
        "message" => "Geçerli bir e-posta adresi giriniz."
    ], JSON_UNESCAPED_UNICODE);
    exit();
}

try {
    // 1. E-posta adresi daha önce alınmış mı kontrol et
    $checkStmt = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
    $checkStmt->execute([':email' => $email]);
    if ($checkStmt->fetch()) {
        http_response_code(409); // Conflict
        echo json_encode([
            "success" => false,
            "message" => "Bu e-posta adresi ile zaten bir hesap kayıtlı! Lütfen giriş yapın."
        ], JSON_UNESCAPED_UNICODE);
        exit();
    }

    // 2. Şifreyi endüstri standardı Bcrypt ile hashle
    $passwordHash = password_hash($password, PASSWORD_BCRYPT);
    $userId = "usr_" . time() . "_" . mt_rand(1000, 9999);

    // 3. Veritabanına kaydet
    $insertStmt = $conn->prepare("
        INSERT INTO users (user_id, name, email, password_hash, metadata)
        VALUES (:user_id, :name, :email, :password_hash, :metadata)
    ");
    $insertStmt->execute([
        ':user_id' => $userId,
        ':name' => $name ?: 'Sporcu',
        ':email' => $email,
        ':password_hash' => $passwordHash,
        ':metadata' => $metadata
    ]);

    http_response_code(201);
    echo json_encode([
        "success" => true,
        "message" => "Kullanıcı hosting veritabanınıza başarıyla kaydedildi! 🎉",
        "user" => [
            "id" => $userId,
            "name" => $name ?: 'Sporcu',
            "email" => $email,
            "createdAt" => date('Y-m-d H:i:s')
        ]
    ], JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Kayıt işlemi sırasında veritabanı hatası oluştu.",
        "error_detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
}
