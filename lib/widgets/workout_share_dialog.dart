import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';

class WorkoutShareDialog extends StatelessWidget {
  final String workoutTitle;
  final int durationMinutes;
  final int burnedCalories;
  final double totalVolumeKg;
  final int newPrCount;

  const WorkoutShareDialog({
    super.key,
    required this.workoutTitle,
    required this.durationMinutes,
    required this.burnedCalories,
    required this.totalVolumeKg,
    this.newPrCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final profile = UserSession.current;
    final isEn = AppLocale.isEnglish;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 9:16 Hikaye Kartı Tasarımı
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF14171E), Color(0xFF0A0C10)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // GymTrack Logo ve Üst Başlık
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center_rounded, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "GymTrack",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: 1),
                        ),
                      ],
                    ),
                    Text(
                      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Kullanıcı Profili ve Antrenman Başlığı
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.surfaceColor,
                      backgroundImage: profile.avatarImage,
                      child: profile.avatarImage == null ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(workoutTitle, style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Metrik Grid Alanı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildShareMetric(isEn ? 'Duration' : 'Süre', "$durationMinutes ${isEn ? 'min' : 'dk'}", Icons.timer_outlined, Colors.white),
                          _buildShareMetric(isEn ? 'Calories' : 'Kalori', "$burnedCalories kcal", Icons.local_fire_department, Colors.orangeAccent),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildShareMetric(isEn ? 'Total Volume' : 'Toplam Tonaj', "${totalVolumeKg.toInt()} kg", Icons.fitness_center, AppTheme.accent),
                          _buildShareMetric(isEn ? 'New PRs' : 'Yeni PR', "$newPrCount ${isEn ? 'Records' : 'Rekor'}", Icons.emoji_events, Colors.amberAccent),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Alt Etiket & Motto
                Center(
                  child: Column(
                    children: [
                      Text(
                        isEn ? "DISCIPLINE EQUALS FREEDOM ⚡" : "DİSİPLİN BAŞARIYI GETİRİR ⚡",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "#GymTrack #Fitness #Workout #NoExcuses",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Butonlar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocale.get('close'), style: const TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share_rounded, size: 20),
                label: Text(
                  isEn ? 'Share to Instagram Story' : 'Instagram Hikayede Paylaş',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEn ? 'Workout card ready to share! 📸' : 'Antrenman hikaye kartı hazırlandı! 📸'),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareMetric(String title, String val, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
