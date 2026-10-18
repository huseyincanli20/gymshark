-- =================================================================
-- GymTrack MySQL Veritabanı Tablo Şeması & İlk Veri Yükleme (Seed)
-- Hosting cPanel / Plesk phpMyAdmin üzerinden bu SQL kodunu çalıştırabilirsiniz.
-- =================================================================

-- 1. ÜYELER TABLOSU (users)
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` VARCHAR(64) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `metadata` TEXT DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. EGZERSİZLER & GIFLER TABLOSU (exercises)
CREATE TABLE IF NOT EXISTS `exercises` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. ANTRENMAN PROGRAMLARI TABLOSU (workout_routines)
CREATE TABLE IF NOT EXISTS `workout_routines` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. BESİNLER & GÖRSELLERİ TABLOSU (foods)
CREATE TABLE IF NOT EXISTS `foods` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =================================================================
-- İPUCU: admin.php veya get_content.php dosyaları çalıştırıldığında 
-- tablolar otomatik oluşturulup varsayılan verilerle doldurulmaktadır.
-- =================================================================
