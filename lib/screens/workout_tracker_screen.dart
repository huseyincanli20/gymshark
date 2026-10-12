import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../models/workout_manager.dart';
import '../models/user_profile.dart';
import '../services/exercise_repository.dart';
import '../utils/app_locale.dart';
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
        final exercises = ExerciseRepository.instance.exercises;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final ex = exercises[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.surfaceColor,
                child: Icon(Icons.fitness_center, color: AppTheme.primary),
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
        final exercises = ExerciseRepository.instance.exercises;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocale.isEnglish ? "Select Exercise to Replace" : "Değiştirmek İstediğiniz Egzersizi Seçin",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.surfaceColor,
                      child: Icon(Icons.fitness_center, color: AppTheme.primary),
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
        title: Text(AppLocale.get('workout_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: AppTheme.accent, size: 28),
            tooltip: AppLocale.get('finish_workout'),
            onPressed: () {
              // 1. Haftalık aktiviteye bugünü kaydet
              UserSession.current.logWorkoutForToday();

              // 2. Tamamlanan setlerdeki ağırlıklardan kişisel rekorları (PR) güncelle
              int newPrCount = 0;
              for (final log in workoutManager.activeWorkout) {
                final completedSets = log.sets.where((s) => s.isCompleted).toList();
                if (completedSets.isNotEmpty) {
                  // En yüksek ağırlıklı seti bul
                  completedSets.sort((a, b) => b.weight.compareTo(a.weight));
                  final bestSet = completedSets.first;

                  // Mevcut PR var mı kontrol et
                  final existingPr = UserSession.current.personalRecords.firstWhere(
                    (p) => p.exerciseName.toLowerCase() == log.exercise.name.toLowerCase(),
                    orElse: () => PersonalRecord(id: '', exerciseName: '', weight: 0, reps: 0, date: DateTime.now()),
                  );

                  if (existingPr.id.isEmpty || bestSet.weight > existingPr.weight) {
                    UserSession.current.addOrUpdatePR(
                      exerciseName: log.exercise.name,
                      weight: bestSet.weight,
                      reps: bestSet.reps,
                    );
                    newPrCount++;
                  }
                }
              }

              // 3. Antrenmanda yakılan kaloriyi hesapla
              // Formül: (Kaldırılan toplam tonaj (kg) * 0.015) + (Tamamlanan set sayısı * 18 kcal) + (Kilo bazı metabolik harcama)
              double totalVolumeKg = 0.0;
              int totalCompletedSets = 0;
              for (final log in workoutManager.activeWorkout) {
                for (final s in log.sets) {
                  if (s.isCompleted) {
                    totalVolumeKg += (s.weight * s.reps);
                    totalCompletedSets++;
                  }
                }
              }

              // Set yoksa bile antrenman başlangıç taban harcaması ~120 kcal
              double burnedCalories = 120.0;
              if (totalCompletedSets > 0) {
                final weightMultiplier = UserSession.current.weightKg / 70.0;
                burnedCalories = ((totalVolumeKg * 0.014) + (totalCompletedSets * 14.0)) * weightMultiplier;
              }
              burnedCalories = double.parse((burnedCalories.clamp(80.0, 1500.0)).toStringAsFixed(0));

              // Kullanıcının günlük yakılan kalorisine ekle
              UserSession.current.addBurnedCalories(burnedCalories);

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orangeAccent, size: 28),
                      const SizedBox(width: 8),
                      Text(AppLocale.get('workout_completed'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(AppLocale.get('workout_burned_cal'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              "${burnedCalories.toInt()} kcal",
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${AppLocale.get('total_volume')}: ${totalVolumeKg.toInt()} kg • $totalCompletedSets ${AppLocale.isEnglish ? 'Sets' : 'Set'}",
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (newPrCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: AppTheme.accent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppLocale.isEnglish
                                      ? "Congratulations! You broke $newPrCount new personal record(s) (PR)!"
                                      : "Tebrikler! $newPrCount yeni kişisel rekor (PR) kırdınız!",
                                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocale.get('back_to_home'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
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
                        "${AppLocale.get('rest_seconds')}$_restSecondsRemaining ${AppLocale.get('sec_short')}",
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
                    child: Text(AppLocale.get('skip'), style: const TextStyle(color: Colors.white)),
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
                                PopupMenuItem(
                                  value: 'change_image',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.image_outlined, color: AppTheme.accent, size: 20),
                                      const SizedBox(width: 10),
                                      Text(AppLocale.get('change_image'), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit_sets',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 20),
                                      const SizedBox(width: 10),
                                      Text(AppLocale.get('edit_sets'), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'replace',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.swap_horiz_rounded, color: Colors.amber, size: 20),
                                      const SizedBox(width: 10),
                                      Text(AppLocale.get('replace_exercise'), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                      const SizedBox(width: 10),
                                      Text(AppLocale.get('remove_exercise'), style: const TextStyle(color: Colors.redAccent)),
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
                            SizedBox(width: 35, child: Text(AppLocale.get('set'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
                            Expanded(child: Center(child: Text(UserSession.current.weightUnit.toUpperCase(), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            Expanded(child: Center(child: Text(AppLocale.get('reps'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
                            SizedBox(width: 48, child: Center(child: Text(AppLocale.get('done'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)))),
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
                          label: Text(AppLocale.get('add_set'), style: const TextStyle(color: AppTheme.primary)),
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
                label: Text(AppLocale.get('add_exercise'), style: const TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _openExerciseSelector,
              ),
            ),
          )
        ],
      ),
    );
  }
}
