enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
  cardio
}

class Exercise {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String videoUrl; // Demo video / mp4 / youtube
  final String thumbnailUrl;
  final String instructions;
  final String tips;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.instructions,
    required this.tips,
  });
}

class WorkoutSet {
  double weight;
  int reps;
  bool isCompleted;

  WorkoutSet({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });
}

class ActiveExerciseLog {
  final Exercise exercise;
  List<WorkoutSet> sets;

  ActiveExerciseLog({
    required this.exercise,
    required this.sets,
  });
}

class FoodItem {
  final String id;
  final String name;
  final double calories; // kcal per 100g
  final double protein;  // gram
  final double carbs;    // gram
  final double fat;      // gram
  final String category; // Et/Tavuk, Bakliyat, Meyve vs.

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
  });
}

class LoggedMeal {
  final FoodItem food;
  final double amountGrams;

  LoggedMeal({
    required this.food,
    required this.amountGrams,
  });

  double get totalCalories => (food.calories * amountGrams) / 100;
  double get totalProtein => (food.protein * amountGrams) / 100;
  double get totalCarbs => (food.carbs * amountGrams) / 100;
  double get totalFat => (food.fat * amountGrams) / 100;
}
