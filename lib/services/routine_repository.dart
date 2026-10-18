import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine_models.dart';
import 'cloud_auth_service.dart';

/// Antrenman programlarını (PPL, Upper/Lower, 5x5, Full Body vb.) ve içeriklerini
/// hosting MySQL veritabanı üzerinden senkronize tutan servis.
class RoutineRepository extends ChangeNotifier {
  static final RoutineRepository instance = RoutineRepository._();
  RoutineRepository._();

  static const String _storageKey = 'gymtrack_cached_routines_v2';
  List<WorkoutRoutine> _routines = [];
  bool _isInitialized = false;

  List<WorkoutRoutine> get routines => _routines;
  bool get isInitialized => _isInitialized;

  /// Servisi başlatır; yerel önbelleği okur ve sunucudan arka planda senkronize eder
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedData);
        _routines = decoded.map((item) => WorkoutRoutine.fromMap(item)).toList();
      } else {
        _routines = List<WorkoutRoutine>.from(WorkoutRoutine.getDefaultRoutines());
        await _saveToLocal();
      }
    } catch (e) {
      debugPrint("RoutineRepository init error: $e");
      _routines = List<WorkoutRoutine>.from(WorkoutRoutine.getDefaultRoutines());
    }
    _isInitialized = true;
    notifyListeners();

    // Hosting veritabanından güncel antrenmanları çek
    syncFromWeb();
  }

  /// Hosting MySQL veritabanından güncel programları ve içeriklerini çeker
  Future<bool> syncFromWeb() async {
    try {
      final hostingBase = await CloudAuthService.instance.getHostingUrl();
      final endpoint = '$hostingBase/get_content.php?type=routines';
      final response = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic>? items;
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map && decoded['routines'] is List) {
          items = decoded['routines'];
        }

        if (items != null && items.isNotEmpty) {
          final List<WorkoutRoutine> fetched = items.map((item) => WorkoutRoutine.fromMap(item)).toList();
          _routines = fetched;
          await _saveToLocal();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("RoutineRepository syncFromWeb error: $e");
    }
    return false;
  }

  /// Yeni program ekler
  Future<void> addRoutine(WorkoutRoutine routine) async {
    _routines.insert(0, routine);
    await _saveToLocal();
    notifyListeners();
  }

  /// Mevcut programı günceller
  Future<void> updateRoutine(WorkoutRoutine updated) async {
    final index = _routines.indexWhere((r) => r.id == updated.id);
    if (index != -1) {
      _routines[index] = updated;
      await _saveToLocal();
      notifyListeners();
    }
  }

  /// Programı siler
  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((r) => r.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  /// Varsayılan antrenman programlarına sıfırlar
  Future<void> resetToDefaults() async {
    _routines = List<WorkoutRoutine>.from(WorkoutRoutine.getDefaultRoutines());
    await _saveToLocal();
    notifyListeners();
  }

  /// Yerel SharedPreferences'a kaydeder
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _routines.map((r) => r.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint("RoutineRepository save error: $e");
    }
  }
}
