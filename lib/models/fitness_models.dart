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
  final String videoUrl; // Demo video / mp4 / youtube / gif
  final String thumbnailUrl; // Fotoğraf veya Hareketli GIF URL
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

  Exercise copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    String? videoUrl,
    String? thumbnailUrl,
    String? instructions,
    String? tips,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup.name,
    'videoUrl': videoUrl,
    'thumbnailUrl': thumbnailUrl,
    'instructions': instructions,
    'tips': tips,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    MuscleGroup group = MuscleGroup.chest;
    final groupStr = (json['muscleGroup'] ?? '').toString().toLowerCase();
    for (var g in MuscleGroup.values) {
      if (g.name.toLowerCase() == groupStr) {
        group = g;
        break;
      }
    }

    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      muscleGroup: group,
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      tips: json['tips'] ?? '',
    );
  }
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
  String? customImageUrl;

  ActiveExerciseLog({
    required this.exercise,
    required this.sets,
    this.customImageUrl,
  });

  String get effectiveImageUrl =>
      (customImageUrl != null && customImageUrl!.isNotEmpty)
          ? customImageUrl!
          : exercise.thumbnailUrl;
}

class FoodItem {
  final String id;
  final String name;
  final double calories; // kcal per 100g
  final double protein;  // gram
  final double carbs;    // gram
  final double fat;      // gram
  final String category; // Et/Tavuk, Bakliyat, Meyve vs.
  final String imageUrl; // Fotoğraf veya görsel URL

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.category,
    this.imageUrl = '',
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? category,
    String? imageUrl,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'category': category,
    'imageUrl': imageUrl,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: (json['id'] ?? json['food_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      category: (json['category'] ?? 'Genel').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
    );
  }
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
