import 'package:flutter/material.dart';
import '../models/routine_models.dart';
import '../models/workout_manager.dart';
import '../models/fitness_models.dart';
import '../models/user_profile.dart';
import '../services/exercise_repository.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';
import 'workout_tracker_screen.dart';

class WorkoutRoutinesScreen extends StatefulWidget {
  const WorkoutRoutinesScreen({super.key});

  @override
  State<WorkoutRoutinesScreen> createState() => _WorkoutRoutinesScreenState();
}

class _WorkoutRoutinesScreenState extends State<WorkoutRoutinesScreen> {
  String _selectedCategory = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final profile = UserSession.current;
    final isEn = AppLocale.isEnglish;
    final defaultRoutines = WorkoutRoutine.getDefaultRoutines();
    final allRoutines = [...defaultRoutines, ...profile.customRoutines];

    final categories = ['Tümü', 'PPL', 'Upper/Lower', '5x5', 'Full Body', 'Özel'];

    final filteredRoutines = _selectedCategory == 'Tümü'
        ? allRoutines
        : (_selectedCategory == 'Özel'
            ? allRoutines.where((r) => r.isCustom).toList()
            : allRoutines.where((r) => r.splitCategory == _selectedCategory).toList());

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('routines_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppTheme.accent),
            tooltip: AppLocale.get('create_routine'),
            onPressed: () => _showCreateCustomRoutineDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Kategori Filtreleri
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      cat == 'Tümü' ? (isEn ? 'All' : 'Tümü') : (cat == 'Özel' ? (isEn ? 'Custom' : 'Özel') : cat),
                      style: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.accent,
                    backgroundColor: AppTheme.surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Rutin Listesi
          Expanded(
            child: filteredRoutines.isEmpty
                ? Center(
                    child: Text(
                      isEn ? 'No routines found in this category' : 'Bu kategoride program bulunmuyor',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRoutines.length,
                    itemBuilder: (context, index) {
                      final routine = filteredRoutines[index];
                      return _buildRoutineCard(routine, isEn);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard(WorkoutRoutine routine, bool isEn) {
    final exercises = routine.getResolvedExercises();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: routine.isCustom ? AppTheme.accent.withOpacity(0.5) : Colors.white10,
          width: routine.isCustom ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    routine.getName(isEn),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    routine.splitCategory,
                    style: const TextStyle(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              routine.getDesc(isEn),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // Süre ve Seviye Rozetleri
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  "${routine.estimatedMinutes} ${isEn ? 'min' : 'dk'}",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.fitness_center_outlined, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  routine.level,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  "${exercises.length} ${isEn ? 'Exercises' : 'Egzersiz'}",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),

            // Egzersiz Önizleme Listesi
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: exercises.take(4).map((ex) {
                return Chip(
                  backgroundColor: AppTheme.surfaceColor,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                  label: Text(
                    ex.name,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Başlat Butonu
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: Text(
                  AppLocale.get('start_routine'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () => _startRoutine(routine),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRoutine(WorkoutRoutine routine) {
    final exercises = routine.getResolvedExercises();
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocale.isEnglish ? 'No exercises found in this routine.' : 'Bu programda egzersiz bulunamadı.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final manager = WorkoutManager.instance;
    manager.activeWorkout.clear();

    for (int i = 0; i < routine.exerciseRefs.length; i++) {
      final ref = routine.exerciseRefs[i];
      final ex = exercises.firstWhere(
        (e) => e.id == ref.exerciseId || e.name.toLowerCase() == ref.exerciseId.toLowerCase(),
        orElse: () => exercises.first,
      );

      final sets = List.generate(
        ref.defaultSets,
        (_) => WorkoutSet(weight: ref.defaultWeightKg, reps: ref.defaultReps),
      );

      manager.activeWorkout.add(ActiveExerciseLog(exercise: ex, sets: sets));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutTrackerScreen()),
    );
  }

  void _showCreateCustomRoutineDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedExercises = <Exercise>[];
    final allExercises = ExerciseRepository.instance.exercises;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
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
                      Text(
                        AppLocale.get('create_routine'),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocale.isEnglish ? 'Routine Name' : 'Program Adı',
                      hintText: AppLocale.isEnglish ? 'e.g. Arnold Chest & Back' : 'Örn: Arnold Göğüs & Sırt',
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      labelText: AppLocale.isEnglish ? 'Description' : 'Açıklama',
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocale.isEnglish ? 'Selected Exercises' : 'Seçilen Egzersizler'} (${selectedExercises.length}):",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16, color: AppTheme.accent),
                        label: Text(
                          AppLocale.isEnglish ? 'Add Exercise' : 'Egzersiz Ekle',
                          style: const TextStyle(color: AppTheme.accent, fontSize: 13),
                        ),
                        onPressed: () async {
                          final ex = await showDialog<Exercise>(
                            context: context,
                            builder: (context) => SimpleDialog(
                              title: Text(AppLocale.isEnglish ? 'Select Exercise' : 'Egzersiz Seç'),
                              backgroundColor: AppTheme.cardColor,
                              children: allExercises.map((e) {
                                return SimpleDialogOption(
                                  onPressed: () => Navigator.pop(context, e),
                                  child: Text(e.name),
                                );
                              }).toList(),
                            ),
                          );
                          if (ex != null) {
                            setModalState(() {
                              selectedExercises.add(ex);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    children: selectedExercises.map((e) {
                      return Chip(
                        label: Text(e.name, style: const TextStyle(fontSize: 11)),
                        onDeleted: () {
                          setModalState(() {
                            selectedExercises.remove(e);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isNotEmpty && selectedExercises.isNotEmpty) {
                          final newRoutine = WorkoutRoutine(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            nameTr: name,
                            nameEn: name,
                            descTr: descCtrl.text.trim(),
                            descEn: descCtrl.text.trim(),
                            splitCategory: 'Özel',
                            isCustom: true,
                            exerciseRefs: selectedExercises
                                .map((e) => RoutineExerciseRef(exerciseId: e.id, defaultSets: 3, defaultReps: 10, defaultWeightKg: 20))
                                .toList(),
                          );
                          UserSession.current.saveCustomRoutine(newRoutine);
                          Navigator.pop(context);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocale.isEnglish ? 'Custom routine saved! 📋' : 'Özel program kaydedildi! 📋'),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        }
                      },
                      child: Text(
                        AppLocale.get('save'),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
