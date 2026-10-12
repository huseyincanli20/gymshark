import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../models/user_profile.dart';

class HealthKitService {
  static final HealthKitService instance = HealthKitService._internal();
  HealthKitService._internal();

  final Health _health = Health();
  bool _isConfigured = false;
  bool _isSyncing = false;
  String? _lastSyncMessage;

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
      }
      _isConfigured = true;
    } catch (e) {
      debugPrint("Health configure error: $e");
    }
  }

  /// Apple Health veya Android Health Connect'ten izin iste
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      _lastSyncMessage = "Web platformunda sağlık uygulaması desteklenmez.";
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
      _lastSyncMessage = "Web ortamında HealthKit simüle edildi.";
      return false;
    }

    if (_isSyncing) return false;
    _isSyncing = true;

    try {
      await _ensureConfigured();

      // Apple Health / Health Connect izin isteme diyaloğunu doğrudan tetikle
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

      // 1. Adım Verisini Çek
      int? steps;
      try {
        steps = await _health.getTotalStepsInInterval(startOfDay, now);
      } catch (e) {
        debugPrint("getTotalStepsInInterval error: $e");
      }

      // 2. Yakılan Aktif Kaloriyi Çek
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
        _lastSyncMessage = "Sağlık uygulamasından güncellendi: ${steps ?? 0} adım, ${burnedCalories.toInt()} kcal 🔥";
      } else {
        _lastSyncMessage = "Bağlantı kuruldu (Bugün için yeni veri bulunamadı).";
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
