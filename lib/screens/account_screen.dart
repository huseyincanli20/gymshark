import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/device_image_picker.dart';
import '../services/cloud_auth_service.dart';
import '../utils/app_locale.dart';
import 'exercise_edit_dialog.dart';
import 'exercise_web_sync_modal.dart';
import 'achievements_screen.dart';
import 'measurements_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isRegisterMode = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final profile = UserSession.current;

  Future<void> _handleAuthSubmit() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_isRegisterMode && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreniz en az 6 karakter olmalıdır."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isRegisterMode) {
        // Doğrudan sunucu veritabanına kaydet
        await CloudAuthService.instance.registerUserToCloud(
          name: name.isNotEmpty ? name : 'Sporcu',
          email: email,
          password: password,
          initialProfile: {
            'heightCm': profile.heightCm,
            'weightKg': profile.weightKg,
            'gender': profile.gender,
            'age': profile.age,
            'targetWeightKg': profile.targetWeightKg,
          },
        );
      } else {
        // GİRİŞ YAP MODU: Şifre ve kimlik doğrulaması
        final verifiedUser = await CloudAuthService.instance.verifyCredentials(email, password);
        if (verifiedUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Hatalı e-posta veya şifre! Lütfen bilgilerinizi kontrol edin."),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return; // Hatalı şifrede kesinlikle giriş yapılması engellenir!
        }
      }

      // Yönetici (Admin) Kimlik Kontrolü
      final isAdminCredentials = email.toLowerCase() == 'huseyincanli@gmail.com' && password == '15715799';

      setState(() {
        profile.isLoggedIn = true;
        profile.email = email;
        if (isAdminCredentials) {
          profile.name = "Hüseyin Canlı";
        } else if (_isRegisterMode && name.isNotEmpty) {
          profile.name = name;
        }
      });
      profile.saveToPrefs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAdminCredentials
                ? "👑 Yönetici Girişi Başarılı! Hoş geldiniz Hüseyin Canlı (Egzersiz Düzenleme Yetkisi Aktif)"
                : (_isRegisterMode 
                    ? "Hesabınız başarıyla oluşturuldu ve veritabanına kaydedildi! 🚀" 
                    : "Giriş başarılı! Hoş geldiniz 🎉")),
            backgroundColor: isAdminCredentials ? Colors.amber.shade800 : AppTheme.accent,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                profile.isLoggedIn = false;
              });
              profile.saveToPrefs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Oturum kapatıldı. İstediğinizde tekrar giriş yapabilirsiniz.")),
              );
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.isLoggedIn
            ? AppLocale.get('account_title')
            : (_isRegisterMode ? AppLocale.get('tab_register') : AppLocale.get('tab_login'))),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns_rounded, color: Colors.lightBlueAccent),
            tooltip: "Hosting API Ayarı 🌐",
            onPressed: _showHostingConfigDialog,
          ),
          if (profile.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: AppLocale.get('logout'),
              onPressed: _handleLogout,
            ),
        ],
      ),
      body: profile.isLoggedIn ? _buildProfileContent() : _buildLoginForm(),
    );
  }

  // --- GİRİŞ / KAYIT FORMU ---
  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isRegisterMode ? Icons.person_add_alt_1_rounded : Icons.account_circle,
                size: 70,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isRegisterMode ? AppLocale.get('register_title') : AppLocale.get('login_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _isRegisterMode
                  ? AppLocale.get('register_subtitle')
                  : AppLocale.get('login_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Giriş / Kayıt Geçiş Tabı
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRegisterMode = false;
                          _emailController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isRegisterMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            AppLocale.get('tab_login'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !_isRegisterMode ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isRegisterMode = true;
                          _emailController.clear();
                          _passwordController.clear();
                          _nameController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isRegisterMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            AppLocale.get('tab_register'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isRegisterMode ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_isRegisterMode) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocale.get('input_fullname'),
                  prefixIcon: const Icon(Icons.badge_outlined, color: AppTheme.primary),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocale.get('input_email'),
                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primary),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: AppLocale.get('input_password'),
                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLoading ? null : _handleAuthSubmit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        _isRegisterMode ? AppLocale.get('btn_register') : AppLocale.get('btn_login'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GİRİŞ YAPILMIŞ PROFİL VE AYARLAR ---
  Widget _buildProfileContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Profil Başlık Kartı
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showPhotoPickerModal,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primary.withOpacity(0.2),
                        backgroundImage: profile.avatarImage,
                        child: profile.avatarImage == null
                            ? const Icon(Icons.person, size: 36, color: AppTheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(profile.email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text("Aktif Üye", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 11)),
                )
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 1. SAĞLIK AYRINTILARI
        _buildSectionHeader(AppLocale.get('sec_health'), Icons.favorite_rounded, Colors.redAccent),
        Card(
          child: Column(
            children: [
              _buildTile(AppLocale.get('height'), "${profile.heightCm.toInt()} ${profile.heightUnit}", Icons.height, () {
                _showEditDialog("${AppLocale.get('height')} (${profile.heightUnit})", profile.heightCm.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newHeight: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('weight'), "${profile.weightKg} ${profile.weightUnit}", Icons.monitor_weight_outlined, () {
                _showEditDialog("${AppLocale.get('weight')} (${profile.weightUnit})", profile.weightKg.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newWeight: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('age'), "${profile.age}", Icons.cake_outlined, () {
                _showEditDialog(AppLocale.get('age'), profile.age.toString(), (val) {
                  final v = int.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newAge: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('gender'), profile.gender, Icons.transgender, () {
                _showGenderPicker();
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('blood_group'), profile.bloodGroup, Icons.bloodtype, () {
                _showBloodGroupPicker();
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. HEDEFLER
        _buildSectionHeader(AppLocale.get('sec_goals'), Icons.track_changes_rounded, Colors.amber),
        Card(
          child: Column(
            children: [
              _buildTile(AppLocale.get('target_weight'), "${profile.targetWeightKg} ${profile.weightUnit}", Icons.flag_outlined, () {
                _showEditDialog("${AppLocale.get('target_weight')} (${profile.weightUnit})", profile.targetWeightKg.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newTargetWeight: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('daily_calorie_goal'), "${profile.dailyCalorieGoal.toInt()} ${profile.energyUnit}", Icons.local_fire_department_outlined, () {
                _showEditDialog(AppLocale.get('daily_calorie_goal'), profile.dailyCalorieGoal.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newDailyCalorie: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('daily_water_goal'), "${profile.dailyWaterGoalLiters} L", Icons.water_drop_outlined, () {
                _showEditDialog(AppLocale.get('daily_water_goal'), profile.dailyWaterGoalLiters.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newDailyWater: v));
                });
              }),
              _buildDivider(),
              _buildTile(AppLocale.get('weekly_workout_days'), "${profile.weeklyWorkoutDays}", Icons.calendar_month_outlined, () {
                _showEditDialog(AppLocale.get('weekly_workout_days'), profile.weeklyWorkoutDays.toString(), (val) {
                  final v = int.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newWeeklyWorkouts: v));
                });
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. BİLDİRİMLER
        _buildSectionHeader(AppLocale.get('sec_notifications'), Icons.notifications_rounded, AppTheme.accent),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(AppLocale.get('notif_workout')),
                subtitle: Text(profile.language == 'en' ? "Don't miss planned workout days" : "Planlanan günlerde antrenmanı kaçırma", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.workoutReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.workoutReminders = val),
              ),
              _buildDivider(),
              SwitchListTile(
                title: Text(AppLocale.get('notif_meal')),
                subtitle: Text(profile.language == 'en' ? "Reminders to log meals" : "Öğün loglamayı hatırlatan bildirimler", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.mealReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.mealReminders = val),
              ),
              _buildDivider(),
              SwitchListTile(
                title: Text(AppLocale.get('notif_water')),
                subtitle: Text(profile.language == 'en' ? "Hydration & water reminders" : "Düzenli su içme bildirimleri", style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.waterReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.waterReminders = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. ÖLÇÜ BİRİMLERİ & DİL
        _buildSectionHeader(AppLocale.get('sec_units'), Icons.straighten_rounded, AppTheme.fatColor),
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(AppLocale.get('unit_weight')),
                trailing: DropdownButton<String>(
                  value: profile.weightUnit,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'kg', child: Text("Kilogram (kg)")),
                    DropdownMenuItem(value: 'lbs', child: Text("Pound (lbs)")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => profile.weightUnit = val);
                  },
                ),
              ),
              _buildDivider(),
              ListTile(
                title: Text(AppLocale.get('unit_height')),
                trailing: DropdownButton<String>(
                  value: profile.heightUnit,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'cm', child: Text("Santimetre (cm)")),
                    DropdownMenuItem(value: 'inch', child: Text("İnç (in)")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => profile.heightUnit = val);
                  },
                ),
              ),
              _buildDivider(),
              ListTile(
                title: Text(AppLocale.get('unit_energy')),
                trailing: DropdownButton<String>(
                  value: profile.energyUnit,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'kcal', child: Text("Kalori (kcal)")),
                    DropdownMenuItem(value: 'kJ', child: Text("Kilojoule (kJ)")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => profile.energyUnit = val);
                      profile.saveToPrefs();
                    }
                  },
                ),
              ),
              _buildDivider(),
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppTheme.accent),
                title: Text(AppLocale.get('language_setting')),
                subtitle: Text(
                  profile.language == 'en' ? "English (English)" : "Türkçe (Turkish)",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                trailing: DropdownButton<String>(
                  value: profile.language,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'tr', child: Text("🇹🇷 Türkçe (TR)")),
                    DropdownMenuItem(value: 'en', child: Text("🇺🇸 English (EN)")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        profile.setLanguage(val);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val == 'tr' ? "Dil Türkçe olarak güncellendi 🇹🇷" : "Language set to English 🇺🇸"),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 5. UYGULAMA TEMASI & VURGU RENGİ
        _buildSectionHeader(AppLocale.get('theme_selector'), Icons.palette_rounded, AppTheme.getPrimaryFor(profile.themeKey)),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.isEnglish ? "Choose accent color" : "Uygulama vurgu rengini seçin",
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildThemeOption('cyan', const Color(0xFF00E5FF), 'Cyan'),
                    _buildThemeOption('red', const Color(0xFFFF3B30), 'Red'),
                    _buildThemeOption('gold', const Color(0xFFFFD700), 'Gold'),
                    _buildThemeOption('emerald', const Color(0xFF00E676), 'Emerald'),
                    _buildThemeOption('purple', const Color(0xFFD500F9), 'Purple'),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // 6. BAŞARI ROZETLERİ & MEZURA TAKİBİ
        _buildSectionHeader(AppLocale.isEnglish ? "Milestones & Measurements" : "Başarılar & Vücut Takibi", Icons.military_tech_rounded, Colors.amber),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.military_tech_rounded, color: Colors.amber),
                ),
                title: Text(AppLocale.get('badges_title'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(AppLocale.get('badges_subtitle'), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                  );
                },
              ),
              _buildDivider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.straighten_rounded, color: Color(0xFF00E676)),
                ),
                title: Text(AppLocale.get('measurements_title'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text(AppLocale.get('compare_photos_title'), style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MeasurementsScreen()),
                  );
                },
              ),
            ],
          ),
        ),

        if (profile.isAdmin) ...[
          const SizedBox(height: 20),

          // 7. EGZERSİZLER & İNTERNET SENKRONİZASYONU (SADECE YÖNETİCİYE ÖZEL)
          _buildSectionHeader(AppLocale.get('sec_exercise_mgmt'), Icons.admin_panel_settings_rounded, Colors.amber),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.amber, width: 1.2),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sync_alt_rounded, color: Colors.amber),
                  ),
                  title: const Text("İnternet Sitesinden Senkronize Et", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Web sitesi API veya JSON üzerinden egzersiz ve GIF çekin", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.amber, size: 20),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const ExerciseWebSyncModal(),
                    );
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primary),
                  ),
                  title: const Text("Yeni Egzersiz / GIF Ekle", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Özel hareket, form talimatı ve .gif linki tanımlayın", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.add_circle, color: AppTheme.primary, size: 22),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => const ExerciseEditDialog(),
                    );
                  },
                ),
                _buildDivider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.dns_rounded, color: Colors.lightBlueAccent),
                  ),
                  title: const Text("Özel Hosting & Veritabanı API'si", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Kullanıcı kayıt ve şifrelerinin saklanacağı sunucu adresi", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  trailing: const Icon(Icons.settings, color: Colors.lightBlueAccent, size: 20),
                  onTap: _showHostingConfigDialog,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),

        // 6. HAKKIMIZDA
        _buildSectionHeader("Hakkımızda", Icons.info_outline_rounded, AppTheme.primary),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.code_rounded, color: AppTheme.primary),
                ),
                title: const Text("Geliştirici", style: TextStyle(fontSize: 14)),
                trailing: const Text(
                  "Hüseyin Canlı",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary),
                ),
              ),
              _buildDivider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppTheme.accent),
                ),
                title: const Text("Uygulama"),
                trailing: const Text(
                  "GymTrack v1.0.0",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary),
                ),
              ),
              _buildDivider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "GymTrack; sporcuların antrenman, beslenme, kalori ve sağlık gelişimlerini profesyonelce takip edebilmeleri için Flutter ile geliştirilmiştir.",
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildThemeOption(String key, Color color, String name) {
    final isSelected = profile.themeKey == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          profile.setTheme(key);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocale.isEnglish ? "Theme updated to $name 🎨" : "Tema $name olarak ayarlandı! 🎨"),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: color,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTile(String title, String value, IconData icon, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          if (onTap != null) const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 18),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppTheme.surfaceColor, indent: 16, endIndent: 16);
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final options = ['Erkek', 'Kadın', 'Diğer / Belirtmek İstemiyorum'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Cinsiyet Seçin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(height: 1),
              ...options.map((g) {
                final isSelected = profile.gender == g;
                return ListTile(
                  title: Text(g, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppTheme.accent) : null,
                  onTap: () {
                    setState(() {
                      profile.updateProfile(newGender: g);
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBloodGroupPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final options = ['A Rh+', 'A Rh-', 'B Rh+', 'B Rh-', 'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Kan Grubu Seçin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: options.map((bg) {
                    final isSelected = profile.bloodGroup == bg;
                    return ListTile(
                      title: Text(bg, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.accent) : null,
                      onTap: () {
                        setState(() {
                          profile.updateProfile(newBloodGroup: bg);
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageFromDevice() {
    pickDeviceImage((base64Result) {
      if (base64Result.isNotEmpty) {
        setState(() {
          profile.updateProfile(newCustomPhotoBase64: base64Result);
        });
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Telefonunuzdaki fotoğraf profil resmi yapıldı! 📸✨"),
              backgroundColor: AppTheme.accent,
            ),
          );
        }
      }
    });
  }

  void _showPhotoPickerModal() {
    final avatarList = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Profil Fotoğrafı Seç", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),

              // Telefon Galerisinden Yükleme Butonu
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                  label: const Text(
                    "Telefonumdaki Fotoğraflardan Seç",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: _pickImageFromDevice,
                ),
              ),

              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white12)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("veya hazır avatarlardan seç", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.white12)),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    final photo = avatarList[index];
                    final isCurrent = profile.photoUrl == photo && (profile.customPhotoBase64 == null || profile.customPhotoBase64!.isEmpty);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          profile.updateProfile(newPhotoUrl: photo);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profil fotoğrafınız güncellendi! 📸"), backgroundColor: AppTheme.accent),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? AppTheme.accent : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: NetworkImage(photo),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showHostingConfigDialog() async {
    final currentUrl = await CloudAuthService.instance.getHostingUrl();
    final controller = TextEditingController(text: currentUrl);
    String? statusMessage;
    bool isTesting = false;
    bool? testSuccess;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.dns_rounded, color: Colors.lightBlueAccent),
              SizedBox(width: 8),
              Text("Özel Hosting API", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Aldığınız web hostingteki 'api' klasörünün tam web adresini girin. Kullanıcı adları, e-postalar ve şifreler bu sunucudaki MySQL veritabanına kaydedilir.",
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Hosting API URL",
                    hintText: "https://siteniz.com/api",
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.link, size: 20, color: Colors.lightBlueAccent),
                  ),
                ),
                const SizedBox(height: 12),
                if (statusMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: testSuccess == true
                          ? Colors.greenAccent.withOpacity(0.15)
                          : Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: testSuccess == true ? Colors.greenAccent : Colors.redAccent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          testSuccess == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                          size: 18,
                          color: testSuccess == true ? Colors.greenAccent : Colors.redAccent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusMessage!,
                            style: TextStyle(
                              fontSize: 11,
                              color: testSuccess == true ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.lightBlueAccent,
                      side: const BorderSide(color: Colors.lightBlueAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isTesting
                        ? null
                        : () async {
                            final inputUrl = controller.text.trim();
                            if (inputUrl.isEmpty) {
                              setDialogState(() {
                                statusMessage = "Lütfen bir URL adresi girin.";
                                testSuccess = false;
                              });
                              return;
                            }
                            setDialogState(() {
                              isTesting = true;
                              statusMessage = null;
                            });
                            final result = await CloudAuthService.instance.testHostingConnection(inputUrl);
                            setDialogState(() {
                              isTesting = false;
                              testSuccess = result['success'] == true;
                              statusMessage = result['message'];
                            });
                          },
                    icon: isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.lightBlueAccent),
                          )
                        : const Icon(Icons.wifi_tethering_rounded, size: 18),
                    label: Text(isTesting ? "Test Ediliyor..." : "Bağlantıyı Test Et"),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogCtx);
                await CloudAuthService.instance.setHostingUrl(null);
                nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text("Hosting adresi sıfırlandı. Yerel kasa devrede.")),
                );
              },
              child: const Text("Sıfırla", style: TextStyle(color: Colors.redAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogCtx);
                final url = controller.text.trim();
                await CloudAuthService.instance.setHostingUrl(url.isEmpty ? null : url);
                nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(url.isEmpty
                        ? "Hosting adresi kaldırıldı."
                        : "Hosting adresi başarıyla kaydedildi! ($url) 🌐"),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              },
              child: const Text("Kaydet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
