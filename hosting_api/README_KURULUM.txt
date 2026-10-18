====================================================================
GYMTRACK - HOSTING CMS & VERİTABANI YÖNETİM REHBERİ
====================================================================

Bu sistem ile GymTrack mobil ve web uygulamasının içindeki tüm önemli verileri:
1. Antrenman Programları ve içerikleri (PPL, Upper/Lower, 5x5, Süre, Setler, Tekrarlar)
2. Egzersizler, Hareket Formları, İpuçları ve Canlı Hareketli GIF'ler
3. Besinler, Kaloriler, Protein / Karbonhidrat / Yağ makroları ve Yemek Görselleri
4. Kayıtlı Üyeler ve Hesap Güvenliği

doğrudan web tarayıcınızdan (https://huseyincanli.com/api/admin.php) veya
phpMyAdmin veritabanınız üzerinden anlık olarak değiştirmenizi sağlar.
Değiştirdiğiniz her veri, uygulamayı kullanan tüm üyelerin ekranına otomatik yansır!

--------------------------------------------------------------------
DOSYALAR VE GÖREVLERİ (hosting_api klasörü)
--------------------------------------------------------------------
1. `admin.php`: Web tabanlı Yönetici & CMS Paneli. (Sekmeler: Üyeler, Antrenmanlar, Egzersizler & GIF'ler, Besinler & Kalori, Veritabanı)
2. `get_content.php`: Uygulamanın veritabanından güncel antrenman, egzersiz ve besinleri çektiği yüksek hızlı JSON API.
3. `init_tables.php`: Veritabanında tablolar (exercises, workout_routines, foods) yoksa otomatik oluşturan ve boşsa tüm standart verileri/resimleri yükleyen akıllı başlatıcı.
4. `db.php`: Canlı hosting veritabanı bağlantı ayarları (CORS ve PDO).
5. `register.php`: Mobil ve web'den yeni üye kayıt endpoint'i.
6. `login.php`: Güvenli Bcrypt şifre doğrulama ve giriş endpoint'i.
7. `schema.sql`: İsteğe bağlı olarak phpMyAdmin'den manuel çalıştırmak isteyenler için SQL şeması.

--------------------------------------------------------------------
CPANEL DOSYA YÜKLEME ADIMLARI
--------------------------------------------------------------------
1. Hosting cPanel'e giriş yapın -> "Dosya Yöneticisi" (File Manager) açın.
2. `public_html/api` klasörüne gidin.
3. Bu klasördeki dosyaları (`admin.php`, `get_content.php`, `init_tables.php`, `schema.sql`) yükleyip mevcutların üzerine yazdırın.
4. Tarayıcınızdan şu linke gidin:
   https://huseyincanli.com/api/admin.php
5. Giriş yapın:
   - E-Posta: huseyincanli@gmail.com
   - Şifre: 15715799

Tebrikler! Artık uygulamanın tüm egzersizlerini, GIF'lerini, antrenman programlarını
ve resimli besinlerini tek tıkla tarayıcınızdan düzenleyebilirsiniz! 🚀
====================================================================
