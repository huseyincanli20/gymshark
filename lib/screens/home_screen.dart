import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/user_profile.dart';
import '../models/fitness_models.dart';
import '../models/workout_manager.dart';
import 'workout_tracker_screen.dart';
import 'exercise_detail_screen.dart';

import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    UserSession.current.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserSession.current.removeListener(_onProfileChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserSession.current;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("GymTrack", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: AppTheme.primary)),
            Text("Bugün göğüs ve triceps günü 🔥", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceColor,
              backgroundImage: profile.avatarImage,
              child: profile.avatarImage == null
                  ? const Icon(Icons.person, size: 18, color: AppTheme.primary)
                  : null,
            ),
            tooltip: "Hesabım & Profil",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hızlı Antrenmana Başla Banner'ı
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Günün Antrenmanı",
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Push Day (Göğüs & Omuz)",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WorkoutTrackerScreen()),
                            );
                          },
                          child: const Text("Şimdi Başla", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.fitness_center_rounded, size: 70, color: Colors.white24),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // GÜNLÜK YAKILAN KALORİ & GÜNLÜK ADIM SAYAR PENCERESİ
            Row(
              children: [
                // 1. Günlük Yakılan Kalori Kartı
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 20),
                            ),
                            Text(
                              "Bugün",
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Yakılan Kalori",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              "${profile.todayBurnedCalories.toInt()}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "kcal",
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.todayBurnedCalories > 0
                              ? "Antrenman & Adım 🔥"
                              : "Antrenman bekleniyor",
                          style: const TextStyle(fontSize: 10, color: AppTheme.accent),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Günlük Adım Sayar Kartı
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showEditStepsDialog();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.directions_walk_rounded, color: AppTheme.accent, size: 20),
                              ),
                              const Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Günlük Adım",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                "${profile.todaySteps}",
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accent),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "/ ${profile.stepGoal}",
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (profile.todaySteps / profile.stepGoal).clamp(0.0, 1.0),
                              backgroundColor: AppTheme.surfaceColor,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                              minHeight: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Haftalık Streak & Hedef
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: AppTheme.accent, size: 20),
                    SizedBox(width: 8),
                    Text("Haftalık Aktivite", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "${profile.completedDaysThisWeek.length}/${profile.weeklyWorkoutDays} Gün",
                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18, color: AppTheme.textSecondary),
                      tooltip: "Haftalık Aktiviteyi Sıfırla",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.cardColor,
                            title: const Text("Aktiviteyi Sıfırla"),
                            content: const Text("Haftalık antrenman aktivite geçmişini sıfırlamak istiyor musunuz?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("İptal"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  profile.resetWeeklyActivity();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Haftalık aktivite sıfırlandı. Yeni haftaya hazırsınız! 🔄")),
                                  );
                                },
                                child: const Text("Sıfırla", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayItem("Pzt", 1, profile.completedDaysThisWeek.contains(1)),
                _buildDayItem("Sal", 2, profile.completedDaysThisWeek.contains(2)),
                _buildDayItem("Çar", 3, profile.completedDaysThisWeek.contains(3)),
                _buildDayItem("Per", 4, profile.completedDaysThisWeek.contains(4)),
                _buildDayItem("Cum", 5, profile.completedDaysThisWeek.contains(5)),
                _buildDayItem("Cmt", 6, profile.completedDaysThisWeek.contains(6)),
                _buildDayItem("Paz", 7, profile.completedDaysThisWeek.contains(7)),
              ],
            ),

            const SizedBox(height: 28),

            // Egzersiz Rehberi & Hareket Formları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text("Egzersiz Rehberi & Formlar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Tümü", style: TextStyle(color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MockData.exercises.length,
                itemBuilder: (context, index) {
                  final ex = MockData.exercises[index];
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<Exercise>(
                        context,
                        MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
                      );
                      if (result != null) {
                        WorkoutManager.instance.addExercise(result);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${result.name} canlı antrenman takibine eklendi! 💪"),
                              backgroundColor: AppTheme.accent,
                              action: SnackBarAction(
                                label: "Antrenmana Git",
                                textColor: Colors.black,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const WorkoutTrackerScreen()),
                                  );
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      width: 148,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.network(
                                  ex.thumbnailUrl,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_stories, size: 11, color: AppTheme.primary),
                                      SizedBox(width: 3),
                                      Text(
                                        "Form Gör",
                                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ex.muscleGroup.name.toUpperCase(),
                                      style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditStepsDialog() {
    final profile = UserSession.current;
    final controller = TextEditingController(text: profile.todaySteps > 0 ? profile.todaySteps.toString() : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.directions_walk_rounded, color: AppTheme.accent),
            SizedBox(width: 8),
            Text("Günlük Adım Sayısı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bugünkü adım sayınızı girin veya hızlı butonları kullanın. Her adım harcanan kaloriyi otomatik hesaplar.",
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Toplam Adım",
                suffixText: "adım",
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text("+1.000"),
                  onPressed: () {
                    final curr = int.tryParse(controller.text) ?? 0;
                    controller.text = (curr + 1000).toString();
                  },
                ),
                ActionChip(
                  label: const Text("+3.000"),
                  onPressed: () {
                    final curr = int.tryParse(controller.text) ?? 0;
                    controller.text = (curr + 3000).toString();
                  },
                ),
                ActionChip(
                  label: const Text("+5.000"),
                  onPressed: () {
                    final curr = int.tryParse(controller.text) ?? 0;
                    controller.text = (curr + 5000).toString();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              profile.resetDailyBurnedAndSteps();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Günlük adım ve yakılan kalori sıfırlandı. 🔄")),
              );
            },
            child: const Text("Sıfırla", style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              final steps = int.tryParse(controller.text) ?? 0;
              profile.setSteps(steps);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Adım sayısı ($steps) ve yakılan kalori güncellendi! 🚶‍♂️🔥"),
                  backgroundColor: AppTheme.accent,
                ),
              );
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, int dayNumber, bool isDone) {
    final isToday = DateTime.now().weekday == dayNumber;
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDone
                ? AppTheme.accent
                : (isToday ? AppTheme.primary.withOpacity(0.25) : AppTheme.surfaceColor),
            shape: BoxShape.circle,
            border: isToday
                ? Border.all(color: AppTheme.primary, width: 2)
                : Border.all(color: Colors.transparent),
          ),
          child: Icon(
            isDone ? Icons.check : (isToday ? Icons.fitness_center : Icons.circle),
            color: isDone ? Colors.black : (isToday ? AppTheme.primary : Colors.white24),
            size: isDone ? 20 : (isToday ? 16 : 10),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
