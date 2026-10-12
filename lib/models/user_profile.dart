class UserProfile {
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
}

// Global basit durum yönetimi
class UserSession {
  static final UserProfile current = UserProfile();
}
