import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/user_profile.dart';
import '../models/fitness_models.dart';
import '../models/workout_manager.dart';
import 'workout_tracker_screen.dart';
import 'exercise_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            icon: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80'),
            ),
            onPressed: () {},
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

            const SizedBox(height: 24),

            // Haftalık Streak & Hedef
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Haftalık Aktivite", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("4/${UserSession.current.weeklyWorkoutDays} Gün", style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDayItem("Pzt", true),
                _buildDayItem("Sal", true),
                _buildDayItem("Çar", false),
                _buildDayItem("Per", true),
                _buildDayItem("Cum", true),
                _buildDayItem("Cmt", false),
                _buildDayItem("Paz", false),
              ],
            ),

            const SizedBox(height: 28),

            // Popüler Videolu Egzersizler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Videolu Egzersizler", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                      width: 140,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(height: 2),
                                Text(
                                  ex.muscleGroup.name.toUpperCase(),
                                  style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w600),
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

  Widget _buildDayItem(String day, bool isDone) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDone ? AppTheme.accent : AppTheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check : Icons.circle,
            color: isDone ? Colors.black : Colors.white24,
            size: isDone ? 20 : 10,
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
