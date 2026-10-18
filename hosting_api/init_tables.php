<?php
/**
 * GymTrack - Veritabanı Tablo Başlatıcı ve Otomatik Tohumlama (Seeding)
 * Bu dosya veritabanında tablolar (exercises, workout_routines, foods) eksikse otomatik oluşturur
 * ve boşsa varsayılan antrenmanları, egzersizleri ve resimli besinleri MySQL'e ekler.
 */

function init_gymtrack_tables($conn) {
    try {
        // 1. users tablosu
        $conn->exec("CREATE TABLE IF NOT EXISTS `users` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `user_id` VARCHAR(64) NOT NULL UNIQUE,
          `name` VARCHAR(100) NOT NULL,
          `email` VARCHAR(150) NOT NULL UNIQUE,
          `password_hash` VARCHAR(255) NOT NULL,
          `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
          `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
          `metadata` TEXT DEFAULT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        // 2. exercises tablosu
        $conn->exec("CREATE TABLE IF NOT EXISTS `exercises` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `exercise_id` VARCHAR(64) NOT NULL UNIQUE,
          `name` VARCHAR(150) NOT NULL,
          `muscle_group` VARCHAR(50) NOT NULL DEFAULT 'chest',
          `thumbnail_url` TEXT DEFAULT NULL,
          `video_url` TEXT DEFAULT NULL,
          `instructions` TEXT DEFAULT NULL,
          `tips` TEXT DEFAULT NULL,
          `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
          `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        // 3. workout_routines tablosu
        $conn->exec("CREATE TABLE IF NOT EXISTS `workout_routines` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `routine_id` VARCHAR(64) NOT NULL UNIQUE,
          `name_tr` VARCHAR(150) NOT NULL,
          `name_en` VARCHAR(150) NOT NULL,
          `desc_tr` TEXT DEFAULT NULL,
          `desc_en` TEXT DEFAULT NULL,
          `split_category` VARCHAR(50) NOT NULL DEFAULT 'PPL',
          `level` VARCHAR(50) NOT NULL DEFAULT 'Orta',
          `estimated_minutes` INT NOT NULL DEFAULT 50,
          `exercise_refs_json` LONGTEXT NOT NULL,
          `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
          `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        // 4. foods tablosu
        $conn->exec("CREATE TABLE IF NOT EXISTS `foods` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `food_id` VARCHAR(64) NOT NULL UNIQUE,
          `name` VARCHAR(150) NOT NULL,
          `category` VARCHAR(100) NOT NULL DEFAULT 'Et & Protein',
          `calories` DECIMAL(8,2) NOT NULL DEFAULT 0.00,
          `protein` DECIMAL(8,2) NOT NULL DEFAULT 0.00,
          `carbs` DECIMAL(8,2) NOT NULL DEFAULT 0.00,
          `fat` DECIMAL(8,2) NOT NULL DEFAULT 0.00,
          `image_url` TEXT DEFAULT NULL,
          `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
          `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;");

        // --- EXERCISES TOHUMLAMA (Eğer boşsa) ---
        $exCount = $conn->query("SELECT COUNT(*) FROM `exercises`")->fetchColumn();
        if ($exCount == 0) {
            $defaultExercises = [
                ['ex_1', 'Barbell Bench Press', 'chest', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-doing-bench-presses-with-a-barbell-41617-large.mp4', 'Sırtüstü sehpaya uzanın. Barı omuz genişliğinden biraz daha geniş tutun. Kontrollü şekilde göğsünüze indirin ve patlayıcı güçle yukarı itin.', 'Bileklerinizi bükmeyin ve kürek kemiklerinizi sehpa üzerinde sıkı tutun.'],
                ['ex_2', 'Barbell Back Squat', 'legs', 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-athlete-working-out-with-a-barbell-41613-large.mp4', 'Barı trapez kaslarınızın üzerine yerleştirin. Ayaklarınızı omuz genişliğinde açın. Kalçanızı geriye vererek dizleriniz 90 derece olana kadar çömelin.', 'Dizlerinizin ayak parmak uçlarının çok önüne geçmesine izin vermeyin, göğsünüzü dik tutun.'],
                ['ex_3', 'Deadlift', 'back', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-lifting-weights-in-a-gym-41615-large.mp4', 'Barın hemen önüne geçin. Sırtınızı düz tutarak kalçadan eğilin ve barı kavrayın. Bacak ve sırt kaslarınızla ağırlığı kaldırarak dik konuma gelin.', 'Omurganızı asla yuvarlamayın, nefesinizi karnınıza kilitleyin.'],
                ['ex_4', 'Overhead Shoulder Press', 'shoulders', 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-athletic-man-lifting-barbell-overhead-41618-large.mp4', 'Barı köprücük kemiği hizasında tutun. Karın ve kalçayı sıkarak barı başınızın üzerine doğru itin.', 'Beli aşırı arkaya bükmekten kaçının.'],
                ['ex_5', 'Barbell Bicep Curl', 'arms', 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-young-man-training-with-dumbbells-41611-large.mp4', 'Dirseklerinizi gövdenize sabitleyin. Ağırlığı kontrollü bir şekilde göğse doğru kaldırın ve yavaşça indirin.', 'Belden kuvvet alıp sallanmayın.'],
                ['ex_6', 'Dumbbell Lateral Raise', 'shoulders', 'https://images.unsplash.com/photo-1534367507873-d2d7e24c797f?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-lifting-dumbbells-in-a-gym-41619-large.mp4', 'Dambılları yanlara doğru omuz hizasına kadar kaldırın. Dirsekleri hafif bükük tutun.', 'Ağırlığı savurmayın, inişi 2 saniye yavaşlatın.'],
                ['ex_7', 'Lat Pulldown', 'back', 'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-lat-pulldown-exercise-41620-large.mp4', 'Geniş tutuşla barı kavrayın ve göğsün üst kısmına doğru çekin.', 'Sırtınızı geriye aşırı yatırmayın, kanat kaslarınızı sıkın.'],
                ['ex_8', 'Incline Dumbbell Press', 'chest', 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-exercising-with-dumbbells-on-a-bench-41621-large.mp4', '30-45 derece eğimli sehpaya uzanın. Dambılları üst göğüs hizasında yukarı itin ve yavaşça indirin.', 'Üst göğüs kaslarını tepe noktada 1 saniye sıkın.'],
                ['ex_9', 'Triceps Rope Pushdown', 'arms', 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-athlete-training-triceps-in-the-gym-41622-large.mp4', 'Halatı iki yandan kavrayın, dirsekleri gövdeye sabitleyin ve aşağı doğru iterek uçları iki yana açın.', 'Dirseklerin ileri geri oynamasına izin vermeyin.'],
                ['ex_10', 'Leg Press', 'legs', 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-working-out-on-leg-press-machine-41623-large.mp4', 'Ayaklarınızı platforma omuz genişliğinde yerleştirin. Ağırlığı kontrollü bükerek dizleri 90 dereceye getirin.', 'Tepe noktada dizlerinizi asla tamamen kilitlemeyin.'],
                ['ex_11', 'Barbell Bent Over Row', 'back', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=500&q=80', 'https://assets.mixkit.co/videos/preview/mixkit-man-lifting-barbell-in-gym-41624-large.mp4', 'Gövdenizi 45 derece öne eğin, barı diz altından göbeğe doğru çekin.', 'Sırtınızı kamburlaştırmayın, karın kaslarınızı sıkı tutun.']
            ];

            $stmt = $conn->prepare("INSERT INTO `exercises` (`exercise_id`, `name`, `muscle_group`, `thumbnail_url`, `video_url`, `instructions`, `tips`) VALUES (?, ?, ?, ?, ?, ?, ?)");
            foreach ($defaultExercises as $e) {
                $stmt->execute($e);
            }
        }

        // --- WORKOUT ROUTINES TOHUMLAMA (Eğer boşsa) ---
        $rtCount = $conn->query("SELECT COUNT(*) FROM `workout_routines`")->fetchColumn();
        if ($rtCount == 0) {
            $defaultRoutines = [
                [
                    'routine_ppl_push',
                    'PPL: İtiş Günü (Push Day)',
                    'PPL: Push Day (Chest & Shoulders)',
                    'Göğüs, ön omuz ve arka kol (Triceps) hipertrofi ve güç seansı.',
                    'Hypertrophy and strength session targeting chest, front delts, and triceps.',
                    'PPL',
                    'Orta',
                    55,
                    json_encode([
                        ['exerciseId' => 'ex_1', 'defaultSets' => 4, 'defaultReps' => 8, 'defaultWeightKg' => 60],
                        ['exerciseId' => 'ex_4', 'defaultSets' => 4, 'defaultReps' => 10, 'defaultWeightKg' => 40],
                        ['exerciseId' => 'ex_6', 'defaultSets' => 3, 'defaultReps' => 12, 'defaultWeightKg' => 10],
                        ['exerciseId' => 'ex_8', 'defaultSets' => 3, 'defaultReps' => 12, 'defaultWeightKg' => 25],
                    ])
                ],
                [
                    'routine_ppl_pull',
                    'PPL: Çekiş Günü (Pull Day)',
                    'PPL: Pull Day (Back & Biceps)',
                    'Sırt kalınlığı, lat genişliği ve biceps tepe noktası gelişimi.',
                    'Back thickness, lat width, and bicep peak development routine.',
                    'PPL',
                    'Orta',
                    50,
                    json_encode([
                        ['exerciseId' => 'ex_3', 'defaultSets' => 4, 'defaultReps' => 6, 'defaultWeightKg' => 80],
                        ['exerciseId' => 'ex_5', 'defaultSets' => 4, 'defaultReps' => 10, 'defaultWeightKg' => 25],
                        ['exerciseId' => 'ex_7', 'defaultSets' => 3, 'defaultReps' => 10, 'defaultWeightKg' => 50],
                    ])
                ],
                [
                    'routine_ppl_legs',
                    'PPL: Bacak Günü (Leg Day)',
                    'PPL: Leg Day (Quads & Hamstrings)',
                    'Quadriceps, hamstring ve kalf kasları için patlayıcı alt gövde çalışması.',
                    'Explosive lower body workout targeting quads, hamstrings, and calves.',
                    'PPL',
                    'İleri',
                    60,
                    json_encode([
                        ['exerciseId' => 'ex_2', 'defaultSets' => 4, 'defaultReps' => 8, 'defaultWeightKg' => 70],
                        ['exerciseId' => 'ex_3', 'defaultSets' => 3, 'defaultReps' => 8, 'defaultWeightKg' => 75],
                        ['exerciseId' => 'ex_10', 'defaultSets' => 3, 'defaultReps' => 12, 'defaultWeightKg' => 100],
                    ])
                ],
                [
                    'routine_upper_power',
                    'Üst Vücut Güç (Upper Body)',
                    'Upper Body Power & Tone',
                    'Tüm üst gövde kas gruplarını dengeli ve yoğun şekilde uyarır.',
                    'Balanced and intense stimulation for all upper body muscle groups.',
                    'Upper/Lower',
                    'Başlangıç / Orta',
                    50,
                    json_encode([
                        ['exerciseId' => 'ex_1', 'defaultSets' => 3, 'defaultReps' => 10, 'defaultWeightKg' => 50],
                        ['exerciseId' => 'ex_4', 'defaultSets' => 3, 'defaultReps' => 10, 'defaultWeightKg' => 35],
                        ['exerciseId' => 'ex_5', 'defaultSets' => 3, 'defaultReps' => 12, 'defaultWeightKg' => 20],
                    ])
                ],
                [
                    'routine_5x5_strength',
                    '5x5 Güç & Kütle Programı',
                    '5x5 Strength & Mass Program',
                    'Temel bileşik (compound) hareketlerle maksimum kuvvet artışı.',
                    'Maximum strength gains using foundational compound movements.',
                    '5x5',
                    'İleri',
                    65,
                    json_encode([
                        ['exerciseId' => 'ex_2', 'defaultSets' => 5, 'defaultReps' => 5, 'defaultWeightKg' => 80],
                        ['exerciseId' => 'ex_1', 'defaultSets' => 5, 'defaultReps' => 5, 'defaultWeightKg' => 70],
                        ['exerciseId' => 'ex_3', 'defaultSets' => 1, 'defaultReps' => 5, 'defaultWeightKg' => 95],
                    ])
                ],
            ];

            $stmt = $conn->prepare("INSERT INTO `workout_routines` (`routine_id`, `name_tr`, `name_en`, `desc_tr`, `desc_en`, `split_category`, `level`, `estimated_minutes`, `exercise_refs_json`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
            foreach ($defaultRoutines as $r) {
                $stmt->execute($r);
            }
        }

        // --- FOODS TOHUMLAMA (Eğer boşsa) ---
        $fdCount = $conn->query("SELECT COUNT(*) FROM `foods`")->fetchColumn();
        if ($fdCount == 0) {
            $defaultFoods = [
                ['f_1', 'Tavuk Göğsü (Izgara)', 'Et & Protein', 165, 31.0, 0.0, 3.6, 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?auto=format&fit=crop&w=400&q=80'],
                ['f_2', 'Dana Bonfile / Biftek', 'Et & Protein', 250, 26.0, 0.0, 15.0, 'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=400&q=80'],
                ['f_3', 'Somon Balığı (Fırın)', 'Et & Protein', 208, 20.4, 0.0, 13.4, 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=400&q=80'],
                ['f_4', 'Ton Balığı (Konserve, Süzme)', 'Et & Protein', 116, 26.0, 0.0, 1.0, 'https://images.unsplash.com/photo-1501595091296-3aa970afb3ff?auto=format&fit=crop&w=400&q=80'],
                ['f_5', 'Hindi Göğsü', 'Et & Protein', 135, 30.0, 0.0, 1.5, 'https://images.unsplash.com/photo-1516684732162-798a0062be99?auto=format&fit=crop&w=400&q=80'],
                ['f_6', 'Yumurta (Bütün, Haşlanmış)', 'Temel Besin', 155, 13.0, 1.1, 11.0, 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?auto=format&fit=crop&w=400&q=80'],
                ['f_7', 'Yumurta Beyazı', 'Temel Besin', 52, 11.0, 0.7, 0.2, 'https://images.unsplash.com/photo-1587486913049-53fc88980cfc?auto=format&fit=crop&w=400&q=80'],
                ['f_8', 'Lor Peyniri (Yağsız)', 'Süt Ürünleri', 98, 11.0, 3.4, 4.3, 'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=400&q=80'],
                ['f_9', 'Süzme Yoğurt / Greek Yogurt', 'Süt Ürünleri', 97, 10.0, 4.0, 4.5, 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=400&q=80'],
                ['f_10', 'Tam Yağlı Süt', 'Süt Ürünleri', 61, 3.2, 4.8, 3.3, 'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=400&q=80'],
                ['f_11', 'Yulaf Ezmesi', 'Karbonhidrat', 389, 16.9, 66.3, 6.9, 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=400&q=80'],
                ['f_12', 'Pirinç Pilavı (Beyaz)', 'Karbonhidrat', 130, 2.7, 28.2, 0.3, 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=400&q=80'],
                ['f_13', 'Kepekli / Esmer Pirinç', 'Karbonhidrat', 111, 2.6, 23.0, 0.9, 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6?auto=format&fit=crop&w=400&q=80'],
                ['f_14', 'Haşlanmış Patates', 'Karbonhidrat', 87, 1.9, 20.1, 0.1, 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=400&q=80'],
                ['f_15', 'Tatlı Patates', 'Karbonhidrat', 86, 1.6, 20.1, 0.1, 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?auto=format&fit=crop&w=400&q=80'],
                ['f_16', 'Makarna (Haşlanmış)', 'Karbonhidrat', 158, 5.8, 30.9, 0.9, 'https://images.unsplash.com/photo-1551462147-ff29053bfc14?auto=format&fit=crop&w=400&q=80'],
                ['f_17', 'Kırmızı Mercimek (Pişmiş)', 'Bakliyat', 116, 9.0, 20.0, 0.4, 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=400&q=80'],
                ['f_18', 'Haşlanmış Nohut', 'Bakliyat', 164, 8.9, 27.4, 2.6, 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?auto=format&fit=crop&w=400&q=80'],
                ['f_19', 'Muz', 'Meyve', 89, 1.1, 22.8, 0.3, 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=400&q=80'],
                ['f_20', 'Elma', 'Meyve', 52, 0.3, 13.8, 0.2, 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=400&q=80'],
                ['f_21', 'Avokado', 'Sağlıklı Yağlar', 160, 2.0, 8.5, 14.7, 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=400&q=80'],
                ['f_22', 'Çiğ Badem', 'Sağlıklı Yağlar', 579, 21.2, 21.6, 49.9, 'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&w=400&q=80'],
                ['f_23', 'Fıstık Ezmesi (%100 Doğal)', 'Sağlıklı Yağlar', 588, 25.0, 20.0, 50.0, 'https://images.unsplash.com/photo-1568651316499-52e850b5551c?auto=format&fit=crop&w=400&q=80'],
                ['f_24', 'Zeytinyağı (10g / 1 Yemek Kaşığı)', 'Sağlıklı Yağlar', 884, 0.0, 0.0, 100.0, 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=400&q=80'],
                ['f_25', 'Whey Protein Tozu (1 Ölçek ~30g)', 'İçecek & Takviye', 400, 80.0, 6.0, 4.0, 'https://images.unsplash.com/photo-1579722821273-0f6c7d44362f?auto=format&fit=crop&w=400&q=80'],
                ['f_26', 'Filtre Kahve / Sade Americano', 'İçecek', 2, 0.1, 0.0, 0.0, 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80'],
                ['f_27', 'Maden Suyu (Doğal)', 'İçecek', 0, 0.0, 0.0, 0.0, 'https://images.unsplash.com/photo-1523362628745-0c100150b504?auto=format&fit=crop&w=400&q=80'],
                ['f_28', 'Taze Sıkılmış Portakal Suyu', 'İçecek', 45, 0.7, 10.4, 0.2, 'https://images.unsplash.com/photo-1613478223719-2ab802602423?auto=format&fit=crop&w=400&q=80'],
                ['f_29', 'Yeşil Çay', 'İçecek', 1, 0.0, 0.0, 0.0, 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?auto=format&fit=crop&w=400&q=80'],
                ['f_30', 'Hindistan Cevizi Suyu', 'İçecek', 19, 0.7, 3.7, 0.2, 'https://images.unsplash.com/photo-1525385133512-2f3bdd039054?auto=format&fit=crop&w=400&q=80']
            ];

            $stmt = $conn->prepare("INSERT INTO `foods` (`food_id`, `name`, `category`, `calories`, `protein`, `carbs`, `fat`, `image_url`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            foreach ($defaultFoods as $f) {
                $stmt->execute($f);
            }
        }

        return true;
    } catch (PDOException $e) {
        error_log("init_gymtrack_tables error: " . $e->getMessage());
        return false;
    }
}
