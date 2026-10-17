import 'dart:convert';
import 'fitness_models.dart';
import '../services/exercise_repository.dart';

class RoutineExerciseRef {
  final String exerciseId;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeightKg;

  const RoutineExerciseRef({
    required this.exerciseId,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeightKg = 20.0,
  });

  Map<String, dynamic> toMap() => {
    'exerciseId': exerciseId,
    'defaultSets': defaultSets,
    'defaultReps': defaultReps,
    'defaultWeightKg': defaultWeightKg,
  };

  factory RoutineExerciseRef.fromMap(Map<String, dynamic> map) => RoutineExerciseRef(
    exerciseId: map['exerciseId'] ?? '',
    defaultSets: map['defaultSets'] ?? 3,
    defaultReps: map['defaultReps'] ?? 10,
    defaultWeightKg: (map['defaultWeightKg'] as num?)?.toDouble() ?? 20.0,
  );
}

class WorkoutRoutine {
  final String id;
  final String nameTr;
  final String nameEn;
  final String descTr;
  final String descEn;
  final String splitCategory; // 'PPL', 'Upper/Lower', 'Full Body', '5x5', 'Özel'
  final String level; // 'Başlangıç', 'Orta', 'İleri'
  final int estimatedMinutes;
  final List<RoutineExerciseRef> exerciseRefs;
  final bool isCustom;

  WorkoutRoutine({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    required this.descTr,
    required this.descEn,
    required this.splitCategory,
    this.level = 'Orta',
    this.estimatedMinutes = 55,
    required this.exerciseRefs,
    this.isCustom = false,
  });

  String getName(bool isEnglish) => isEnglish ? nameEn : nameTr;
  String getDesc(bool isEnglish) => isEnglish ? descEn : descTr;

  List<Exercise> getResolvedExercises() {
    final allEx = ExerciseRepository.instance.exercises;
    final List<Exercise> list = [];
    for (final ref in exerciseRefs) {
      final found = allEx.where((e) => e.id == ref.exerciseId || e.name.toLowerCase() == ref.exerciseId.toLowerCase()).toList();
      if (found.isNotEmpty) {
        list.add(found.first);
      }
    }
    return list;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nameTr': nameTr,
    'nameEn': nameEn,
    'descTr': descTr,
    'descEn': descEn,
    'splitCategory': splitCategory,
    'level': level,
    'estimatedMinutes': estimatedMinutes,
    'isCustom': isCustom,
    'exerciseRefs': exerciseRefs.map((e) => e.toMap()).toList(),
  };

  factory WorkoutRoutine.fromMap(Map<String, dynamic> map) => WorkoutRoutine(
    id: map['id'] ?? '',
    nameTr: map['nameTr'] ?? '',
    nameEn: map['nameEn'] ?? '',
    descTr: map['descTr'] ?? '',
    descEn: map['descEn'] ?? '',
    splitCategory: map['splitCategory'] ?? 'Özel',
    level: map['level'] ?? 'Orta',
    estimatedMinutes: map['estimatedMinutes'] ?? 50,
    isCustom: map['isCustom'] ?? true,
    exerciseRefs: (map['exerciseRefs'] as List<dynamic>?)
            ?.map((e) => RoutineExerciseRef.fromMap(e))
            .toList() ??
        [],
  );

  String toJson() => jsonEncode(toMap());
  factory WorkoutRoutine.fromJson(String source) => WorkoutRoutine.fromMap(jsonDecode(source));

