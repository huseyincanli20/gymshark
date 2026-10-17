import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserSession.current;
    final isEn = AppLocale.isEnglish;
    final badges = profile.badges;
    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final totalCount = badges.length;
    final completionRatio = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('badges_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Özet Başarı Kartı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF57C00), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Milestone Progress' : 'Başarı İlerlemen',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$unlockedCount / $totalCount ${isEn ? 'Badges Unlocked' : 'Rozet Kazanıldı'}",
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: completionRatio,
                            backgroundColor: Colors.black26,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rozet Kartları Listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: badge.isUnlocked ? Colors.amber.withOpacity(0.6) : Colors.white10,
                      width: badge.isUnlocked ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Madalya / Emoji Kutusu
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: badge.isUnlocked ? Colors.amber.withOpacity(0.2) : AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            badge.iconEmoji,
                            style: TextStyle(
                              fontSize: 28,
                              color: badge.isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Başlık ve Açıklama
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    badge.getTitle(isEn),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: badge.isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: badge.isUnlocked ? AppTheme.accent.withOpacity(0.2) : AppTheme.surfaceColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    badge.isUnlocked ? AppLocale.get('unlocked') : AppLocale.get('locked'),
                                    style: TextStyle(
                                      color: badge.isUnlocked ? AppTheme.accent : AppTheme.textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              badge.getDesc(isEn),
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            // İlerleme Çubuğu
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: badge.progress,
                                      backgroundColor: AppTheme.surfaceColor,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        badge.isUnlocked ? Colors.amber : AppTheme.primary,
                                      ),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  badge.progressText,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
