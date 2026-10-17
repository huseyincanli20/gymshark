import '../models/user_profile.dart';

/// GymTrack İki Dilli (Türkçe 🇹🇷 / İngilizce 🇺🇸) Çeviri ve Yerelleştirme Sözlüğü
class AppLocale {
  static String get currentLang => UserSession.current.language;
  static bool get isEnglish => currentLang == 'en';

  static String get(String key) {
    if (isEnglish) {
      return _en[key] ?? _tr[key] ?? key;
    }
    return _tr[key] ?? key;
  }

  // --- TÜRKÇE SÖZLÜK ---
  static const Map<String, String> _tr = {
    // Alt Navigasyon
    'nav_home': 'Ana Sayfa',
    'nav_workout': 'Antrenman',
    'nav_nutrition': 'Beslenme',
    'nav_progress': 'İlerleme',

    // Genel Butonlar ve Durumlar
    'save': 'Kaydet',
    'cancel': 'İptal',
    'delete': 'Sil',
    'edit': 'Düzenle',
    'close': 'Kapat',
    'search': 'Ara...',
    'reset': 'Sıfırla',
    'apply': 'Uygula',
    'skip': 'Atla',
    'done': 'BİTTİ',
    'active_member': 'Aktif Üye',
    'admin_badge': '👑 Yönetici',
    'loading': 'Yükleniyor...',

    // Giriş & Kayıt Ekranı
    'login_title': 'GymTrack Hesabınıza Giriş Yapın',
    'register_title': "GymTrack'e Kayıt Olun",
    'login_subtitle': 'Sağlık detaylarınız, antrenman hedefleriniz ve tercihleriniz senkronize edilsin.',
    'register_subtitle': 'Sağlık ve antrenman yolculuğunuza hemen başlayın.',
    'tab_login': 'Giriş Yap',
    'tab_register': 'Kayıt Ol',
    'input_fullname': 'Ad Soyad',
    'input_email': 'E-Posta',
    'input_password': 'Şifre',
    'btn_login': 'Giriş Yap',
    'btn_register': 'Kayıt Ol ve Başla',
    'logout': 'Çıkış Yap',
    'logout_confirm': 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',

    // Profil & Ayarlar Başlıkları
    'account_title': 'Hesabım ve Ayarlar',
    'sec_health': 'Sağlık Ayrıntıları',
    'sec_goals': 'Hedefler',
    'sec_notifications': 'Bildirimler',
    'sec_units': 'Ölçü Birimleri & Dil',
    'sec_exercise_mgmt': 'Egzersiz & Form Yönetimi (Yönetici)',
    'sec_about': 'Hakkımızda',

    // Sağlık & Hedef Alanları
    'height': 'Boy',
    'weight': 'Kilo',
    'age': 'Yaş',
    'gender': 'Cinsiyet',
    'blood_group': 'Kan Grubu',
    'target_weight': 'Hedef Kilo',
    'daily_calorie_goal': 'Günlük Kalori Hedefi',
    'daily_water_goal': 'Günlük Su Hedefi',
    'weekly_workout_days': 'Haftalık Antrenman Hedefi',

    // Bildirim ve Birimler
    'notif_workout': 'Antrenman Hatırlatıcı',
    'notif_meal': 'Öğün Takip Hatırlatıcı',
    'notif_water': 'Su Hatırlatıcı',
    'unit_weight': 'Ağırlık Birimi',
    'unit_height': 'Boy Birimi',
    'unit_energy': 'Enerji Birimi',
    'language_setting': 'Dil / Language',

    // Ana Sayfa
    'greeting_welcome': 'Hoş Geldin,',
    'today_summary': 'Bugünün Özeti',
    'calories_burned': 'Yakılan Kalori',
    'steps_taken': 'Günlük Adım',
    'water_consumed': 'İçilen Su',
    'workout_active': 'Antrenman',
    'quick_start': 'Hızlı Başlat',
    'start_workout': 'Antrenmana Başla',
    'start_now': 'Şimdi Başla',
    'todays_workout': 'Günün Antrenmanı',
    'fitness_activity': 'Apple Fitness & Aktivite',
    'sync_fitness': 'Fitness Eşitle',
    'log_meal': 'Öğün Ekle',
    'weekly_activity': 'Haftalık Aktivite',
    'popular_exercises': 'Popüler Egzersizler',
    'view_all': 'Tümünü Gör',
    'days_unit': 'Gün',

    // Su Takibi
    'water_tracker': 'Su Takibi & Hidrasyon',
    'water_goal': 'Günlük Su Hedefi',
    'water_add_200': '+200 ml',
    'water_add_500': '+500 ml',
    'water_add_1000': '+1 Litre',
    'water_reset': 'Suyu Sıfırla',
    'water_congrats': 'Harika! Günlük su hedefine ulaştın! 💧',

    // Antrenman Programları & Rutinler
    'routines_title': 'Programlar & Rutinler',
    'start_routine': 'Bu Programı Başlat',
    'create_routine': 'Yeni Rutin Oluştur',
    'routine_category': 'Kategori',
    'routine_duration': 'Süre',
    'routine_level': 'Seviye',

    // Akıllı Antrenman Araçları
    'gym_tools_title': 'Akıllı Antrenman Araçları',
    'plate_calc': 'Plaka Hesaplayıcı',
    'one_rm_calc': '1RM & Yüzde Tablosu',
    'hiit_timer': 'HIIT / Tabata Zamanlayıcı',
    'barbell_weight': 'Bar Ağırlığı',
    'target_total_weight': 'Hedef Toplam Ağırlık',
    'each_side_plates': 'Her Yana Takılacak Plakalar',
    'work': 'ÇALIŞ',
    'rest': 'DİNLEN',
    'prepare': 'HAZIRLAN',
    'round': 'Tur',

    // AI Koç
    'ai_coach_title': 'GymTrack AI Kişisel Koç',
    'ai_coach_subtitle': 'Kişiye Özel Antrenman & Diyet Planı',
    'ai_generate_routine': 'AI ile Program Oluştur',
    'ai_generate_diet': 'AI Günlük Yemek Planı',
    'ai_quick_advice': 'AI Antrenör Tavsiyesi',
    'apply_to_workout': 'Antrenmana Uygula',

    // Başarı Rozetleri & Oyunlaştırma
    'badges_title': 'Başarı Rozetleri',
    'badges_subtitle': 'Antrenman ve Sağlık Başarıların',
    'unlocked': 'Kazanıldı',
    'locked': 'Kilitli',

    // Mezura & Fotoğraf
    'measurements_title': 'Mezura Ölçümleri',
    'compare_photos_title': 'Önce & Sonra Fotoğraf',
    'add_measurement': 'Yeni Ölçüm Ekle',
    'chest_cm': 'Göğüs',
    'arm_cm': 'Kol (Biceps)',
    'waist_cm': 'Bel',
    'hips_cm': 'Kalça',
    'thigh_cm': 'Bacak (Uyluk)',
    'shoulders_cm': 'Omuz',

    // Sosyal Paylaşım Kartı & Tema
    'share_workout_card': 'Instagram Story Kartı',
    'share_card_title': 'Antrenman Özeti Kartı',
    'lifetime_volume': 'Toplam Yaşam Boyu Tonaj',
    'theme_selector': 'Uygulama Teması',
    'theme_cyan': 'Neon Cyan (Varsayılan)',
    'theme_red': 'Ateş Kırmızısı',
    'theme_gold': 'Altın Şampiyon',
    'theme_emerald': 'Zümrüt Yeşil',
    'theme_purple': 'Siberpunk Mor',

    // Antrenman Ekranı
    'workout_title': 'Canlı Antrenman Takibi',
    'active_session': 'Aktif Antrenman Seansı',
    'add_exercise': 'Egzersiz Ekle',
    'finish_workout': 'Antrenmanı Kaydet & Tamamla',
    'set': 'SET',
    'weight_kg': 'AĞIRLIK',
    'reps': 'TEKRAR',
    'rest_timer': 'Dinlenme Sayacı',
    'add_set': 'Set Ekle',
    'change_image': 'Görseli Değiştir',
    'edit_sets': 'Ağırlık & Set Düzenle',
    'replace_exercise': 'Egzersizi Değiştir',
    'remove_exercise': 'Egzersizi Kaldır',
    'rest_seconds': 'Dinlenme: ',
    'sec_short': 'sn',
    'workout_completed': 'Antrenman Tamamlandı! 🔥',
    'workout_burned_cal': 'Bu Antrenmanda Yakılan Kalori',
    'total_volume': 'Toplam Hacim',
    'back_to_home': 'Harika! Ana Sayfaya Dön',

    // Egzersiz Rehberi
    'exercise_guide_title': 'Egzersiz Rehberi & Formlar',
    'search_exercise': 'Egzersiz veya kas grubu ara...',
    'form_guide': 'Form Rehberi',
    'critical_trainer_tip': 'Kritik Antrenör İpucu',
    'add_to_today_workout': 'Bugünkü Antrenmana Ekle',

    // Beslenme Ekranı
    'nutrition_title': 'Beslenme & Kalori Takibi',
    'daily_budget': 'Günlük Kalori Bütçesi',
    'calories_remaining': 'Kalan',
    'food_search': 'Yiyecek ara veya barkod okut...',
    'barcode_scan': 'Barkod Okut',
    'today_meals': 'Bugünün Öğünleri',
    'add_food': 'Besin Ekle',
    'custom_food': 'Kendi Besinin',
    'reset_meals': 'Öğünleri Sıfırla',
    'no_meals_yet': 'Bugün henüz öğün eklenmedi',
    'no_meals_hint': 'Günlük hedefinize ulaşmak için yukarıdan besin ekleyin veya barkod okutun.',
    'select_grams': 'Gram Seç',
    'add_to_meal': 'Öğüne Ekle',
    'portion_amount': 'Porsiyon / Gramaj Miktarı',
    'protein': 'Protein',
    'carbs': 'Karb',
    'fat': 'Yağ',

    // İlerleme Ekranı
    'progress_title': 'İlerleme ve İstatistikler',
    'current_weight': 'Mevcut Kilo',
    'target_weight_card': 'Hedef Kilo',
    'height_label': 'Boy',
    'diff_label': 'Fark',
    'weight_chart': 'Kilo Değişim Grafiği',
    'reset_chart': 'Grafiği Sıfırla',
    'no_weight_logs': "Henüz kilo kaydı bulunmuyor. '+' butonu ile ekleyebilirsiniz.",
    'personal_records': 'Kişisel Rekorlar (PR)',
    'delete_all': 'Tümünü Sil',
    'no_records_yet': 'Henüz kayıtlı bir rekor yok',
    'no_records_hint': "Canlı antrenman takibinden setlerinizi tamamladığınızda veya '+' butonuna basarak yeni rekor ekleyebilirsiniz.",
    'est_1rm': 'Tahmini 1RM',
  };

