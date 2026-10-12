import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import '../models/user_profile.dart';

class HealthKitService {
  static final HealthKitService instance = HealthKitService._internal();
  HealthKitService._internal();

  final Health _health = Health();
  bool _isConfigured = false;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  // Canlı Pedometer Akışı
  Stream<StepCount>? _stepCountStream;
  int _lastStreamSteps = 0;

  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  // Desteklenen sağlık veri tipleri: Adım ve Aktif Kalori
  final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  final List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _ensureConfigured() async {
    if (_isConfigured) return;
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await _health.configure();
        _initLivePedometerStream();
      }
      _isConfigured = true;
    } catch (e) {
      debugPrint("Health configure error: $e");
    }
  }

  /// Telefonun hareket sensörlerini (Apple CoreMotion / Pedometer) canlı dinler
  void _initLivePedometerStream() {
    if (kIsWeb) return;
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream?.listen(
        (StepCount event) {
          debugPrint("Live Pedometer Step event: ${event.steps}");
          _lastStreamSteps = event.steps;
          final profile = UserSession.current;
          if (event.steps > 0 && event.steps != profile.todaySteps) {
            profile.syncStepsFromHealth(event.steps);
            // Her adım için Apple Fitness kalorisi hesapla
            final stepCal = (event.steps * 0.042);
            if (stepCal > profile.todayBurnedCalories) {
              profile.syncBurnedCaloriesFromHealth(stepCal);
            }
          }
        },
        onError: (error) {
          debugPrint("Pedometer stream error: $error");
        },
      );
    } catch (e) {
      debugPrint("Pedometer initialization error: $e");
    }
  }

  /// Apple Fitness veya Android Health Connect'ten izin iste
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      _lastSyncMessage = "Web platformunda Fitness uygulaması desteklenmez.";
      return false;
    }

    try {
      await _ensureConfigured();
      final granted = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );
      debugPrint("requestAuthorization result: $granted");
      return granted;
    } catch (e) {
      debugPrint("Health requestAuthorization error: $e");
      _lastSyncMessage = "İzin isteği sırasında hata: $e";
      return false;
    }
  }

  /// Canlı olarak bugünkü adım ve yakılan kalori verilerini çekip UserSession'a kaydeder
  Future<bool> syncTodayHealthData({bool requestIfNoAuth = true}) async {
    if (kIsWeb) {
      _lastSyncMessage = "Web ortamında Fitness verisi simüle edildi.";
      return false;
    }

    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      await _ensureConfigured();

      // 1. Apple Health / Fitness izin isteme diyaloğunu tetikle
      if (requestIfNoAuth) {
        try {
          await _health.requestAuthorization(
            _dataTypes,
            permissions: _permissions,
          );
        } catch (e) {
          debugPrint("Health requestAuthorization prompt error: $e");
        }
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

      // 2. Adım Verisini Çek (Önce HealthKit, başarısızsa CoreMotion Pedometer)
      int? steps;
      try {
        steps = await _health.getTotalStepsInInterval(startOfDay, now);
      } catch (e) {
        debugPrint("getTotalStepsInInterval error: $e");
      }

      if ((steps == null || steps == 0) && _lastStreamSteps > 0) {
        steps = _lastStreamSteps;
      }

      // 3. Yakılan Aktif Kaloriyi Çek (Apple Fitness Move / Hareket Kalorisi)
      double burnedCalories = 0.0;
      try {
        final caloriePoints = await _health.getHealthDataFromTypes(
          types: [HealthDataType.ACTIVE_ENERGY_BURNED],
          startTime: startOfDay,
          endTime: now,
        );

        for (final p in caloriePoints) {
          final val = p.value;
          if (val is NumericHealthValue) {
            burnedCalories += val.numericValue.toDouble();
          }
        }
      } catch (e) {
        debugPrint("getHealthDataFromTypes ACTIVE_ENERGY_BURNED error: $e");
      }

      // Eğer HealthKit doğrudan 0 döndüyse ve adım varsa adımlardan harcanan kaloriyi de ekle
      if (burnedCalories == 0.0 && steps != null && steps > 0) {
        burnedCalories = steps * 0.042;
      }

      // Verileri UserSession profiline aktar
      final profile = UserSession.current;
      bool hasChanges = false;

      if (steps != null && steps > 0) {
        profile.syncStepsFromHealth(steps);
        hasChanges = true;
      }

      if (burnedCalories > 0) {
        profile.syncBurnedCaloriesFromHealth(burnedCalories);
        hasChanges = true;
      }

      if (hasChanges) {
        _lastSyncMessage = "Fitness verileri güncellendi: ${profile.todaySteps} adım, ${profile.todayBurnedCalories.toInt()} kcal 🔥";
      } else {
        _lastSyncMessage = "Fitness bağlantısı aktif (Bugün henüz yeni veri kaydedilmemiş).";
      }

      _isSyncing = false;
      return true;
    } catch (e) {
      debugPrint("Health sync error: $e");
      _lastSyncMessage = "Senkronizasyon hatası: $e";
      _isSyncing = false;
      return false;
    }
  }
}
