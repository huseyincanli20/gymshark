import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isRegisterMode = false;
  final _nameController = TextEditingController(text: 'Hüseyin Canlı');
  final _emailController = TextEditingController(text: 'huseyin@gymtrack.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _obscurePassword = true;

  final profile = UserSession.current;

  void _handleAuthSubmit() {
    setState(() {
      profile.isLoggedIn = true;
      profile.email = _emailController.text.trim();
      if (_isRegisterMode && _nameController.text.trim().isNotEmpty) {
        profile.name = _nameController.text.trim();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isRegisterMode ? "Hesabınız başarıyla oluşturuldu! Hoş geldiniz 🎉" : "Giriş başarılı! Hoş geldiniz 🎉"),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _handleLogout() {
    setState(() {
      profile.isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(profile.isLoggedIn ? "Hesabım & Ayarlar" : (_isRegisterMode ? "Kayıt Ol" : "Giriş Yap")),
        actions: [
          if (profile.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: "Çıkış Yap",
              onPressed: _handleLogout,
            )
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
              _isRegisterMode ? "GymTrack'e Kayıt Olun" : "GymTrack Hesabınıza Giriş Yapın",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _isRegisterMode
                  ? "Sağlık ve antrenman yolculuğunuza hemen başlayın."
                  : "Sağlık detaylarınız, antrenman hedefleriniz ve tercihleriniz senkronize edilsin.",
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
                      onTap: () => setState(() => _isRegisterMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isRegisterMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Giriş Yap",
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
                      onTap: () => setState(() => _isRegisterMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isRegisterMode ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "Kayıt Ol",
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
                  labelText: "Ad Soyad",
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
                labelText: "E-Posta",
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
                labelText: "Şifre",
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
                onPressed: _handleAuthSubmit,
                child: Text(
                  _isRegisterMode ? "Hesap Oluştur ve Başla" : "Giriş Yap",
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
                        backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
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
        _buildSectionHeader("Sağlık Ayrıntıları", Icons.favorite_rounded, Colors.redAccent),
        Card(
          child: Column(
            children: [
              _buildTile("Boy", "${profile.heightCm.toInt()} ${profile.heightUnit}", Icons.height, () {
                _showEditDialog("Boy Güncelle (cm)", profile.heightCm.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newHeight: v));
                });
              }),
              _buildDivider(),
              _buildTile("Kilo", "${profile.weightKg} ${profile.weightUnit}", Icons.monitor_weight_outlined, () {
                _showEditDialog("Kilo Güncelle (kg)", profile.weightKg.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newWeight: v));
                });
              }),
              _buildDivider(),
              _buildTile("Yaş", "${profile.age}", Icons.cake_outlined, () {
                _showEditDialog("Yaş", profile.age.toString(), (val) {
                  final v = int.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newAge: v));
                });
              }),
              _buildDivider(),
              _buildTile("Cinsiyet", profile.gender, Icons.transgender, () {
                _showGenderPicker();
              }),
              _buildDivider(),
              _buildTile("Kan Grubu", profile.bloodGroup, Icons.bloodtype, () {
                _showBloodGroupPicker();
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. HEDEFLER
        _buildSectionHeader("Hedefler", Icons.track_changes_rounded, Colors.amber),
        Card(
          child: Column(
            children: [
              _buildTile("Hedef Kilo", "${profile.targetWeightKg} ${profile.weightUnit}", Icons.flag_outlined, () {
                _showEditDialog("Hedef Kilo (kg)", profile.targetWeightKg.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newTargetWeight: v));
                });
              }),
              _buildDivider(),
              _buildTile("Günlük Kalori Hedefi", "${profile.dailyCalorieGoal.toInt()} ${profile.energyUnit}", Icons.local_fire_department_outlined, () {
                _showEditDialog("Günlük Kalori", profile.dailyCalorieGoal.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newDailyCalorie: v));
                });
              }),
              _buildDivider(),
              _buildTile("Günlük Su Hedefi", "${profile.dailyWaterGoalLiters} Litre", Icons.water_drop_outlined, () {
                _showEditDialog("Su Hedefi (Litre)", profile.dailyWaterGoalLiters.toString(), (val) {
                  final v = double.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newDailyWater: v));
                });
              }),
              _buildDivider(),
              _buildTile("Haftalık Antrenman Hedefi", "${profile.weeklyWorkoutDays} Gün", Icons.calendar_month_outlined, () {
                _showEditDialog("Haftalık Antrenman (Gün)", profile.weeklyWorkoutDays.toString(), (val) {
                  final v = int.tryParse(val);
                  if (v != null) setState(() => profile.updateProfile(newWeeklyWorkouts: v));
                });
              }),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. BİLDİRİMLER
        _buildSectionHeader("Bildirimler", Icons.notifications_rounded, AppTheme.accent),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Antrenman Hatırlatıcıları"),
                subtitle: const Text("Planlanan günlerde antrenmanı kaçırma", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.workoutReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.workoutReminders = val),
              ),
              _buildDivider(),
              SwitchListTile(
                title: const Text("Öğün & Kalori Bildirimleri"),
                subtitle: const Text("Öğün loglamayı hatırlatan bildirimler", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.mealReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.mealReminders = val),
              ),
              _buildDivider(),
              SwitchListTile(
                title: const Text("Su Hatırlatıcı"),
                subtitle: const Text("Düzenli su içme bildirimleri", style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                value: profile.waterReminders,
                activeColor: AppTheme.accent,
                onChanged: (val) => setState(() => profile.waterReminders = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. ÖLÇÜ BİRİMLERİ
        _buildSectionHeader("Ölçü Birimleri", Icons.straighten_rounded, AppTheme.fatColor),
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text("Ağırlık Birimi"),
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
                title: const Text("Boy Birimi"),
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
                title: const Text("Enerji Birimi"),
                trailing: DropdownButton<String>(
                  value: profile.energyUnit,
                  dropdownColor: AppTheme.cardColor,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'kcal', child: Text("Kalori (kcal)")),
                    DropdownMenuItem(value: 'kJ', child: Text("Kilojoule (kJ)")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => profile.energyUnit = val);
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 5. HAKKIMIZDA
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

  void _showPhotoPickerModal() {
    final avatarList = [
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=400&q=80',
    ];

    final urlController = TextEditingController();

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
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Profil Fotoğrafı Seç / Yükle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Hazır Sporcu Avatarlarından Seçin:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatarList.length,
                  itemBuilder: (context, index) {
                    final photo = avatarList[index];
                    final isCurrent = profile.photoUrl == photo;
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
              const SizedBox(height: 20),
              const Text("Veya Kendi Fotoğraf Bağlantınızı (URL) Girin:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: "https://... görsel bağlantısı",
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onPressed: () {
                      final url = urlController.text.trim();
                      if (url.isNotEmpty) {
                        setState(() {
                          profile.updateProfile(newPhotoUrl: url);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Fotoğrafınız başarıyla kaydedildi! 📸"), backgroundColor: AppTheme.accent),
                        );
                      }
                    },
                    child: const Text("Uygula", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
