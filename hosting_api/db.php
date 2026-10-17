<?php
/**
 * GymTrack - Hosting Veritabanı Bağlantısı ve CORS Ayarları
 * 
 * Hosting firmanızın cPanel veya Plesk panelinden aldığınız veritabanı
 * bilgilerini aşağıdaki değişkenlere yazınız.
 */

// Flutter Web ve Mobil uygulamadan gelen isteklere izin ver (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Tarayıcı OPTIONS (Preflight) isteklerini hemen onayla
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// ====================================================================
// --- LÜTFEN AŞAĞIDAKİ BİLGİLERİ KENDİ HOSTINGİNİZE GÖRE DOLDURUN ---
// ====================================================================
$db_host = "localhost";                  // Hostinglerde genellikle 'localhost'tur.
$db_name = "ojubxqxxjl_gymtrack_db";          // Örn: cpaneluser_gymtrack
$db_user = "ojubxqxxjl_gymtrack_user";// Örn: cpaneluser_dbuser
$db_pass = "Ankara198198.";        // Veritabanı kullanıcısının şifresi

try {
    $conn = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Veritabanı bağlantı hatası: Lütfen db.php içindeki veritabanı adı, kullanıcı ve şifreyi kontrol edin.",
        "error_detail" => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE);
    exit();
}
