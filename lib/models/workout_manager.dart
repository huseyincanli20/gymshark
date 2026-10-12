import 'package:flutter/material.dart';
import 'fitness_models.dart';
import '../data/mock_data.dart';

class WorkoutManager extends ChangeNotifier {
  static final WorkoutManager instance = WorkoutManager._();
  WorkoutManager._() {
    // Varsayılan başlangıç egzersizi
    if (MockData.exercises.isNotEmpty) {
      activeWorkout.add(
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

  final List<ActiveExerciseLog> activeWorkout = [];

  void addExercise(Exercise exercise) {
    // Eğer egzersiz zaten ekliyse yeni set aç, değilse baştan ekle
    final existingIndex = activeWorkout.indexWhere((log) => log.exercise.id == exercise.id);
    if (existingIndex != -1) {
      final log = activeWorkout[existingIndex];
      final lastWeight = log.sets.isNotEmpty ? log.sets.last.weight : 20.0;
      final lastReps = log.sets.isNotEmpty ? log.sets.last.reps : 10;
      log.sets.add(WorkoutSet(weight: lastWeight, reps: lastReps));
    } else {
      activeWorkout.add(
        ActiveExerciseLog(
          exercise: exercise,
          sets: [
            WorkoutSet(weight: 20, reps: 10),
            WorkoutSet(weight: 25, reps: 10),
            WorkoutSet(weight: 30, reps: 8),
          ],
        ),
      );
    }
    notifyListeners();
  }

  void replaceExercise(int index, Exercise newExercise) {
    if (index >= 0 && index < activeWorkout.length) {
      final oldSets = activeWorkout[index].sets;
      activeWorkout[index] = ActiveExerciseLog(
        exercise: newExercise,
        sets: oldSets,
      );
      notifyListeners();
    }
  }

  void updateExerciseSets(int index, List<WorkoutSet> updatedSets) {
    if (index >= 0 && index < activeWorkout.length) {
      activeWorkout[index].sets = updatedSets;
      notifyListeners();
    }
  }

  void updateExerciseImage(int index, String imageUrl) {
    if (index >= 0 && index < activeWorkout.length) {
      activeWorkout[index].customImageUrl = imageUrl;
      notifyListeners();
    }
  }

  void removeExercise(int index) {
    if (index >= 0 && index < activeWorkout.length) {
      activeWorkout.removeAt(index);
      notifyListeners();
    }
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < activeWorkout.length) {
      final log = activeWorkout[exerciseIndex];
      final lastWeight = log.sets.isNotEmpty ? log.sets.last.weight : 20.0;
      final lastReps = log.sets.isNotEmpty ? log.sets.last.reps : 10;
      log.sets.add(WorkoutSet(weight: lastWeight, reps: lastReps));
      notifyListeners();
    }
  }
}
