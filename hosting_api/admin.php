<?php
session_start();
require_once 'db.php';
require_once 'init_tables.php';

header("Content-Type: text/html; charset=UTF-8");

// Veritabanı tablolarını kontrol et / otomatik oluştur
init_gymtrack_tables($conn);

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

$is_logged_in = !empty($_SESSION['gymtrack_admin']);
$active_tab = $_GET['tab'] ?? 'members';
$msg = $_GET['msg'] ?? '';

// --- YÖNETİCİ İŞLEMLERİ (POST & GET) ---
if ($is_logged_in) {

    // 1. ÜYE SİLME
    if (isset($_GET['delete_user'])) {
        $delId = (int)$_GET['delete_user'];
        $stmt = $conn->prepare("DELETE FROM users WHERE id = :id");
        $stmt->execute([':id' => $delId]);
        header("Location: admin.php?tab=members&msg=user_deleted");
        exit();
    }

    // 2. EGZERSİZ SİLME
    if (isset($_GET['delete_exercise'])) {
        $delId = (int)$_GET['delete_exercise'];
        $stmt = $conn->prepare("DELETE FROM exercises WHERE id = :id");
        $stmt->execute([':id' => $delId]);
        header("Location: admin.php?tab=exercises&msg=ex_deleted");
        exit();
    }

    // 3. PROGRAM SİLME
    if (isset($_GET['delete_routine'])) {
        $delId = (int)$_GET['delete_routine'];
        $stmt = $conn->prepare("DELETE FROM workout_routines WHERE id = :id");
        $stmt->execute([':id' => $delId]);
        header("Location: admin.php?tab=routines&msg=routine_deleted");
        exit();
    }

    // 4. BESİN SİLME
    if (isset($_GET['delete_food'])) {
        $delId = (int)$_GET['delete_food'];
        $stmt = $conn->prepare("DELETE FROM foods WHERE id = :id");
        $stmt->execute([':id' => $delId]);
        header("Location: admin.php?tab=foods&msg=food_deleted");
        exit();
    }

    // 5. FABRİKA AYARLARINA SIFIRLA
    if (isset($_GET['reset_defaults'])) {
        $conn->exec("TRUNCATE TABLE exercises");
        $conn->exec("TRUNCATE TABLE workout_routines");
        $conn->exec("TRUNCATE TABLE foods");
        init_gymtrack_tables($conn);
        header("Location: admin.php?tab=settings&msg=reset_ok");
        exit();
    }

    // POST İŞLEMLERİ
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $action = $_POST['action'] ?? '';

        // EGZERSİZ EKLE VEYA DÜZENLE
        if ($action === 'save_exercise') {
            $ex_db_id = !empty($_POST['db_id']) ? (int)$_POST['db_id'] : null;
            $name = trim($_POST['name'] ?? '');
            $muscle = trim($_POST['muscle_group'] ?? 'chest');
            $thumb = trim($_POST['thumbnail_url'] ?? '');
            $video = trim($_POST['video_url'] ?? '');
            $instructions = trim($_POST['instructions'] ?? '');
            $tips = trim($_POST['tips'] ?? '');

            if ($ex_db_id) {
                // Güncelle
                $stmt = $conn->prepare("UPDATE exercises SET name = :name, muscle_group = :muscle, thumbnail_url = :thumb, video_url = :video, instructions = :inst, tips = :tips WHERE id = :id");
                $stmt->execute([
                    ':name' => $name,
                    ':muscle' => $muscle,
                    ':thumb' => $thumb,
                    ':video' => $video,
                    ':inst' => $instructions,
                    ':tips' => $tips,
                    ':id' => $ex_db_id
                ]);
            } else {
                // Ekle
                $custom_id = 'ex_' . time() . '_' . rand(100, 999);
                $stmt = $conn->prepare("INSERT INTO exercises (exercise_id, name, muscle_group, thumbnail_url, video_url, instructions, tips) VALUES (:eid, :name, :muscle, :thumb, :video, :inst, :tips)");
                $stmt->execute([
                    ':eid' => $custom_id,
                    ':name' => $name,
                    ':muscle' => $muscle,
                    ':thumb' => $thumb,
                    ':video' => $video,
                    ':inst' => $instructions,
                    ':tips' => $tips
                ]);
            }
            header("Location: admin.php?tab=exercises&msg=ex_saved");
            exit();
        }

        // BESİN EKLE VEYA DÜZENLE
        if ($action === 'save_food') {
            $food_db_id = !empty($_POST['db_id']) ? (int)$_POST['db_id'] : null;
            $name = trim($_POST['name'] ?? '');
            $category = trim($_POST['category'] ?? 'Genel');
            $calories = (float)str_replace(',', '.', $_POST['calories'] ?? '0');
            $protein = (float)str_replace(',', '.', $_POST['protein'] ?? '0');
            $carbs = (float)str_replace(',', '.', $_POST['carbs'] ?? '0');
            $fat = (float)str_replace(',', '.', $_POST['fat'] ?? '0');
            $image_url = trim($_POST['image_url'] ?? '');

            if ($food_db_id) {
                $stmt = $conn->prepare("UPDATE foods SET name = :name, category = :cat, calories = :cal, protein = :p, carbs = :c, fat = :f, image_url = :img WHERE id = :id");
                $stmt->execute([
                    ':name' => $name,
                    ':cat' => $category,
                    ':cal' => $calories,
                    ':p' => $protein,
                    ':c' => $carbs,
                    ':f' => $fat,
                    ':img' => $image_url,
                    ':id' => $food_db_id
                ]);
            } else {
                $custom_id = 'f_' . time() . '_' . rand(100, 999);
                $stmt = $conn->prepare("INSERT INTO foods (food_id, name, category, calories, protein, carbs, fat, image_url) VALUES (:fid, :name, :cat, :cal, :p, :c, :f, :img)");
                $stmt->execute([
                    ':fid' => $custom_id,
                    ':name' => $name,
                    ':cat' => $category,
                    ':cal' => $calories,
                    ':p' => $protein,
                    ':c' => $carbs,
                    ':f' => $fat,
                    ':img' => $image_url
                ]);
            }
            header("Location: admin.php?tab=foods&msg=food_saved");
            exit();
        }

        // ANTRENMAN PROGRAMI EKLE VEYA DÜZENLE
        if ($action === 'save_routine') {
            $rt_db_id = !empty($_POST['db_id']) ? (int)$_POST['db_id'] : null;
            $name_tr = trim($_POST['name_tr'] ?? '');
            $name_en = trim($_POST['name_en'] ?? $name_tr);
            $desc_tr = trim($_POST['desc_tr'] ?? '');
            $desc_en = trim($_POST['desc_en'] ?? $desc_tr);
            $split = trim($_POST['split_category'] ?? 'PPL');
            $level = trim($_POST['level'] ?? 'Orta');
            $mins = (int)($_POST['estimated_minutes'] ?? 50);

            // Egzersiz referanslarını derle
            $selected_exercises = $_POST['ex_ids'] ?? [];
            $ex_sets = $_POST['ex_sets'] ?? [];
            $ex_reps = $_POST['ex_reps'] ?? [];
            $ex_weights = $_POST['ex_weights'] ?? [];

            $refs = [];
            foreach ($selected_exercises as $idx => $exId) {
                if (!empty($exId)) {
                    $refs[] = [
                        'exerciseId' => $exId,
                        'defaultSets' => (int)($ex_sets[$idx] ?? 3),
                        'defaultReps' => (int)($ex_reps[$idx] ?? 10),
                        'defaultWeightKg' => (float)($ex_weights[$idx] ?? 20)
                    ];
                }
            }
            $refs_json = json_encode($refs, JSON_UNESCAPED_UNICODE);

            if ($rt_db_id) {
                $stmt = $conn->prepare("UPDATE workout_routines SET name_tr = :nt, name_en = :ne, desc_tr = :dt, desc_en = :de, split_category = :sc, level = :lvl, estimated_minutes = :em, exercise_refs_json = :refs WHERE id = :id");
                $stmt->execute([
                    ':nt' => $name_tr,
                    ':ne' => $name_en,
                    ':dt' => $desc_tr,
                    ':de' => $desc_en,
                    ':sc' => $split,
                    ':lvl' => $level,
                    ':em' => $mins,
                    ':refs' => $refs_json,
                    ':id' => $rt_db_id
                ]);
            } else {
                $custom_id = 'routine_' . time();
                $stmt = $conn->prepare("INSERT INTO workout_routines (routine_id, name_tr, name_en, desc_tr, desc_en, split_category, level, estimated_minutes, exercise_refs_json) VALUES (:rid, :nt, :ne, :dt, :de, :sc, :lvl, :em, :refs)");
                $stmt->execute([
                    ':rid' => $custom_id,
                    ':nt' => $name_tr,
                    ':ne' => $name_en,
                    ':dt' => $desc_tr,
                    ':de' => $desc_en,
                    ':sc' => $split,
                    ':lvl' => $level,
                    ':em' => $mins,
                    ':refs' => $refs_json
                ]);
            }
            header("Location: admin.php?tab=routines&msg=routine_saved");
            exit();
        }
    }

    // --- TAB VERİLERİNİ ÇEK ---
    // 1. Üyeler
    $users = $conn->query("SELECT id, user_id, name, email, created_at FROM users ORDER BY id DESC")->fetchAll();
    $total_users = count($users);

    // 2. Egzersizler
    $filter_muscle = $_GET['muscle'] ?? '';
    if ($filter_muscle !== '') {
        $stmtEx = $conn->prepare("SELECT * FROM exercises WHERE muscle_group = :m ORDER BY id DESC");
        $stmtEx->execute([':m' => $filter_muscle]);
        $exercises = $stmtEx->fetchAll();
    } else {
        $exercises = $conn->query("SELECT * FROM exercises ORDER BY id DESC")->fetchAll();
    }
    $total_exercises = count($exercises);

    // 3. Antrenman Programları
    $routines = $conn->query("SELECT * FROM workout_routines ORDER BY id DESC")->fetchAll();
    $total_routines = count($routines);

    // 4. Besinler
    $filter_cat = $_GET['category'] ?? '';
    if ($filter_cat !== '') {
        $stmtFd = $conn->prepare("SELECT * FROM foods WHERE category = :c ORDER BY id DESC");
        $stmtFd->execute([':c' => $filter_cat]);
        $foods = $stmtFd->fetchAll();
    } else {
        $foods = $conn->query("SELECT * FROM foods ORDER BY id DESC")->fetchAll();
    }
    $total_foods = count($foods);

    // Egzersiz haritası (Program detayında isim göstermek için)
    $allExList = $conn->query("SELECT exercise_id, name, muscle_group FROM exercises ORDER BY name ASC")->fetchAll();
    $exMap = [];
    foreach ($allExList as $row) {
        $exMap[$row['exercise_id']] = $row['name'];
    }
}
?>
<!DOCTYPE html>
<html lang="tr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GymTrack - Yönetim & Veritabanı Paneli</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body { background-color: #0b0f19; font-family: system-ui, -apple-system, sans-serif; }
    .thumb-preview { object-fit: cover; }
  </style>
