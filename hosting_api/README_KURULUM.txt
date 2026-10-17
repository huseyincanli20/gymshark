====================================================================
GYMTRACK - HOSTING & VERİTABANI KURULUM REHBERİ (ADIM ADIM)
====================================================================

Bu rehber, GymTrack uygulamasındaki üye kayıtlarını ve şifreleri kendi
aldığınız web hosting hizmetindeki MySQL veritabanına kaydetmeniz için
hazırlanmıştır.

--------------------------------------------------------------------
ADIM 1: Veritabanı ve Kullanıcı Oluşturma (cPanel / Plesk)
--------------------------------------------------------------------
1. Hosting kontrol panelinize (cPanel veya Plesk) giriş yapın.
2. "MySQL Veritabanları" (MySQL Databases) bölümüne gidin.
3. Yeni bir veritabanı oluşturun (Örn: `gymtrack_db`).
4. Yeni bir MySQL kullanıcısı oluşturun (Örn: `gymtrack_user`) ve güçlü bir şifre belirleyin.
5. "Veritabanına Kullanıcı Ekle" bölümünden oluşturduğunuz kullanıcıyı veritabanına ekleyin ve "TÜM AYRICALIKLAR" (ALL PRIVILEGES) seçeneğini işaretleyip kaydedin.

--------------------------------------------------------------------
ADIM 2: Tabloyu Oluşturma (phpMyAdmin)
--------------------------------------------------------------------
1. cPanel ana sayfasına dönüp "phpMyAdmin" simgesine tıklayın.
2. Sol menüden 1. adımda oluşturduğunuz veritabanını seçin.
3. Üst menüdeki "SQL" sekmesine tıklayın.
4. `schema.sql` dosyasının içindeki SQL kodunu kopyalayıp buraya yapıştırın ve "Git" (Go) butonuna basın.
   (`users` tablosu başarıyla oluşturulacaktır).

--------------------------------------------------------------------
ADIM 3: db.php Dosyasını Düzenleme
--------------------------------------------------------------------
`db.php` dosyasını Not Defteri veya herhangi bir editör ile açın:
- `$db_name = "VERITABANI_ADINIZ";` -> 1. adımda açtığınız veritabanı adını yazın.
- `$db_user = "VERITABANI_KULLANICI_ADINIZ";` -> 1. adımdaki kullanıcı adını yazın.
- `$db_pass = "VERITABANI_SIFRENIZ";` -> Belirlediğiniz şifreyi yazın.
Dosyayı kaydedin.

--------------------------------------------------------------------
ADIM 4: Dosyaları Hostinginize Yükleme
--------------------------------------------------------------------
1. cPanel'den "Dosya Yöneticisi" (File Manager) bölümüne girin.
2. `public_html` klasörünü açın.
3. İçine `api` adında yeni bir klasör oluşturun (Yol: `public_html/api/`).
4. Bu klasör içine aşağıdaki 4 dosyayı yükleyin:
   - `db.php`
   - `register.php`
   - `login.php`
   - `test_connection.php`

--------------------------------------------------------------------
ADIM 5: Test Edin!
--------------------------------------------------------------------
İnternet tarayıcınızı açın ve şu adrese gidin:
https://siteniz.com/api/test_connection.php
(siteniz.com yerine kendi alan adınızı yazın)

Ekranda şu yazıyı görüyorsanız her şey kusursuz çalışıyor demektir:
{"success":true,"message":"Tebrikler! GymTrack Hosting API ve Veritabanı başarıyla çalışıyor! 🚀"}

--------------------------------------------------------------------
ADIM 6: Uygulamaya Bağlama
--------------------------------------------------------------------
GymTrack uygulamasını açın -> Hesap / Yönetici Ayarları -> "Özel Hosting Bağlantısı"
bölümüne alan adınızın API adresini yazın:
Örn: https://siteniz.com/api

Artık tüm kullanıcılar doğrudan sizin hostinginize kaydolacak ve giriş yapacaktır!
Şifreler Bcrypt algoritmasıyla tek yönlü ve şifreli saklanır.
====================================================================
