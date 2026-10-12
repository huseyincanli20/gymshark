import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightLogEntry {
  final DateTime date;
  final double weight;
  final String note;

  WeightLogEntry({
    required this.date,
    required this.weight,
    this.note = '',
  });
}

class PersonalRecord {
  final String id;
  final String exerciseName;
  double weight;
  int reps;
  DateTime date;

  PersonalRecord({
    required this.id,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.date,
  });

  // Brzycki 1RM hesaplama formülü: weight * (36 / (37 - reps))
  double get calculated1RM {
    if (reps <= 1) return weight;
    if (reps >= 37) return weight;
    return weight * (36 / (37 - reps));
  }
}

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

  // Günlük Yakılan Kalori ve Adım Sayar
  double todayBurnedCalories = 0.0;
  int todaySteps = 0;
  int stepGoal = 8000;

  // Haftalık Tamamlanan Günler: 1: Pzt, 2: Sal, 3: Çar, 4: Per, 5: Cum, 6: Cmt, 7: Paz
  Set<int> completedDaysThisWeek = {};

  // Kilo Geçmişi Kayıtları (Dinamik ve Sıfırlanabilir)
  List<WeightLogEntry> weightHistory = [];

  // Kişisel Rekorlar (PR) (Dinamik, Silinebilir ve Eklenebilir)
  List<PersonalRecord> personalRecords = [];

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
  }) {
    // Otomatik kalori ve makro hesapla
    _recalculateNutrition();

    // Başlangıç kilo geçmişi: Mevcut kilodan başlar
    weightHistory = [
      WeightLogEntry(
        date: DateTime.now().subtract(const Duration(days: 14)),
        weight: weightKg + 1.6,
        note: 'Başlangıç',
      ),
      WeightLogEntry(
        date: DateTime.now().subtract(const Duration(days: 7)),
        weight: weightKg + 0.8,
        note: 'Geçen Hafta',
      ),
      WeightLogEntry(
        date: DateTime.now(),
        weight: weightKg,
        note: 'Güncel',
      ),
    ];
  }

  // Mifflin-St Jeor Formülü ile BMR ve TDEE bazlı Dinamik Kalori & Makro Hesaplama
  void _recalculateNutrition() {
    // BMR (Bazal Metabolizma Hızı)
    double bmr;
    if (gender == 'Kadın') {
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    } else {
      // Erkek veya varsayılan
      bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    }

    // Haftalık spor gününe göre aktivite çarpanı (1.2 - 1.6 aralığı)
    double activityMultiplier = 1.2 + (weeklyWorkoutDays * 0.06);
    double tdee = bmr * activityMultiplier;

    // Kilo verme / alma / koruma hedefine göre kalori ayarı
    double calculatedCalories;
    if (targetWeightKg < weightKg - 0.5) {
      // Kilo verme: 400 kcal açık
      calculatedCalories = tdee - 400;
    } else if (targetWeightKg > weightKg + 0.5) {
      // Kilo alma / Kas inşası: 350 kcal fazla
      calculatedCalories = tdee + 350;
    } else {
      // Kilo koruma
      calculatedCalories = tdee;
    }

    dailyCalorieGoal = calculatedCalories.clamp(1200.0, 5000.0).roundToDouble();

    // Su hedefi: Kilo başına 35-40 ml
    dailyWaterGoalLiters = double.parse(((weightKg * 0.038).clamp(2.0, 5.0)).toStringAsFixed(1));
  }

  // Sporcu makro hesaplaması:
  // Protein: Kilo başına 2.0g (sporcu standardı) -> 4 kcal/g
  // Yağ: Toplam kalorinin %25'i -> 9 kcal/g
  // Karbonhidrat: Kalan kaloriler -> 4 kcal/g
  double get targetProteinGrams {
    return double.parse((weightKg * 2.0).clamp(60.0, 300.0).toStringAsFixed(1));
  }

  double get targetFatGrams {
    final fatCal = dailyCalorieGoal * 0.25;
    return double.parse((fatCal / 9).clamp(30.0, 150.0).toStringAsFixed(1));
  }

  double get targetCarbsGrams {
    final proteinCal = targetProteinGrams * 4;
    final fatCal = targetFatGrams * 9;
    final remainingCal = dailyCalorieGoal - (proteinCal + fatCal);
    return double.parse(((remainingCal > 0 ? remainingCal : 400) / 4).clamp(50.0, 600.0).toStringAsFixed(1));
  }

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
    bool healthMetricsChanged = false;

    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newPhotoUrl != null) {
      photoUrl = newPhotoUrl;
      customPhotoBase64 = null;
    }
    if (newCustomPhotoBase64 != null) {
      customPhotoBase64 = newCustomPhotoBase64;
    }
    if (newIsLoggedIn != null) isLoggedIn = newIsLoggedIn;

    if (newHeight != null && newHeight != heightCm) {
      heightCm = newHeight;
      healthMetricsChanged = true;
    }
    if (newWeight != null && newWeight != weightKg) {
      weightKg = newWeight;
      healthMetricsChanged = true;
      // Yeni kiloyu kilo geçmişine de ekle
      addWeightLog(newWeight, note: 'Manuel Güncelleme');
    }
    if (newAge != null && newAge != age) {
      age = newAge;
      healthMetricsChanged = true;
    }
    if (newGender != null && newGender != gender) {
      gender = newGender;
      healthMetricsChanged = true;
    }
    if (newTargetWeight != null && newTargetWeight != targetWeightKg) {
      targetWeightKg = newTargetWeight;
      healthMetricsChanged = true;
    }
    if (newWeeklyWorkouts != null && newWeeklyWorkouts != weeklyWorkoutDays) {
      weeklyWorkoutDays = newWeeklyWorkouts;
      healthMetricsChanged = true;
    }

    if (newDailyCalorie != null) dailyCalorieGoal = newDailyCalorie;
    if (newDailyWater != null) dailyWaterGoalLiters = newDailyWater;
    if (newWeightUnit != null) weightUnit = newWeightUnit;
    if (newHeightUnit != null) heightUnit = newHeightUnit;
    if (newEnergyUnit != null) energyUnit = newEnergyUnit;
    if (newBloodGroup != null) bloodGroup = newBloodGroup;
    if (newWorkoutReminders != null) workoutReminders = newWorkoutReminders;
    if (newMealReminders != null) mealReminders = newMealReminders;
    if (newWaterReminders != null) waterReminders = newWaterReminders;

    // Boy, kilo, yaş veya cinsiyet değiştiğinde otomatik kalori ve makroları yeniden hesapla
    if (healthMetricsChanged) {
      _recalculateNutrition();
    }

    notifyListeners();
    saveToPrefs();
  }

  // --- HAFTALIK AKTİVİTE YÖNETİMİ ---
  void logWorkoutForToday() {
    final todayWeekday = DateTime.now().weekday; // 1: Pzt, 7: Paz
    completedDaysThisWeek.add(todayWeekday);
    notifyListeners();
    saveToPrefs();
  }

  void resetWeeklyActivity() {
    completedDaysThisWeek.clear();
    notifyListeners();
    saveToPrefs();
  }

  // --- GÜNLÜK YAKILAN KALORİ & ADIM YÖNETİMİ ---
  void addBurnedCalories(double calories) {
    todayBurnedCalories += calories;
    notifyListeners();
    saveToPrefs();
  }

  void addSteps(int steps) {
    todaySteps += steps;
    // Her 1000 adım ortalama 40-45 kcal yakar
    final stepCalories = (steps * 0.042);
    todayBurnedCalories += stepCalories;
    notifyListeners();
    saveToPrefs();
  }

  void setSteps(int steps) {
    final diff = steps - todaySteps;
    todaySteps = steps;
    if (diff > 0) {
      todayBurnedCalories += (diff * 0.042);
    }
    notifyListeners();
    saveToPrefs();
  }

  /// Doğrudan Apple Health / Google Health Connect'ten canlı adımı aktarır
  void syncStepsFromHealth(int steps) {
    todaySteps = steps;
    notifyListeners();
    saveToPrefs();
  }

  /// Doğrudan Apple Health / Google Health Connect'ten canlı yakılan kaloriyi aktarır
  void syncBurnedCaloriesFromHealth(double calories) {
    todayBurnedCalories = calories;
    notifyListeners();
    saveToPrefs();
  }

  void resetDailyBurnedAndSteps() {
    todayBurnedCalories = 0.0;
    todaySteps = 0;
    notifyListeners();
    saveToPrefs();
  }

  // --- KİLO GEÇMİŞİ VE GRAFİK YÖNETİMİ ---
  void addWeightLog(double weight, {String note = ''}) {
    weightHistory.add(WeightLogEntry(date: DateTime.now(), weight: weight, note: note));
    notifyListeners();
  }

  void resetWeightHistory() {
    weightHistory = [
      WeightLogEntry(date: DateTime.now(), weight: weightKg, note: 'Güncel Kilo'),
    ];
    notifyListeners();
  }

  void removeWeightLog(int index) {
    if (index >= 0 && index < weightHistory.length) {
      weightHistory.removeAt(index);
      notifyListeners();
    }
  }

  // --- KİŞİSEL REKORLAR (PR) YÖNETİMİ ---
  void addOrUpdatePR({
    required String exerciseName,
    required double weight,
    required int reps,
  }) {
    final existingIndex = personalRecords.indexWhere(
      (pr) => pr.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Var olan rekoru güncelle
      personalRecords[existingIndex].weight = weight;
      personalRecords[existingIndex].reps = reps;
      personalRecords[existingIndex].date = DateTime.now();
    } else {
      // Yeni rekor ekle
      personalRecords.add(
        PersonalRecord(
          id: 'pr_${DateTime.now().millisecondsSinceEpoch}',
          exerciseName: exerciseName,
          weight: weight,
          reps: reps,
          date: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  void deletePR(String id) {
    personalRecords.removeWhere((pr) => pr.id == id);
    notifyListeners();
  }

  void clearAllPRs() {
    personalRecords.clear();
    notifyListeners();
  }

  // --- KALICI VERİ SAKLAMA (SharedPreferences) ---
  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', isLoggedIn);
      await prefs.setString('name', name);
      await prefs.setString('email', email);
      if (photoUrl != null) await prefs.setString('photoUrl', photoUrl!);
      if (customPhotoBase64 != null) {
        await prefs.setString('customPhotoBase64', customPhotoBase64!);
      } else {
        await prefs.remove('customPhotoBase64');
      }
      await prefs.setDouble('heightCm', heightCm);
      await prefs.setDouble('weightKg', weightKg);
      await prefs.setInt('age', age);
      await prefs.setString('gender', gender);
      await prefs.setString('bloodGroup', bloodGroup);
      await prefs.setDouble('targetWeightKg', targetWeightKg);
      await prefs.setDouble('dailyCalorieGoal', dailyCalorieGoal);
      await prefs.setDouble('dailyWaterGoalLiters', dailyWaterGoalLiters);
      await prefs.setInt('weeklyWorkoutDays', weeklyWorkoutDays);
      await prefs.setDouble('todayBurnedCalories', todayBurnedCalories);
      await prefs.setInt('todaySteps', todaySteps);
      await prefs.setInt('stepGoal', stepGoal);
      await prefs.setStringList(
        'completedDaysThisWeek',
        completedDaysThisWeek.map((e) => e.toString()).toList(),
      );
    } catch (_) {
      // Hata durumunda sessizce devam et
    }
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      name = prefs.getString('name') ?? name;
      email = prefs.getString('email') ?? email;
      photoUrl = prefs.getString('photoUrl') ?? photoUrl;
      customPhotoBase64 = prefs.getString('customPhotoBase64') ?? customPhotoBase64;
      heightCm = prefs.getDouble('heightCm') ?? heightCm;
      weightKg = prefs.getDouble('weightKg') ?? weightKg;
      age = prefs.getInt('age') ?? age;
      gender = prefs.getString('gender') ?? gender;
      bloodGroup = prefs.getString('bloodGroup') ?? bloodGroup;
      targetWeightKg = prefs.getDouble('targetWeightKg') ?? targetWeightKg;
      dailyCalorieGoal = prefs.getDouble('dailyCalorieGoal') ?? dailyCalorieGoal;
      dailyWaterGoalLiters = prefs.getDouble('dailyWaterGoalLiters') ?? dailyWaterGoalLiters;
      weeklyWorkoutDays = prefs.getInt('weeklyWorkoutDays') ?? weeklyWorkoutDays;
      todayBurnedCalories = prefs.getDouble('todayBurnedCalories') ?? todayBurnedCalories;
      todaySteps = prefs.getInt('todaySteps') ?? todaySteps;
      stepGoal = prefs.getInt('stepGoal') ?? stepGoal;

      final daysList = prefs.getStringList('completedDaysThisWeek');
      if (daysList != null) {
        completedDaysThisWeek = daysList.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
      }

      _recalculateNutrition();
      notifyListeners();
    } catch (_) {
      // Hata durumunda sessizce devam et
    }
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

  static Future<void> init() async {
    await current.loadFromPrefs();
  }
}