  // --- İNGİLİZCE SÖZLÜK ---
  static const Map<String, String> _en = {
    // Navigation
    'nav_home': 'Home',
    'nav_workout': 'Workout',
    'nav_nutrition': 'Nutrition',
    'nav_progress': 'Progress',

    // General Buttons & States
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'search': 'Search...',
    'reset': 'Reset',
    'apply': 'Apply',
    'skip': 'Skip',
    'done': 'DONE',
    'active_member': 'Active Member',
    'admin_badge': '👑 Admin',
    'loading': 'Loading...',

    // Login & Register Screen
    'login_title': 'Sign in to GymTrack',
    'register_title': 'Create your GymTrack Account',
    'login_subtitle': 'Sync your health metrics, workout goals, and preferences.',
    'register_subtitle': 'Start your health and fitness journey right now.',
    'tab_login': 'Sign In',
    'tab_register': 'Register',
    'input_fullname': 'Full Name',
    'input_email': 'Email',
    'input_password': 'Password',
    'btn_login': 'Sign In',
    'btn_register': 'Register & Start',
    'logout': 'Log Out',
    'logout_confirm': 'Are you sure you want to log out of your account?',

    // Profile & Settings Headers
    'account_title': 'Account & Settings',
    'sec_health': 'Health Details',
    'sec_goals': 'Goals',
    'sec_notifications': 'Notifications',
    'sec_units': 'Units & Language',
    'sec_exercise_mgmt': 'Exercise & Form Management (Admin)',
    'sec_about': 'About Us',

    // Health & Goals Fields
    'height': 'Height',
    'weight': 'Weight',
    'age': 'Age',
    'gender': 'Gender',
    'blood_group': 'Blood Group',
    'target_weight': 'Target Weight',
    'daily_calorie_goal': 'Daily Calorie Goal',
    'daily_water_goal': 'Daily Water Goal',
    'weekly_workout_days': 'Weekly Workout Goal',

    // Notifications & Units
    'notif_workout': 'Workout Reminder',
    'notif_meal': 'Meal Tracking Reminder',
    'notif_water': 'Water Reminder',
    'unit_weight': 'Weight Unit',
    'unit_height': 'Height Unit',
    'unit_energy': 'Energy Unit',
    'language_setting': 'Language / Dil',

    // Home Screen
    'greeting_welcome': 'Welcome back,',
    'today_summary': "Today's Summary",
    'calories_burned': 'Calories Burned',
    'steps_taken': 'Daily Steps',
    'water_consumed': 'Water Drank',
    'workout_active': 'Workout',
    'quick_start': 'Quick Start',
    'start_workout': 'Start Workout',
    'start_now': 'Start Now',
    'todays_workout': "Today's Workout",
    'fitness_activity': 'Apple Fitness & Activity',
    'sync_fitness': 'Sync Fitness',
    'log_meal': 'Log Meal',
    'weekly_activity': 'Weekly Activity',
    'popular_exercises': 'Popular Exercises',
    'view_all': 'View All',
    'days_unit': 'Days',

    // Water Tracker
    'water_tracker': 'Water Tracker & Hydration',
    'water_goal': 'Daily Water Goal',
    'water_add_200': '+200 ml',
    'water_add_500': '+500 ml',
    'water_add_1000': '+1 Liter',
    'water_reset': 'Reset Water',
    'water_congrats': 'Awesome! You reached your daily water goal! 💧',

    // Workout Routines
    'routines_title': 'Routines & Programs',
    'start_routine': 'Start This Routine',
    'create_routine': 'Create New Routine',
    'routine_category': 'Category',
    'routine_duration': 'Duration',
    'routine_level': 'Level',

    // Gym Tools
    'gym_tools_title': 'Smart Gym Utilities',
    'plate_calc': 'Plate Calculator',
    'one_rm_calc': '1RM & Percentage Table',
    'hiit_timer': 'HIIT / Tabata Timer',
    'barbell_weight': 'Barbell Weight',
    'target_total_weight': 'Target Total Weight',
    'each_side_plates': 'Plates Per Side',
    'work': 'WORK',
    'rest': 'REST',
    'prepare': 'PREPARE',
    'round': 'Round',

    // AI Coach
    'ai_coach_title': 'GymTrack AI Personal Coach',
    'ai_coach_subtitle': 'Custom Workout & Meal Guidance',
    'ai_generate_routine': 'Generate Workout with AI',
    'ai_generate_diet': 'AI Daily Meal Plan',
    'ai_quick_advice': 'AI Trainer Advice',
    'apply_to_workout': 'Apply to Workout',

    // Badges & Gamification
    'badges_title': 'Achievement Badges',
    'badges_subtitle': 'Your Fitness & Health Milestones',
    'unlocked': 'Unlocked',
    'locked': 'Locked',

    // Measurements & Photos
    'measurements_title': 'Body Measurements',
    'compare_photos_title': 'Before & After Comparison',
    'add_measurement': 'Add New Measurement',
    'chest_cm': 'Chest',
    'arm_cm': 'Arm (Biceps)',
    'waist_cm': 'Waist',
    'hips_cm': 'Hips',
    'thigh_cm': 'Thigh',
    'shoulders_cm': 'Shoulders',

    // Social Share Card & Theme
    'share_workout_card': 'Instagram Story Card',
    'share_card_title': 'Workout Summary Card',
    'lifetime_volume': 'Lifetime Total Volume',
    'theme_selector': 'App Theme',
    'theme_cyan': 'Neon Cyan (Default)',
    'theme_red': 'Crimson Red',
    'theme_gold': 'Cyber Gold',
    'theme_emerald': 'Fit Emerald',
    'theme_purple': 'Neon Purple',

    // Workout Screen
    'workout_title': 'Live Workout Tracker',
    'active_session': 'Active Workout Session',
    'add_exercise': 'Add Exercise',
    'finish_workout': 'Save & Finish Workout',
    'set': 'SET',
    'weight_kg': 'WEIGHT',
    'reps': 'REPS',
    'rest_timer': 'Rest Timer',
    'add_set': 'Add Set',
    'change_image': 'Change Image',
    'edit_sets': 'Edit Sets & Weights',
    'replace_exercise': 'Replace Exercise',
    'remove_exercise': 'Remove Exercise',
    'rest_seconds': 'Rest: ',
    'sec_short': 's',
    'workout_completed': 'Workout Completed! 🔥',
    'workout_burned_cal': 'Calories Burned This Workout',
    'total_volume': 'Total Volume',
    'back_to_home': 'Awesome! Return Home',

    // Exercise Guide
    'exercise_guide_title': 'Exercise Guide & Forms',
    'search_exercise': 'Search exercise or muscle group...',
    'form_guide': 'Form Guide',
    'critical_trainer_tip': 'Critical Trainer Tip',
    'add_to_today_workout': 'Add to Today Workout',

    // Nutrition Screen
    'nutrition_title': 'Nutrition & Calories',
    'daily_budget': 'Daily Calorie Budget',
    'calories_remaining': 'Remaining',
    'food_search': 'Search food or scan barcode...',
    'barcode_scan': 'Scan Barcode',
    'today_meals': "Today's Meals",
    'add_food': 'Add Food',
    'custom_food': 'Custom Food',
    'reset_meals': 'Reset Meals',
    'no_meals_yet': 'No meals logged today',
    'no_meals_hint': 'Add foods above or scan a barcode to reach your daily goal.',
    'select_grams': 'Select Grams',
    'add_to_meal': 'Add to Meal',
    'portion_amount': 'Portion / Gram Amount',
    'protein': 'Protein',
    'carbs': 'Carbs',
    'fat': 'Fat',

    // Progress Screen
    'progress_title': 'Progress & Statistics',
    'current_weight': 'Current Weight',
    'target_weight_card': 'Target Weight',
    'height_label': 'Height',
    'diff_label': 'Diff',
    'weight_chart': 'Weight Change Chart',
    'reset_chart': 'Reset Chart',
    'no_weight_logs': "No weight logs yet. Tap '+' to add your current weight.",
    'personal_records': 'Personal Records (PR)',
    'delete_all': 'Delete All',
    'no_records_yet': 'No personal records logged yet',
    'no_records_hint': "Complete your sets in the Live Workout Tracker or tap '+' to log a new personal record.",
    'est_1rm': 'Est. 1RM',
  };
}
