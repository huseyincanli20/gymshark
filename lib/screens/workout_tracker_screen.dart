import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  final List<ActiveExerciseLog> _currentWorkout = [];
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    // Örnek başlangıç egzersizi
    if (MockData.exercises.isNotEmpty) {
      _currentWorkout.add(
        ActiveExerciseLog(
          exercise: MockData.exercises[0],
          sets: [
            WorkoutSet(weight: 60, reps: 10, isCompleted: true),
            WorkoutSet(weight: 70, reps: 8, isCompleted: true),
            WorkoutSet(weight: 80, reps: 6, isCompleted: false),
          ],
        ),
      );
    }
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = seconds;
      _isResting = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        setState(() {
          _restSecondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  void _openExerciseSelector() async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: MockData.exercises.length,
          itemBuilder: (context, index) {
            final ex = MockData.exercises[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.surfaceColor,
                child: const Icon(Icons.fitness_center, color: AppTheme.primary),
              ),
              title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(ex.muscleGroup.name.toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary)),
              trailing: const Icon(Icons.add_circle_outline, color: AppTheme.accent),
              onTap: () => Navigator.pop(context, ex),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        _currentWorkout.add(
          ActiveExerciseLog(
            exercise: selected,
            sets: [
              WorkoutSet(weight: 20, reps: 10),
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Canlı Antrenman Takibi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: AppTheme.accent, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Antrenman başarıyla tamamlandı ve kaydedildi! 🎉")),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Dinlenme Sayacı Bildirimi
          if (_isResting)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.accent.withOpacity(0.15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text(
                        "Dinlenme: $_restSecondsRemaining sn",
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      _restTimer?.cancel();
                      setState(() => _isResting = false);
                    },
                    child: const Text("Atla", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _currentWorkout.length,
              itemBuilder: (context, exIndex) {
                final log = _currentWorkout[exIndex];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExerciseDetailScreen(exercise: log.exercise),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    log.exercise.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.info_outline, size: 18, color: AppTheme.textSecondary),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                              onPressed: () {},
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            SizedBox(width: 35, child: Text("SET", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                            Expanded(child: Center(child: Text("KG", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            Expanded(child: Center(child: Text("TEKRAR", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            SizedBox(width: 48, child: Center(child: Text("BİTTİ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                          ],
                        ),
                        const Divider(color: AppTheme.surfaceColor),
                        ...List.generate(log.sets.length, (setIndex) {
                          final s = log.sets[setIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                  child: Text("${setIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${s.weight} kg",
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${s.reps}",
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 48,
                                  child: IconButton(
                                    icon: Icon(
                                      s.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: s.isCompleted ? AppTheme.accent : AppTheme.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        s.isCompleted = !s.isCompleted;
                                        if (s.isCompleted) {
                                          _startRestTimer(60); // 60 sn dinlenme başlat
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.add, color: AppTheme.primary, size: 18),
                          label: const Text("Set Ekle", style: TextStyle(color: AppTheme.primary)),
                          onPressed: () {
                            setState(() {
                              final lastWeight = log.sets.isNotEmpty ? log.sets.last.weight : 20.0;
                              final lastReps = log.sets.isNotEmpty ? log.sets.last.reps : 10;
                              log.sets.add(WorkoutSet(weight: lastWeight, reps: lastReps));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                label: const Text("Egzersiz Ekle", style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _openExerciseSelector,
              ),
            ),
          )
        ],
      ),
    );
  }
}
