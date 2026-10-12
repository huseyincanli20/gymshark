import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../models/workout_manager.dart';
import '../models/user_profile.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_screen.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key});

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  final workoutManager = WorkoutManager.instance;
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    workoutManager.addListener(_onWorkoutChanged);
    UserSession.current.addListener(_onProfileChanged);
  }

  void _onWorkoutChanged() {
    if (mounted) setState(() {});
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
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
      workoutManager.addExercise(selected);
    }
  }

  void _showReplaceExerciseDialog(int exIndex) async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Değiştirmek İstediğiniz Egzersizi Seçin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
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
                    trailing: const Icon(Icons.swap_horiz_rounded, color: AppTheme.accent),
                    onTap: () => Navigator.pop(context, ex),
                  );
                },
              ),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      workoutManager.replaceExercise(exIndex, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Egzersiz '${selected.name}' ile değiştirildi ve kaydedildi! ✅"),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    }
  }

  void _showEditSetsDialog(int exIndex) {
    final log = workoutManager.activeWorkout[exIndex];
    // Geçici set listesi klonla
    final List<Map<String, TextEditingController>> setControllers = log.sets.map((s) {
      return {
        'weight': TextEditingController(text: s.weight.toString()),
        'reps': TextEditingController(text: s.reps.toString()),
      };
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit_note_rounded, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${log.exercise.name} - Ağırlık & Set Düzenle",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          SizedBox(width: 32, child: Text("Set", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                          Expanded(child: Center(child: Text("Ağırlık (kg)", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                          SizedBox(width: 10),
                          Expanded(child: Center(child: Text("Tekrar", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                          SizedBox(width: 32),
                        ],
                      ),
                      const Divider(),
                      ...List.generate(setControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: setControllers[i]['weight'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppTheme.surfaceColor,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: setControllers[i]['reps'],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: AppTheme.surfaceColor,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 32,
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    if (setControllers.length > 1) {
                                      setDialogState(() {
                                        setControllers.removeAt(i);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.add, color: AppTheme.accent),
                        label: const Text("Yeni Set Ekle", style: TextStyle(color: AppTheme.accent)),
                        onPressed: () {
                          setDialogState(() {
                            final lastW = setControllers.isNotEmpty ? setControllers.last['weight']!.text : "20";
                            final lastR = setControllers.isNotEmpty ? setControllers.last['reps']!.text : "10";
                            setControllers.add({
                              'weight': TextEditingController(text: lastW),
                              'reps': TextEditingController(text: lastR),
                            });
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Vazgeç"),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check, color: Colors.black, size: 18),
                  label: const Text("Kaydet", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    final updatedSets = setControllers.map((c) {
                      return WorkoutSet(
                        weight: double.tryParse(c['weight']!.text) ?? 20.0,
                        reps: int.tryParse(c['reps']!.text) ?? 10,
                        isCompleted: false,
                      );
                    }).toList();

                    workoutManager.updateExerciseSets(exIndex, updatedSets);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${log.exercise.name} set ve ağırlık bilgileri güncellendi! 💾"),
                        backgroundColor: AppTheme.surfaceColor,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeImageDialog(int exIndex) {
    final log = workoutManager.activeWorkout[exIndex];
    final sampleImages = [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1574680096145-d05b474e2155?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1534367507873-d2d7e24c797f?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1605296867304-46d5465a13f1?auto=format&fit=crop&w=500&q=80',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?auto=format&fit=crop&w=500&q=80',
    ];

    final urlController = TextEditingController(text: log.customImageUrl ?? "");

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
                  Expanded(
                    child: Text(
                      "${log.exercise.name} - Görseli Değiştir",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Hazır Egzersiz Görsellerinden Seçin:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleImages.length,
                  itemBuilder: (context, index) {
                    final img = sampleImages[index];
                    final isCurrent = log.effectiveImageUrl == img;
                    return GestureDetector(
                      onTap: () {
                        workoutManager.updateExerciseImage(exIndex, img);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${log.exercise.name} görseli güncellendi! 🖼️"),
                            backgroundColor: AppTheme.accent,
                          ),
                        );
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent ? AppTheme.accent : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(img, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text("Veya Kendi Görsel Linkinizi (URL) Yapıştırın:", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
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
                      final val = urlController.text.trim();
                      if (val.isNotEmpty) {
                        workoutManager.updateExerciseImage(exIndex, val);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${log.exercise.name} özel görseli kaydedildi! 🖼️"),
                            backgroundColor: AppTheme.accent,
                          ),
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

  @override
  void dispose() {
    workoutManager.removeListener(_onWorkoutChanged);
    UserSession.current.removeListener(_onProfileChanged);
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
              itemCount: workoutManager.activeWorkout.length,
              itemBuilder: (context, exIndex) {
                final log = workoutManager.activeWorkout[exIndex];
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
                                  GestureDetector(
                                    onTap: () => _showChangeImageDialog(exIndex),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(
                                            log.effectiveImageUrl,
                                            width: 46,
                                            height: 46,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 46,
                                              height: 46,
                                              color: AppTheme.surfaceColor,
                                              child: const Icon(Icons.fitness_center, color: AppTheme.primary, size: 22),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.edit, size: 10, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        log.exercise.name,
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        log.exercise.muscleGroup.name.toUpperCase(),
                                        style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                              color: AppTheme.cardColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) {
                                if (value == 'replace') {
                                  _showReplaceExerciseDialog(exIndex);
                                } else if (value == 'edit_sets') {
                                  _showEditSetsDialog(exIndex);
                                } else if (value == 'change_image') {
                                  _showChangeImageDialog(exIndex);
                                } else if (value == 'delete') {
                                  workoutManager.removeExercise(exIndex);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("${log.exercise.name} antrenmandan çıkarıldı."),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'change_image',
                                  child: Row(
                                    children: [
                                      Icon(Icons.image_outlined, color: AppTheme.accent, size: 20),
                                      SizedBox(width: 10),
                                      Text("Görseli Değiştir", style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit_sets',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 20),
                                      SizedBox(width: 10),
                                      Text("Ağırlık & Set Düzenle", style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'replace',
                                  child: Row(
                                    children: [
                                      Icon(Icons.swap_horiz_rounded, color: Colors.amber, size: 20),
                                      SizedBox(width: 10),
                                      Text("Egzersizi Değiştir", style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      SizedBox(width: 10),
                                      Text("Egzersizi Kaldır", style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 35, child: Text("SET", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                            Expanded(child: Center(child: Text(UserSession.current.weightUnit.toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            const Expanded(child: Center(child: Text("TEKRAR", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            const SizedBox(width: 48, child: Center(child: Text("BİTTİ", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
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
                                        "${s.weight} ${UserSession.current.weightUnit}",
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
