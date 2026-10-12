import 'dart:convert';
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

  // Profil Fotoğrafı (URL / Avatar / Cihazdan Yüklenen Fotoğraf Base64)
  String? photoUrl;
  String? customPhotoBase64;

  UserProfile({
    this.name = 'Hüseyin Canlı',
    this.email = 'huseyin@gymtrack.com',
    this.photoUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    this.customPhotoBase64,
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
    String? newPhotoUrl,
    String? newCustomPhotoBase64,
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
    String? newGender,
    String? newBloodGroup,
    bool? newWorkoutReminders,
    bool? newMealReminders,
    bool? newWaterReminders,
  }) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newPhotoUrl != null) {
      photoUrl = newPhotoUrl;
      customPhotoBase64 = null; // hazır avatar seçildiyse base64 temizlenir
    }
    if (newCustomPhotoBase64 != null) {
      customPhotoBase64 = newCustomPhotoBase64;
    }
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
    if (newGender != null) gender = newGender;
    if (newBloodGroup != null) bloodGroup = newBloodGroup;
    if (newWorkoutReminders != null) workoutReminders = newWorkoutReminders;
    if (newMealReminders != null) mealReminders = newMealReminders;
    if (newWaterReminders != null) waterReminders = newWaterReminders;
    notifyListeners();
  }

  ImageProvider? get avatarImage {
    if (customPhotoBase64 != null && customPhotoBase64!.isNotEmpty) {
      try {
        final pureBase64 = customPhotoBase64!.contains(',')
            ? customPhotoBase64!.split(',').last
            : customPhotoBase64!;
        return MemoryImage(base64Decode(pureBase64));
      } catch (_) {
        // Hata durumunda photoUrl'ye düş
      }
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    }
    return null;
  }
}

// Global basit durum yönetimi
class UserSession {
  static final UserProfile current = UserProfile();
}