  static List<WorkoutRoutine> getDefaultRoutines() {
    return [
      WorkoutRoutine(
        id: 'routine_ppl_push',
        nameTr: 'PPL: İtiş Günü (Push Day)',
        nameEn: 'PPL: Push Day (Chest & Shoulders)',
        descTr: 'Göğüs, ön omuz ve arka kol (Triceps) hipertrofi ve güç seansı.',
        descEn: 'Hypertrophy and strength session targeting chest, front delts, and triceps.',
        splitCategory: 'PPL',
        level: 'Orta',
        estimatedMinutes: 55,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_1', defaultSets: 4, defaultReps: 8, defaultWeightKg: 60), // Bench Press
          RoutineExerciseRef(exerciseId: 'ex_4', defaultSets: 4, defaultReps: 10, defaultWeightKg: 40), // Shoulder Press
          RoutineExerciseRef(exerciseId: 'ex_6', defaultSets: 3, defaultReps: 12, defaultWeightKg: 10), // Lateral Raise
          RoutineExerciseRef(exerciseId: 'ex_8', defaultSets: 3, defaultReps: 12, defaultWeightKg: 25), // Tricep Dips/Pushdown
        ],
      ),
      WorkoutRoutine(
        id: 'routine_ppl_pull',
        nameTr: 'PPL: Çekiş Günü (Pull Day)',
        nameEn: 'PPL: Pull Day (Back & Biceps)',
        descTr: 'Sırt kalınlığı, lat genişliği ve biceps tepe noktası gelişimi.',
        descEn: 'Back thickness, lat width, and bicep peak development routine.',
        splitCategory: 'PPL',
        level: 'Orta',
        estimatedMinutes: 50,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_3', defaultSets: 4, defaultReps: 6, defaultWeightKg: 80), // Deadlift
          RoutineExerciseRef(exerciseId: 'ex_5', defaultSets: 4, defaultReps: 10, defaultWeightKg: 25), // Bicep Curl
          RoutineExerciseRef(exerciseId: 'ex_7', defaultSets: 3, defaultReps: 10, defaultWeightKg: 50), // Pull-ups / Row
        ],
      ),
      WorkoutRoutine(
        id: 'routine_ppl_legs',
        nameTr: 'PPL: Bacak Günü (Leg Day)',
        nameEn: 'PPL: Leg Day (Quads & Hamstrings)',
        descTr: 'Quadriceps, hamstring ve kalf kasları için patlayıcı alt gövde çalışması.',
        descEn: 'Explosive lower body workout targeting quads, hamstrings, and calves.',
        splitCategory: 'PPL',
        level: 'İleri',
        estimatedMinutes: 60,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_2', defaultSets: 4, defaultReps: 8, defaultWeightKg: 70), // Squat
          RoutineExerciseRef(exerciseId: 'ex_3', defaultSets: 3, defaultReps: 8, defaultWeightKg: 75), // Deadlift / RDL
        ],
      ),
      WorkoutRoutine(
        id: 'routine_upper_power',
        nameTr: 'Üst Vücut Güç (Upper Body)',
        nameEn: 'Upper Body Power & Tone',
        descTr: 'Tüm üst gövde kas gruplarını dengeli ve yoğun şekilde uyarır.',
        descEn: 'Balanced and intense stimulation for all upper body muscle groups.',
        splitCategory: 'Upper/Lower',
        level: 'Başlangıç / Orta',
        estimatedMinutes: 50,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_1', defaultSets: 3, defaultReps: 10, defaultWeightKg: 50),
          RoutineExerciseRef(exerciseId: 'ex_4', defaultSets: 3, defaultReps: 10, defaultWeightKg: 35),
          RoutineExerciseRef(exerciseId: 'ex_5', defaultSets: 3, defaultReps: 12, defaultWeightKg: 20),
        ],
      ),
      WorkoutRoutine(
        id: 'routine_5x5_strength',
        nameTr: '5x5 Güç & Kütle Programı',
        nameEn: '5x5 Strength & Mass Program',
        descTr: 'Temel bileşik (compound) hareketlerle maksimum kuvvet artışı.',
        descEn: 'Maximum strength gains using foundational compound movements.',
        splitCategory: '5x5',
        level: 'İleri',
        estimatedMinutes: 65,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_2', defaultSets: 5, defaultReps: 5, defaultWeightKg: 80), // Squat
          RoutineExerciseRef(exerciseId: 'ex_1', defaultSets: 5, defaultReps: 5, defaultWeightKg: 70), // Bench Press
          RoutineExerciseRef(exerciseId: 'ex_3', defaultSets: 1, defaultReps: 5, defaultWeightKg: 95), // Deadlift
        ],
      ),
      WorkoutRoutine(
        id: 'routine_full_body_express',
        nameTr: 'Tüm Vücut Ekspres (Full Body)',
        nameEn: 'Full Body Express Workout',
        descTr: 'Zamanı kısıtlı olanlar için 40 dakikada tüm vücudu aktive eden antrenman.',
        descEn: 'Full body activation in 40 minutes for busy athletes.',
        splitCategory: 'Full Body',
        level: 'Başlangıç',
        estimatedMinutes: 40,
        exerciseRefs: const [
          RoutineExerciseRef(exerciseId: 'ex_2', defaultSets: 3, defaultReps: 10, defaultWeightKg: 50),
          RoutineExerciseRef(exerciseId: 'ex_1', defaultSets: 3, defaultReps: 10, defaultWeightKg: 40),
          RoutineExerciseRef(exerciseId: 'ex_5', defaultSets: 3, defaultReps: 12, defaultWeightKg: 15),
        ],
      ),
    ];
  }
}
