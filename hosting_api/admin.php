<?php
session_start();
require_once 'db.php';

$admin_pass = "15715799";
$admin_email = "huseyincanli@gmail.com";

// Çıkış yap
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: admin.php");
    exit();
}

// Giriş işlemi
$login_error = "";
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'login') {
    $entered_pass = $_POST['password'] ?? '';
    $entered_email = strtolower(trim($_POST['email'] ?? ''));
    if ($entered_pass === $admin_pass && ($entered_email === $admin_email || empty($entered_email))) {
        $_SESSION['gymtrack_admin'] = true;
        header("Location: admin.php");
        exit();
    } else {
        $login_error = "Hatalı e-posta veya yönetici şifresi!";
    }
}

// Üye Silme
if (isset($_SESSION['gymtrack_admin']) && isset($_GET['delete'])) {
    $delId = (int)$_GET['delete'];
    $delStmt = $conn->prepare("DELETE FROM users WHERE id = :id");
    $delStmt->execute([':id' => $delId]);
    header("Location: admin.php?msg=deleted");
    exit();
}

// Oturum Açık mı?
$is_logged_in = !empty($_SESSION['gymtrack_admin']);

// Üyeleri Çek
$users = [];
$total_users = 0;
if ($is_logged_in) {
    $search = trim($_GET['q'] ?? '');
    if ($search !== '') {
        $stmt = $conn->prepare("SELECT id, user_id, name, email, created_at FROM users WHERE name LIKE :s OR email LIKE :s ORDER BY id DESC");
        $stmt->execute([':s' => "%$search%"]);
    } else {
        $stmt = $conn->query("SELECT id, user_id, name, email, created_at FROM users ORDER BY id DESC");
    }
    $users = $stmt->fetchAll();
    $total_users = count($users);
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GymTrack - Yönetici Üye Paneli</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body { background-color: #0b0f19; font-family: system-ui, -apple-system, sans-serif; }
  </style>
</head>
<body class="text-slate-200 min-h-screen flex flex-col">

  <!-- Üst Bar -->
  <header class="border-b border-slate-800 bg-slate-900/80 backdrop-blur sticky top-0 z-50">
    <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-2xl">⚡</span>
        <div>
          <h1 class="text-lg font-bold text-white leading-tight">GymTrack</h1>
          <p class="text-xs text-cyan-400 font-semibold">Yönetici & Üye Takip Paneli</p>
        </div>
      </div>
      <?php if ($is_logged_in): ?>
        <div class="flex items-center gap-4">
          <span class="text-xs text-slate-400 hidden sm:inline">👑 Yönetici: <strong class="text-white">Hüseyin Canlı</strong></span>
          <a href="admin.php?logout=1" class="text-xs bg-red-600/20 hover:bg-red-600/30 text-red-400 border border-red-500/30 font-bold px-3 py-1.5 rounded-lg transition">Çıkış Yap</a>
        </div>
      <?php endif; ?>
    </div>
  </header>

  <main class="max-w-6xl mx-auto px-4 py-8 flex-1 w-full">

    <?php if (!$is_logged_in): ?>
      <!-- Giriş Formu -->
      <div class="max-w-md mx-auto mt-12 bg-slate-900 border border-slate-800 rounded-2xl p-6 sm:p-8 shadow-2xl">
        <div class="text-center mb-6">
          <div class="w-14 h-14 bg-cyan-500/10 border border-cyan-500/20 rounded-2xl flex items-center justify-center mx-auto mb-3 text-2xl">
            🔒
          </div>
          <h2 class="text-xl font-bold text-white">Yönetici Girişi</h2>
          <p class="text-xs text-slate-400 mt-1">GymTrack üyelerini görüntülemek için şifrenizi girin</p>
        </div>

        <?php if (!empty($login_error)): ?>
          <div class="mb-4 p-3 rounded-xl bg-red-500/10 border border-red-500/30 text-xs text-red-400 font-semibold">
            <?= htmlspecialchars($login_error) ?>
          </div>
        <?php endif; ?>

        <form method="POST" action="admin.php" class="space-y-4">
          <input type="hidden" name="action" value="login">
          <div>
            <label class="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Yönetici E-Postası</label>
            <input type="email" name="email" value="huseyincanli@gmail.com" required class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-cyan-500">
          </div>
          <div>
            <label class="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Şifre</label>
            <input type="password" name="password" required placeholder="••••••••" autofocus class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2.5 text-sm text-white focus:outline-none focus:border-cyan-500">
          </div>
          <button type="submit" class="w-full bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold py-2.5 rounded-xl transition text-sm shadow-lg shadow-cyan-500/20">
            Üye Paneline Giriş Yap ➔
          </button>
        </form>
      </div>

    <?php else: ?>
      <!-- Üye Listesi Dashboard -->
      
      <?php if (isset($_GET['msg']) && $_GET['msg'] === 'deleted'): ?>
        <div class="mb-6 p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-xs text-emerald-400 font-semibold flex items-center justify-between">
          <span>Seçilen kullanıcı veritabanından başarıyla silindi. 🗑️</span>
          <a href="admin.php" class="underline text-emerald-300">Tamam</a>
        </div>
      <?php endif; ?>

      <!-- İstatistik ve Arama Barı -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex items-center gap-4">
          <div class="w-12 h-12 bg-cyan-500/10 rounded-xl flex items-center justify-center text-2xl">👥</div>
          <div>
            <p class="text-xs text-slate-400 font-medium">Toplam Kayıtlı Üye</p>
            <p class="text-2xl font-extrabold text-white mt-0.5"><?= $total_users ?></p>
          </div>
        </div>

        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex items-center gap-4">
          <div class="w-12 h-12 bg-emerald-500/10 rounded-xl flex items-center justify-center text-2xl">🗄️</div>
          <div>
            <p class="text-xs text-slate-400 font-medium">Veritabanı Durumu</p>
            <p class="text-sm font-bold text-emerald-400 mt-0.5 flex items-center gap-1.5">
              <span class="w-2 h-2 bg-emerald-400 rounded-full animate-ping"></span> Canlı ve Bağlı
            </p>
          </div>
        </div>

        <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex items-center gap-4">
          <div class="w-12 h-12 bg-purple-500/10 rounded-xl flex items-center justify-center text-2xl">🔐</div>
          <div>
            <p class="text-xs text-slate-400 font-medium">Şifreleme Algoritması</p>
            <p class="text-sm font-bold text-purple-400 mt-0.5">Bcrypt Hash (Güvenli)</p>
          </div>
        </div>
      </div>

      <!-- Arama Kutusu -->
      <div class="bg-slate-900 border border-slate-800 rounded-2xl p-4 mb-6 flex flex-col sm:flex-row gap-3 items-center justify-between">
        <form method="GET" action="admin.php" class="w-full sm:w-96 flex gap-2">
          <input type="text" name="q" value="<?= htmlspecialchars($_GET['q'] ?? '') ?>" placeholder="İsim veya e-posta ile ara..." class="flex-1 bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-xs text-white focus:outline-none focus:border-cyan-500">
          <button type="submit" class="bg-slate-800 hover:bg-slate-700 text-white text-xs font-bold px-4 py-2 rounded-xl transition">Ara</button>
          <?php if (!empty($_GET['q'])): ?>
            <a href="admin.php" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 text-xs font-bold px-3 py-2 rounded-xl border border-red-500/20 transition flex items-center">Sıfırla</a>
          <?php endif; ?>
        </form>
        <span class="text-xs text-slate-400">Canlı Sunucu: <code class="text-cyan-400">huseyincanli.com/api</code></span>
      </div>

      <!-- Üyeler Tablosu -->
      <div class="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs">
            <thead class="bg-slate-950/80 text-slate-400 uppercase tracking-wider text-[11px] border-b border-slate-800">
              <tr>
                <th class="p-4"># ID</th>
                <th class="p-4">Ad Soyad</th>
                <th class="p-4">E-Posta Adresi</th>
                <th class="p-4">Kayıt Tarihi</th>
                <th class="p-4 text-right">İşlem</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-800/60 font-mono">
              <?php if (empty($users)): ?>
                <tr>
                  <td colspan="5" class="p-8 text-center text-slate-500 font-sans">
                    Henüz kayıtlı bir üye bulunmuyor veya arama sonucu boş.
                  </td>
                </tr>
              <?php else: ?>
                <?php foreach ($users as $u): ?>
                  <tr class="hover:bg-slate-800/40 transition">
                    <td class="p-4 text-slate-400">#<?= htmlspecialchars($u['id']) ?></td>
                    <td class="p-4 font-bold text-white font-sans flex items-center gap-2">
                      <span class="w-7 h-7 rounded-full bg-cyan-500/20 text-cyan-300 flex items-center justify-center text-xs font-bold">
                        <?= strtoupper(mb_substr($u['name'], 0, 1, 'UTF-8')) ?>
                      </span>
                      <?= htmlspecialchars($u['name']) ?>
                    </td>
                    <td class="p-4 text-cyan-400"><?= htmlspecialchars($u['email']) ?></td>
                    <td class="p-4 text-slate-400"><?= htmlspecialchars($u['created_at']) ?></td>
                    <td class="p-4 text-right font-sans">
                      <a href="admin.php?delete=<?= $u['id'] ?>" onclick="return confirm('Bu kullanıcıyı kalıcı olarak silmek istediğinize emin misiniz?');" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 text-xs font-semibold px-3 py-1.5 rounded-lg transition inline-block">Sil</a>
                    </td>
                  </tr>
                <?php endforeach; ?>
              <?php endif; ?>
            </tbody>
          </table>
        </div>
      </div>

    <?php endif; ?>

  </main>

  <footer class="border-t border-slate-800 py-4 text-center text-xs text-slate-600">
    GymTrack &copy; <?= date('Y') ?> &bull; Hüseyin Canlı Hosting Paneli
  </footer>

</body>
</html>