</head>
<body class="text-slate-200 min-h-screen flex flex-col">

  <!-- Üst Bar -->
  <header class="border-b border-slate-800 bg-slate-900/90 backdrop-blur sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <span class="text-2xl">⚡</span>
        <div>
          <h1 class="text-lg font-bold text-white leading-tight">GymTrack CMS</h1>
          <p class="text-xs text-cyan-400 font-semibold">Canlı Veritabanı & İçerik Yönetimi</p>
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

  <main class="max-w-7xl mx-auto px-4 py-6 flex-1 w-full">

    <?php if (!$is_logged_in): ?>
      <!-- Giriş Formu -->
      <div class="max-w-md mx-auto mt-12 bg-slate-900 border border-slate-800 rounded-2xl p-6 sm:p-8 shadow-2xl">
        <div class="text-center mb-6">
          <div class="w-14 h-14 bg-cyan-500/10 border border-cyan-500/20 rounded-2xl flex items-center justify-center mx-auto mb-3 text-2xl">
            🔒
          </div>
          <h2 class="text-xl font-bold text-white">Yönetici Girişi</h2>
          <p class="text-xs text-slate-400 mt-1">GymTrack antrenman, besin ve üyeleri yönetmek için şifrenizi girin</p>
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
            Yönetim Paneline Giriş Yap ➔
          </button>
        </form>
      </div>

    <?php else: ?>
      <!-- Bildirim Mesajları -->
      <?php if (!empty($msg)): ?>
        <div class="mb-6 p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-xs text-emerald-400 font-semibold flex items-center justify-between">
          <span>
            <?php
              switch ($msg) {
                case 'user_deleted': echo 'Seçilen kullanıcı veritabanından başarıyla silindi. 🗑️'; break;
                case 'ex_saved': echo 'Egzersiz başarıyla kaydedildi ve uygulamada güncellendi! 🏃'; break;
                case 'ex_deleted': echo 'Egzersiz veritabanından silindi. 🗑️'; break;
                case 'routine_saved': echo 'Antrenman programı başarıyla kaydedildi! 🏋️'; break;
                case 'routine_deleted': echo 'Antrenman programı silindi. 🗑️'; break;
                case 'food_saved': echo 'Besin ve fotoğraf bilgileri başarıyla kaydedildi! 🥗'; break;
                case 'food_deleted': echo 'Besin veritabanından silindi. 🗑️'; break;
                case 'reset_ok': echo 'Tüm tablolar fabrika ayarlarına sıfırlandı ve standart veriler yüklendi! ⚡'; break;
                default: echo 'İşlem başarıyla tamamlandı!';
              }
            ?>
          </span>
          <a href="admin.php?tab=<?= htmlspecialchars($active_tab) ?>" class="underline text-emerald-300">Tamam</a>
        </div>
      <?php endif; ?>

      <!-- Üst Sekmeler (Tab Bar) -->
      <div class="flex flex-wrap items-center gap-2 mb-6 border-b border-slate-800 pb-3">
        <a href="admin.php?tab=members" class="px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 <?= $active_tab === 'members' ? 'bg-cyan-500 text-slate-950 shadow-lg shadow-cyan-500/20' : 'bg-slate-900 hover:bg-slate-800 text-slate-300' ?>">
          <span>👥</span> Üyeler (<?= $total_users ?>)
        </a>
        <a href="admin.php?tab=routines" class="px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 <?= $active_tab === 'routines' ? 'bg-cyan-500 text-slate-950 shadow-lg shadow-cyan-500/20' : 'bg-slate-900 hover:bg-slate-800 text-slate-300' ?>">
          <span>🏋️</span> Antrenman Programları (<?= $total_routines ?>)
        </a>
        <a href="admin.php?tab=exercises" class="px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 <?= $active_tab === 'exercises' ? 'bg-cyan-500 text-slate-950 shadow-lg shadow-cyan-500/20' : 'bg-slate-900 hover:bg-slate-800 text-slate-300' ?>">
          <span>🏃</span> Egzersizler & GIF'ler (<?= $total_exercises ?>)
        </a>
        <a href="admin.php?tab=foods" class="px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 <?= $active_tab === 'foods' ? 'bg-cyan-500 text-slate-950 shadow-lg shadow-cyan-500/20' : 'bg-slate-900 hover:bg-slate-800 text-slate-300' ?>">
          <span>🥗</span> Besinler & Kalori (<?= $total_foods ?>)
        </a>
        <a href="admin.php?tab=settings" class="px-4 py-2 rounded-xl text-xs font-bold transition flex items-center gap-2 <?= $active_tab === 'settings' ? 'bg-cyan-500 text-slate-950 shadow-lg shadow-cyan-500/20' : 'bg-slate-900 hover:bg-slate-800 text-slate-300' ?>">
          <span>⚙️</span> Veritabanı & API
        </a>
      </div>

      <!-- ============================================================== -->
      <!-- SEKME 1: ÜYELER -->
      <!-- ============================================================== -->
      <?php if ($active_tab === 'members'): ?>
        <div class="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
          <div class="p-4 border-b border-slate-800 flex justify-between items-center">
            <h2 class="text-sm font-bold text-white flex items-center gap-2"><span>👥</span> Kayıtlı Üyeler</h2>
            <span class="text-xs text-slate-400">Toplam: <strong class="text-cyan-400"><?= $total_users ?></strong> kişi</span>
          </div>
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
                  <tr><td colspan="5" class="p-8 text-center text-slate-500 font-sans">Henüz kayıtlı bir üye bulunmuyor.</td></tr>
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
                        <a href="admin.php?tab=members&delete_user=<?= $u['id'] ?>" onclick="return confirm('Bu kullanıcıyı kalıcı olarak silmek istediğinize emin misiniz?');" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 text-xs font-semibold px-3 py-1.5 rounded-lg transition inline-block">Sil</a>
                      </td>
                    </tr>
                  <?php endforeach; ?>
                <?php endif; ?>
              </tbody>
            </table>
          </div>
        </div>

      <!-- ============================================================== -->
      <!-- SEKME 2: ANTRENMAN PROGRAMLARI -->
      <!-- ============================================================== -->
      <?php elseif ($active_tab === 'routines'): ?>
        <div class="flex justify-between items-center mb-4">
          <div>
            <h2 class="text-base font-bold text-white">Antrenman Programları (Routines)</h2>
            <p class="text-xs text-slate-400">Uygulamanın içindeki PPL, Upper/Lower, 5x5 ve özel antrenman listesi</p>
          </div>
          <button onclick="openRoutineModal()" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-4 py-2 rounded-xl text-xs transition shadow-lg shadow-cyan-500/20 flex items-center gap-1.5">
            <span>+</span> Yeni Program Ekle
          </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <?php foreach ($routines as $r): 
            $refs = json_decode($r['exercise_refs_json'], true) ?: [];
          ?>
            <div class="bg-slate-900 border border-slate-800 rounded-2xl p-5 flex flex-col justify-between hover:border-slate-700 transition">
              <div>
                <div class="flex items-start justify-between gap-3 mb-2">
                  <div>
                    <span class="inline-block bg-cyan-500/10 text-cyan-400 border border-cyan-500/20 rounded-lg px-2.5 py-0.5 text-[11px] font-bold mb-1.5">
                      <?= htmlspecialchars($r['split_category']) ?> &bull; <?= htmlspecialchars($r['level']) ?>
                    </span>
                    <h3 class="text-base font-bold text-white leading-snug"><?= htmlspecialchars($r['name_tr']) ?></h3>
                    <p class="text-xs text-slate-400 font-mono mt-0.5"><?= htmlspecialchars($r['name_en']) ?></p>
                  </div>
                  <span class="text-xs bg-slate-800 text-slate-300 px-2.5 py-1 rounded-lg whitespace-nowrap">
                    ⏱️ <?= htmlspecialchars($r['estimated_minutes']) ?> dk
                  </span>
                </div>
                <p class="text-xs text-slate-300 mt-2 mb-4 line-clamp-2"><?= htmlspecialchars($r['desc_tr']) ?></p>

                <!-- İçerdiği Hareketler -->
                <div class="bg-slate-950 border border-slate-800/80 rounded-xl p-3 mb-4">
                  <p class="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-2">İçerdiği Egzersizler (<?= count($refs) ?> hareket):</p>
                  <div class="space-y-1.5 max-h-36 overflow-y-auto pr-1">
                    <?php foreach ($refs as $rf): 
                      $exName = $exMap[$rf['exerciseId']] ?? $rf['exerciseId'];
                    ?>
                      <div class="flex items-center justify-between text-xs py-1 border-b border-slate-800/50 last:border-0">
                        <span class="text-slate-200 font-medium">⚡ <?= htmlspecialchars($exName) ?></span>
                        <span class="text-cyan-400 text-[11px] font-mono">
                          <?= $rf['defaultSets'] ?? 3 ?> set &bull; <?= $rf['defaultReps'] ?? 10 ?> tekrar &bull; <?= $rf['defaultWeightKg'] ?? 20 ?>kg
                        </span>
                      </div>
                    <?php endforeach; ?>
                  </div>
                </div>
              </div>

              <div class="flex items-center justify-end gap-2 pt-3 border-t border-slate-800">
                <button onclick='editRoutine(<?= json_encode($r) ?>)' class="bg-slate-800 hover:bg-slate-700 text-cyan-400 text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-700 transition">Düzenle</button>
                <a href="admin.php?tab=routines&delete_routine=<?= $r['id'] ?>" onclick="return confirm('Bu antrenman programını silmek istediğinize emin misiniz?');" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 text-xs font-semibold px-3 py-1.5 rounded-lg transition">Sil</a>
              </div>
            </div>
          <?php endforeach; ?>
        </div>

      <!-- ============================================================== -->
      <!-- SEKME 3: EGZERSİZLER & GIF'LER -->
      <!-- ============================================================== -->
      <?php elseif ($active_tab === 'exercises'): ?>
        <div class="flex flex-col sm:flex-row justify-between sm:items-center gap-3 mb-4">
          <div>
            <h2 class="text-base font-bold text-white">Egzersizler, Hareket Formları & GIF'ler</h2>
            <p class="text-xs text-slate-400">Uygulamadaki hareketli GIF'leri, rehberleri ve ipuçlarını canlı düzenleyin</p>
          </div>
          <button onclick="openExerciseModal()" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-4 py-2 rounded-xl text-xs transition shadow-lg shadow-cyan-500/20 flex items-center gap-1.5 self-start sm:self-auto">
            <span>+</span> Yeni Egzersiz Ekle
          </button>
        </div>

        <!-- Kas Grubu Filtreleri -->
        <div class="flex flex-wrap items-center gap-2 mb-4">
          <span class="text-xs text-slate-400 mr-1">Kas Grubu:</span>
          <?php 
            $muscles = ['Tümü' => '', 'Göğüs (Chest)' => 'chest', 'Sırt (Back)' => 'back', 'Bacak (Legs)' => 'legs', 'Omuz (Shoulders)' => 'shoulders', 'Kol (Arms)' => 'arms', 'Karın (Core)' => 'core', 'Kardiyo' => 'cardio'];
            foreach ($muscles as $label => $val):
              $sel = ($filter_muscle === $val);
          ?>
            <a href="admin.php?tab=exercises<?= $val !== '' ? '&muscle=' . $val : '' ?>" class="text-xs px-3 py-1 rounded-lg border transition <?= $sel ? 'bg-cyan-500 text-slate-950 border-cyan-400 font-bold' : 'bg-slate-900 text-slate-300 border-slate-800 hover:bg-slate-800' ?>">
              <?= $label ?>
            </a>
          <?php endforeach; ?>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <?php foreach ($exercises as $e): ?>
            <div class="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden flex flex-col justify-between hover:border-slate-700 transition">
              <div>
                <!-- Resim veya GIF Önizlemesi -->
                <div class="h-44 bg-slate-950 relative overflow-hidden flex items-center justify-center">
                  <?php if (!empty($e['thumbnail_url'])): ?>
                    <img src="<?= htmlspecialchars($e['thumbnail_url']) ?>" alt="<?= htmlspecialchars($e['name']) ?>" class="w-full h-full object-cover">
                  <?php else: ?>
                    <span class="text-3xl">🏋️</span>
                  <?php endif; ?>
                  <span class="absolute top-2 right-2 bg-slate-900/80 backdrop-blur border border-slate-700 text-cyan-400 text-[10px] uppercase font-bold px-2 py-0.5 rounded-md">
                    <?= htmlspecialchars($e['muscle_group']) ?>
                  </span>
                </div>

                <div class="p-4">
                  <h3 class="text-sm font-bold text-white"><?= htmlspecialchars($e['name']) ?></h3>
                  <p class="text-xs text-slate-400 mt-1.5 line-clamp-2"><?= htmlspecialchars($e['instructions']) ?></p>
                  <?php if (!empty($e['tips'])): ?>
                    <p class="text-[11px] text-emerald-400/90 mt-2 bg-emerald-500/10 border border-emerald-500/20 rounded-lg p-2">
                      💡 <strong>İpucu:</strong> <?= htmlspecialchars($e['tips']) ?>
                    </p>
                  <?php endif; ?>
                </div>
              </div>

              <div class="p-4 pt-2 border-t border-slate-800/80 flex items-center justify-between">
                <span class="text-[11px] text-slate-500 font-mono">ID: <?= htmlspecialchars($e['exercise_id']) ?></span>
                <div class="flex items-center gap-2">
                  <button onclick='editExercise(<?= json_encode($e) ?>)' class="bg-slate-800 hover:bg-slate-700 text-cyan-400 text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-700 transition">Düzenle</button>
                  <a href="admin.php?tab=exercises&delete_exercise=<?= $e['id'] ?>" onclick="return confirm('Bu egzersizi silmek istediğinize emin misiniz?');" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 text-xs font-semibold px-3 py-1.5 rounded-lg transition">Sil</a>
                </div>
              </div>
            </div>
          <?php endforeach; ?>
        </div>

      <!-- ============================================================== -->
      <!-- SEKME 4: BESİNLER & KALORİ & FOTOĞRAFLAR -->
      <!-- ============================================================== -->
      <?php elseif ($active_tab === 'foods'): ?>
        <div class="flex flex-col sm:flex-row justify-between sm:items-center gap-3 mb-4">
          <div>
            <h2 class="text-base font-bold text-white">Besinler, Kaloriler, Makrolar & Fotoğrafları</h2>
            <p class="text-xs text-slate-400">Yiyecek ve içeceklerin kalori, protein, karbonhidrat, yağ ve görsel URL'lerini yönetin</p>
          </div>
          <button onclick="openFoodModal()" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-4 py-2 rounded-xl text-xs transition shadow-lg shadow-cyan-500/20 flex items-center gap-1.5 self-start sm:self-auto">
            <span>+</span> Yeni Besin Ekle
          </button>
        </div>

        <!-- Kategori Filtresi -->
        <div class="flex flex-wrap items-center gap-2 mb-4">
          <span class="text-xs text-slate-400 mr-1">Kategori:</span>
          <?php 
            $cats = ['Tümü' => '', 'Et & Protein' => 'Et & Protein', 'Temel Besin' => 'Temel Besin', 'Süt Ürünleri' => 'Süt Ürünleri', 'Karbonhidrat' => 'Karbonhidrat', 'Bakliyat' => 'Bakliyat', 'Meyve' => 'Meyve', 'Sağlıklı Yağlar' => 'Sağlıklı Yağlar', 'İçecek' => 'İçecek'];
            foreach ($cats as $label => $val):
              $sel = ($filter_cat === $val);
          ?>
            <a href="admin.php?tab=foods<?= $val !== '' ? '&category=' . urlencode($val) : '' ?>" class="text-xs px-3 py-1 rounded-lg border transition <?= $sel ? 'bg-cyan-500 text-slate-950 border-cyan-400 font-bold' : 'bg-slate-900 text-slate-300 border-slate-800 hover:bg-slate-800' ?>">
              <?= $label ?>
            </a>
          <?php endforeach; ?>
        </div>

        <div class="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
              <thead class="bg-slate-950/80 text-slate-400 uppercase tracking-wider text-[11px] border-b border-slate-800">
                <tr>
                  <th class="p-3 w-16">Fotoğraf</th>
                  <th class="p-3">Besin Adı</th>
                  <th class="p-3">Kategori</th>
                  <th class="p-3 text-right">Kalori (100g)</th>
                  <th class="p-3 text-right">Protein</th>
                  <th class="p-3 text-right">Karb</th>
                  <th class="p-3 text-right">Yağ</th>
                  <th class="p-3 text-right">İşlemler</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-800/60">
                <?php foreach ($foods as $f): ?>
                  <tr class="hover:bg-slate-800/40 transition">
                    <td class="p-3">
                      <div class="w-12 h-12 rounded-xl bg-slate-950 overflow-hidden border border-slate-800 flex items-center justify-center">
                        <?php if (!empty($f['image_url'])): ?>
                          <img src="<?= htmlspecialchars($f['image_url']) ?>" alt="" class="w-full h-full object-cover">
                        <?php else: ?>
                          <span class="text-lg">🥗</span>
                        <?php endif; ?>
                      </div>
                    </td>
                    <td class="p-3 font-bold text-white"><?= htmlspecialchars($f['name']) ?></td>
                    <td class="p-3">
                      <span class="bg-slate-800 text-cyan-400 px-2.5 py-0.5 rounded-md text-[11px]">
                        <?= htmlspecialchars($f['category']) ?>
                      </span>
                    </td>
                    <td class="p-3 text-right font-bold text-emerald-400 font-mono"><?= (float)$f['calories'] ?> kcal</td>
                    <td class="p-3 text-right font-mono text-cyan-400"><?= (float)$f['protein'] ?>g</td>
                    <td class="p-3 text-right font-mono text-amber-400"><?= (float)$f['carbs'] ?>g</td>
                    <td class="p-3 text-right font-mono text-rose-400"><?= (float)$f['fat'] ?>g</td>
                    <td class="p-3 text-right">
                      <button onclick='editFood(<?= json_encode($f) ?>)' class="bg-slate-800 hover:bg-slate-700 text-cyan-400 text-xs font-semibold px-3 py-1.5 rounded-lg border border-slate-700 transition mr-1">Düzenle</button>
                      <a href="admin.php?tab=foods&delete_food=<?= $f['id'] ?>" onclick="return confirm('Bu besini silmek istediğinize emin misiniz?');" class="bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 text-xs font-semibold px-2.5 py-1.5 rounded-lg transition inline-block">Sil</a>
                    </td>
                  </tr>
                <?php endforeach; ?>
              </tbody>
            </table>
          </div>
        </div>

      <!-- ============================================================== -->
      <!-- SEKME 5: VERİTABANI & APİ AYARLARI -->
      <!-- ============================================================== -->
      <?php elseif ($active_tab === 'settings'): ?>
        <div class="max-w-3xl mx-auto space-y-6">
          <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6">
            <h3 class="text-base font-bold text-white mb-2 flex items-center gap-2"><span>🗄️</span> Canlı MySQL Veritabanı Bilgileri</h3>
            <p class="text-xs text-slate-400 mb-4">GymTrack mobil ve web uygulaması doğrudan bu hosting üzerindeki MySQL tablolarını okur.</p>

            <div class="space-y-2 text-xs font-mono bg-slate-950 p-4 rounded-xl border border-slate-800">
              <div class="flex justify-between py-1 border-b border-slate-800/60">
                <span class="text-slate-400">Veritabanı Adı:</span>
                <span class="text-white font-bold">ojubxqxxjl_gymtrack_db</span>
              </div>
              <div class="flex justify-between py-1 border-b border-slate-800/60">
                <span class="text-slate-400">Kullanıcı:</span>
                <span class="text-white">ojubxqxxjl_gymtrack_user</span>
              </div>
              <div class="flex justify-between py-1 border-b border-slate-800/60">
                <span class="text-slate-400">Sunucu Adresi:</span>
                <span class="text-emerald-400">localhost (Canlı ve Bağlı)</span>
              </div>
              <div class="flex justify-between py-1">
                <span class="text-slate-400">İçerik API Endpoint:</span>
                <a href="get_content.php" target="_blank" class="text-cyan-400 underline">https://huseyincanli.com/api/get_content.php</a>
              </div>
            </div>
          </div>

          <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6">
            <h3 class="text-base font-bold text-white mb-2 flex items-center gap-2"><span>🔄</span> Fabrika Ayarlarına Sıfırla</h3>
            <p class="text-xs text-slate-400 mb-4">
              Veritabanındaki egzersizleri, antrenman programlarını ve resimli besinleri en baştaki standart orijinal durumuna geri yükler. Kayıtlı kullanıcı hesapları silinmez.
            </p>
            <a href="admin.php?reset_defaults=1" onclick="return confirm('Tüm antrenman, egzersiz ve besinler orijinal fabrika ayarlarına sıfırlanacak. Onaylıyor musunuz?');" class="bg-red-500/20 hover:bg-red-500/30 text-red-400 border border-red-500/30 text-xs font-bold px-4 py-2.5 rounded-xl transition inline-block">
              ⚠️ Varsayılan Verileri Yeniden Yükle
            </a>
          </div>
        </div>

      <?php endif; ?>

      <!-- ============================================================== -->
      <!-- MODALLER: EGZERSİZ, BESİN VE PROGRAM FORM MODALLERİ -->
      <!-- ============================================================== -->

      <!-- 1. EGZERSİZ MODALI -->
      <div id="exerciseModal" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 max-h-[90vh] overflow-y-auto">
          <div class="flex justify-between items-center mb-4">
            <h3 id="exModalTitle" class="text-base font-bold text-white">Yeni Egzersiz Ekle</h3>
            <button onclick="closeExerciseModal()" class="text-slate-400 hover:text-white text-lg">&times;</button>
          </div>
          <form method="POST" action="admin.php?tab=exercises" class="space-y-4">
            <input type="hidden" name="action" value="save_exercise">
            <input type="hidden" name="db_id" id="ex_db_id" value="">
            
            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Egzersiz Adı</label>
              <input type="text" name="name" id="ex_name" required placeholder="Örn: Incline Bench Press" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Hedef Kas Grubu</label>
              <select name="muscle_group" id="ex_muscle" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
                <option value="chest">Göğüs (Chest)</option>
                <option value="back">Sırt (Back)</option>
                <option value="legs">Bacak (Legs)</option>
                <option value="shoulders">Omuz (Shoulders)</option>
                <option value="arms">Kol / Biceps / Triceps (Arms)</option>
                <option value="core">Karın / Core</option>
                <option value="cardio">Kardiyo</option>
              </select>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Hareketli GIF veya Fotoğraf URL</label>
              <input type="text" name="thumbnail_url" id="ex_thumb" oninput="previewExImage(this.value)" placeholder="https://...gif veya .jpg" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              <div id="ex_img_preview_box" class="mt-2 w-full h-32 bg-slate-950 border border-slate-800 rounded-xl hidden items-center justify-center overflow-hidden">
                <img id="ex_img_preview" src="" alt="Önizleme" class="w-full h-full object-cover">
              </div>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Demo Video / MP4 URL (İsteğe Bağlı)</label>
              <input type="text" name="video_url" id="ex_video" placeholder="https://...mp4" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Doğru Form & Talimatlar</label>
              <textarea name="instructions" id="ex_inst" rows="3" placeholder="Sırtınızı sehpaya sabitleyin..." class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500"></textarea>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Önemli Güvenlik / Form İpucu</label>
              <input type="text" name="tips" id="ex_tips" placeholder="Belinizi aşırı kavis yapmaktan kaçının." class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
            </div>

            <div class="flex justify-end gap-3 pt-3">
              <button type="button" onclick="closeExerciseModal()" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-400 hover:text-white bg-slate-800">Vazgeç</button>
              <button type="submit" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-5 py-2 rounded-xl text-xs transition">Kaydet</button>
            </div>
          </form>
        </div>
      </div>

      <!-- 2. BESİN MODALI -->
      <div id="foodModal" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-lg w-full p-6 max-h-[90vh] overflow-y-auto">
          <div class="flex justify-between items-center mb-4">
            <h3 id="foodModalTitle" class="text-base font-bold text-white">Yeni Besin Ekle</h3>
            <button onclick="closeFoodModal()" class="text-slate-400 hover:text-white text-lg">&times;</button>
          </div>
          <form method="POST" action="admin.php?tab=foods" class="space-y-4">
            <input type="hidden" name="action" value="save_food">
            <input type="hidden" name="db_id" id="food_db_id" value="">
            
            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Besin Adı</label>
              <input type="text" name="name" id="food_name" required placeholder="Örn: Hindi Füme" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
            </div>

            <div class="grid grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Kategori</label>
                <select name="category" id="food_cat" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
                  <option value="Et & Protein">Et & Protein</option>
                  <option value="Temel Besin">Temel Besin</option>
                  <option value="Süt Ürünleri">Süt Ürünleri</option>
                  <option value="Karbonhidrat">Karbonhidrat</option>
                  <option value="Bakliyat">Bakliyat</option>
                  <option value="Meyve">Meyve</option>
                  <option value="Sağlıklı Yağlar">Sağlıklı Yağlar</option>
                  <option value="İçecek">İçecek</option>
                  <option value="İçecek & Takviye">İçecek & Takviye</option>
                </select>
              </div>
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Kalori (100g için)</label>
                <input type="number" step="0.1" name="calories" id="food_cal" required placeholder="kcal" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Besin Fotoğrafı URL</label>
              <input type="text" name="image_url" id="food_img" oninput="previewFoodImage(this.value)" placeholder="https://...jpg veya .png" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              <div id="food_img_preview_box" class="mt-2 w-full h-32 bg-slate-950 border border-slate-800 rounded-xl hidden items-center justify-center overflow-hidden">
                <img id="food_img_preview" src="" alt="Önizleme" class="w-full h-full object-cover">
              </div>
            </div>

            <div class="grid grid-cols-3 gap-3">
              <div>
                <label class="block text-xs font-semibold text-cyan-400 mb-1">Protein (g)</label>
                <input type="number" step="0.1" name="protein" id="food_p" required placeholder="g" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
              <div>
                <label class="block text-xs font-semibold text-amber-400 mb-1">Karb (g)</label>
                <input type="number" step="0.1" name="carbs" id="food_c" required placeholder="g" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
              <div>
                <label class="block text-xs font-semibold text-rose-400 mb-1">Yağ (g)</label>
                <input type="number" step="0.1" name="fat" id="food_f" required placeholder="g" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
            </div>

            <div class="flex justify-end gap-3 pt-3">
              <button type="button" onclick="closeFoodModal()" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-400 hover:text-white bg-slate-800">Vazgeç</button>
              <button type="submit" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-5 py-2 rounded-xl text-xs transition">Kaydet</button>
            </div>
          </form>
        </div>
      </div>

      <!-- 3. PROGRAM MODALI -->
      <div id="routineModal" class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 hidden flex items-center justify-center p-4">
        <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-2xl w-full p-6 max-h-[90vh] overflow-y-auto">
          <div class="flex justify-between items-center mb-4">
            <h3 id="routineModalTitle" class="text-base font-bold text-white">Yeni Antrenman Programı Ekle</h3>
            <button onclick="closeRoutineModal()" class="text-slate-400 hover:text-white text-lg">&times;</button>
          </div>
          <form method="POST" action="admin.php?tab=routines" class="space-y-4">
            <input type="hidden" name="action" value="save_routine">
            <input type="hidden" name="db_id" id="rt_db_id" value="">
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Program Adı (Türkçe)</label>
                <input type="text" name="name_tr" id="rt_nt" required placeholder="Örn: PPL: İtiş Günü (Push Day)" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Program Adı (İngilizce)</label>
                <input type="text" name="name_en" id="rt_ne" placeholder="Örn: PPL: Push Day" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Kategori (Split)</label>
                <select name="split_category" id="rt_split" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
                  <option value="PPL">PPL</option>
                  <option value="Upper/Lower">Upper/Lower</option>
                  <option value="5x5">5x5</option>
                  <option value="Full Body">Full Body</option>
                  <option value="Özel">Özel</option>
                </select>
              </div>
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Zorluk Seviyesi</label>
                <select name="level" id="rt_lvl" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
                  <option value="Başlangıç">Başlangıç</option>
                  <option value="Orta">Orta</option>
                  <option value="İleri">İleri</option>
                </select>
              </div>
              <div>
                <label class="block text-xs font-semibold text-slate-300 mb-1">Tahmini Süre (Dk)</label>
                <input type="number" name="estimated_minutes" id="rt_mins" value="50" class="w-full bg-slate-950 border border-slate-800 rounded-xl px-3 py-2 text-sm text-white focus:outline-none focus:border-cyan-500">
              </div>
            </div>

            <div>
              <label class="block text-xs font-semibold text-slate-300 mb-1">Açıklama (Türkçe)</label>
              <textarea name="desc_tr" id="rt_dt" rows="2" placeholder="Göğüs, omuz ve triceps hipertrofi seansı..." class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-2 text-sm text-white focus:outline-none focus:border-cyan-500"></textarea>
            </div>

            <!-- Egzersiz Seçici Alanı -->
            <div>
              <div class="flex justify-between items-center mb-2">
                <label class="text-xs font-bold text-cyan-400">İçerdiği Egzersizler & Hedef Set/Tekrarlar</label>
                <button type="button" onclick="addExerciseRowToRoutine()" class="text-xs bg-cyan-500/20 text-cyan-300 border border-cyan-500/30 px-2.5 py-1 rounded-lg hover:bg-cyan-500/30 transition">+ Hareket Ekle</button>
              </div>
              <div id="routine_exercises_container" class="space-y-2 max-h-48 overflow-y-auto bg-slate-950 p-3 rounded-xl border border-slate-800">
                <!-- Dinamik satırlar buraya eklenir -->
              </div>
            </div>

            <div class="flex justify-end gap-3 pt-3">
              <button type="button" onclick="closeRoutineModal()" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-400 hover:text-white bg-slate-800">Vazgeç</button>
              <button type="submit" class="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-bold px-5 py-2 rounded-xl text-xs transition">Programı Kaydet</button>
            </div>
          </form>
        </div>
      </div>

      <!-- JavaScript Fonksiyonları -->
      <script>
        const availableExercises = <?= json_encode($allExList) ?>;

        // EGZERSİZ MODAL FONKSİYONLARI
        function openExerciseModal() {
          document.getElementById('exModalTitle').innerText = 'Yeni Egzersiz Ekle';
          document.getElementById('ex_db_id').value = '';
          document.getElementById('ex_name').value = '';
          document.getElementById('ex_muscle').value = 'chest';
          document.getElementById('ex_thumb').value = '';
          document.getElementById('ex_video').value = '';
          document.getElementById('ex_inst').value = '';
          document.getElementById('ex_tips').value = '';
          previewExImage('');
          document.getElementById('exerciseModal').classList.remove('hidden');
        }

        function editExercise(ex) {
          document.getElementById('exModalTitle').innerText = 'Egzersizi Düzenle';
          document.getElementById('ex_db_id').value = ex.id;
          document.getElementById('ex_name').value = ex.name || '';
          document.getElementById('ex_muscle').value = ex.muscle_group || 'chest';
          document.getElementById('ex_thumb').value = ex.thumbnail_url || '';
          document.getElementById('ex_video').value = ex.video_url || '';
          document.getElementById('ex_inst').value = ex.instructions || '';
          document.getElementById('ex_tips').value = ex.tips || '';
          previewExImage(ex.thumbnail_url || '');
          document.getElementById('exerciseModal').classList.remove('hidden');
        }

        function closeExerciseModal() {
          document.getElementById('exerciseModal').classList.add('hidden');
        }

        function previewExImage(url) {
          const box = document.getElementById('ex_img_preview_box');
          const img = document.getElementById('ex_img_preview');
          if (url && url.trim().length > 5) {
            img.src = url;
            box.classList.remove('hidden');
            box.classList.add('flex');
          } else {
            box.classList.add('hidden');
            box.classList.remove('flex');
          }
        }

        // BESİN MODAL FONKSİYONLARI
        function openFoodModal() {
          document.getElementById('foodModalTitle').innerText = 'Yeni Besin Ekle';
          document.getElementById('food_db_id').value = '';
          document.getElementById('food_name').value = '';
          document.getElementById('food_cat').value = 'Et & Protein';
          document.getElementById('food_cal').value = '';
          document.getElementById('food_p').value = '';
          document.getElementById('food_c').value = '';
          document.getElementById('food_f').value = '';
          document.getElementById('food_img').value = '';
          previewFoodImage('');
          document.getElementById('foodModal').classList.remove('hidden');
        }

        function editFood(f) {
          document.getElementById('foodModalTitle').innerText = 'Besini Düzenle';
          document.getElementById('food_db_id').value = f.id;
          document.getElementById('food_name').value = f.name || '';
          document.getElementById('food_cat').value = f.category || 'Et & Protein';
          document.getElementById('food_cal').value = f.calories || '';
          document.getElementById('food_p').value = f.protein || '';
          document.getElementById('food_c').value = f.carbs || '';
          document.getElementById('food_f').value = f.fat || '';
          document.getElementById('food_img').value = f.image_url || '';
          previewFoodImage(f.image_url || '');
          document.getElementById('foodModal').classList.remove('hidden');
        }

        function closeFoodModal() {
          document.getElementById('foodModal').classList.add('hidden');
        }

        function previewFoodImage(url) {
          const box = document.getElementById('food_img_preview_box');
          const img = document.getElementById('food_img_preview');
          if (url && url.trim().length > 5) {
            img.src = url;
            box.classList.remove('hidden');
            box.classList.add('flex');
          } else {
            box.classList.add('hidden');
            box.classList.remove('flex');
          }
        }

        // PROGRAM MODAL FONKSİYONLARI
        function openRoutineModal() {
          document.getElementById('routineModalTitle').innerText = 'Yeni Antrenman Programı Ekle';
          document.getElementById('rt_db_id').value = '';
          document.getElementById('rt_nt').value = '';
          document.getElementById('rt_ne').value = '';
          document.getElementById('rt_split').value = 'PPL';
          document.getElementById('rt_lvl').value = 'Orta';
          document.getElementById('rt_mins').value = '50';
          document.getElementById('rt_dt').value = '';
          document.getElementById('routine_exercises_container').innerHTML = '';
          addExerciseRowToRoutine(); // Varsayılan 1 satır
          document.getElementById('routineModal').classList.remove('hidden');
        }

        function editRoutine(r) {
          document.getElementById('routineModalTitle').innerText = 'Antrenman Programını Düzenle';
          document.getElementById('rt_db_id').value = r.id;
          document.getElementById('rt_nt').value = r.name_tr || '';
          document.getElementById('rt_ne').value = r.name_en || '';
          document.getElementById('rt_split').value = r.split_category || 'PPL';
          document.getElementById('rt_lvl').value = r.level || 'Orta';
          document.getElementById('rt_mins').value = r.estimated_minutes || '50';
          document.getElementById('rt_dt').value = r.desc_tr || '';
          
          const container = document.getElementById('routine_exercises_container');
          container.innerHTML = '';
          let refs = [];
          try {
            refs = JSON.parse(r.exercise_refs_json) || [];
          } catch (e) {}

          if (refs.length > 0) {
            refs.forEach(ref => {
              addExerciseRowToRoutine(ref.exerciseId, ref.defaultSets, ref.defaultReps, ref.defaultWeightKg);
            });
          } else {
            addExerciseRowToRoutine();
          }

          document.getElementById('routineModal').classList.remove('hidden');
        }

        function closeRoutineModal() {
          document.getElementById('routineModal').classList.add('hidden');
        }

        function addExerciseRowToRoutine(selectedExId = '', sets = 3, reps = 10, weight = 20) {
          const container = document.getElementById('routine_exercises_container');
          const div = document.createElement('div');
          div.className = 'flex items-center gap-2 text-xs py-1 border-b border-slate-800/60';

          let optionsHtml = '';
          availableExercises.forEach(e => {
            const isSel = (e.exercise_id === selectedExId) ? 'selected' : '';
            optionsHtml += `<option value="${e.exercise_id}" ${isSel}>${e.name} (${e.muscle_group})</option>`;
          });

          div.innerHTML = `
            <select name="ex_ids[]" class="flex-1 bg-slate-900 border border-slate-800 rounded-lg px-2 py-1 text-white">
              ${optionsHtml}
            </select>
            <input type="number" name="ex_sets[]" value="${sets}" title="Set" placeholder="Set" class="w-14 bg-slate-900 border border-slate-800 rounded-lg px-2 py-1 text-white text-center">
            <input type="number" name="ex_reps[]" value="${reps}" title="Tekrar" placeholder="Tekrar" class="w-14 bg-slate-900 border border-slate-800 rounded-lg px-2 py-1 text-white text-center">
            <input type="number" step="0.5" name="ex_weights[]" value="${weight}" title="Kg" placeholder="Kg" class="w-16 bg-slate-900 border border-slate-800 rounded-lg px-2 py-1 text-white text-center">
            <button type="button" onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-300 font-bold px-2 py-1">&times;</button>
          `;
          container.appendChild(div);
        }
      </script>

    <?php endif; ?>

  </main>

  <footer class="border-t border-slate-800 py-4 text-center text-xs text-slate-600">
    GymTrack CMS &copy; <?= date('Y') ?> &bull; Hüseyin Canlı Hosting Paneli
  </footer>

</body>
</html>
