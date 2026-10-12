import 'package:flutter/material.dart';

class UserProfile extends ChangeNotifier {
  String name;
  String email;
  bool isLoggedIn;

  // Bildirim Tercihleri
  bool workoutReminders;
  bool mealReminders;
  bool waterReminders;

  // Sağlık Ayrıntıları
  double heightCm;
  double weightKg;
  int age;
  String gender;
  String bloodGroup;

  // Hedefler
  double targetWeightKg;
  double dailyCalorieGoal;
  double dailyWaterGoalLiters;
  int weeklyWorkoutDays;

  // Ölçü Birimleri
  String weightUnit; // "kg" veya "lbs"
  String heightUnit; // "cm" veya "inch"
  String energyUnit; // "kcal" veya "kJ"

  UserProfile({
    this.name = 'Hüseyin Canlı',
    this.email = 'huseyin@gymtrack.com',
    this.isLoggedIn = false,
    this.workoutReminders = true,
    this.mealReminders = true,
    this.waterReminders = false,
    this.heightCm = 178,
    this.weightKg = 76.4,
    this.age = 24,
    this.gender = 'Erkek',
    this.bloodGroup = 'A Rh+',
    this.targetWeightKg = 74.0,
    this.dailyCalorieGoal = 2400,
    this.dailyWaterGoalLiters = 3.0,
    this.weeklyWorkoutDays = 5,
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    this.energyUnit = 'kcal',
  });

  void updateProfile({
    String? newName,
    String? newEmail,
    bool? newIsLoggedIn,
    double? newHeight,
    double? newWeight,
    int? newAge,
    double? newTargetWeight,
    double? newDailyCalorie,
    double? newDailyWater,
    int? newWeeklyWorkouts,
    String? newWeightUnit,
    String? newHeightUnit,
    String? newEnergyUnit,
    bool? newWorkoutReminders,
    bool? newMealReminders,
    bool? newWaterReminders,
  }) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newIsLoggedIn != null) isLoggedIn = newIsLoggedIn;
    if (newHeight != null) heightCm = newHeight;
    if (newWeight != null) weightKg = newWeight;
    if (newAge != null) age = newAge;
    if (newTargetWeight != null) targetWeightKg = newTargetWeight;
    if (newDailyCalorie != null) dailyCalorieGoal = newDailyCalorie;
    if (newDailyWater != null) dailyWaterGoalLiters = newDailyWater;
    if (newWeeklyWorkouts != null) weeklyWorkoutDays = newWeeklyWorkouts;
    if (newWeightUnit != null) weightUnit = newWeightUnit;
    if (newHeightUnit != null) heightUnit = newHeightUnit;
    if (newEnergyUnit != null) energyUnit = newEnergyUnit;
    if (newWorkoutReminders != null) workoutReminders = newWorkoutReminders;
    if (newMealReminders != null) mealReminders = newMealReminders;
    if (newWaterReminders != null) waterReminders = newWaterReminders;
    notifyListeners();
  }
}

// Global basit durum yönetimi
class UserSession {
  static final UserProfile current = UserProfile();
}
