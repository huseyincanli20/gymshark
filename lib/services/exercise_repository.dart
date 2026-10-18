import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import 'cloud_auth_service.dart';

/// Egzersizleri ve hareket formlarını (talimatlar, ipuçları, hareketli GIF ve görseller)
/// hem internet sitesi / bulut API üzerinden hem de cihaz içi dinamik depolamada yöneten servis.
class ExerciseRepository extends ChangeNotifier {
  static final ExerciseRepository instance = ExerciseRepository._();
  ExerciseRepository._();

  static const String _storageKey = 'gymtrack_custom_and_edited_exercises_v1';
  static const String _cloudExercisesUrlKey = 'gymtrack_remote_exercises_api_endpoint';
  
  // Varsayılan API / İnternet üzerinden JSON veya GIF çekeceği endpoint (kullanıcı değiştirebilir veya özel web sitesine bağlayabilir)
  String _remoteApiEndpoint = 'https://huseyincanli.com/api/get_content.php?type=exercises';

  List<Exercise> _exercises = [];
  bool _isInitialized = false;

  List<Exercise> get exercises => _exercises;
  String get remoteApiEndpoint => _remoteApiEndpoint;

  /// Servisi başlatır; yerel depolamadaki düzenlenmiş egzersizleri ve GIF'leri yükler
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final hostingBase = await CloudAuthService.instance.getHostingUrl();
      final defaultEndpoint = '$hostingBase/get_content.php?type=exercises';
      _remoteApiEndpoint = prefs.getString(_cloudExercisesUrlKey) ?? defaultEndpoint;
      final savedData = prefs.getString(_storageKey);

      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedData);
        _exercises = decoded.map((item) => Exercise.fromJson(item)).toList();
      } else {
        // İlk açılışta MockData'daki varsayılan egzersizlerle başla
        _exercises = List<Exercise>.from(MockData.exercises);
        await _saveToLocal();
      }
    } catch (e) {
      debugPrint("ExerciseRepository init error: $e");
      _exercises = List<Exercise>.from(MockData.exercises);
    }
    _isInitialized = true;
    notifyListeners();

    // Hosting veritabanından güncel egzersizleri ve GIF'leri çek
    syncFromWeb();
  }

  /// Uzak API adresini günceller
  Future<void> setRemoteApiEndpoint(String newUrl) async {
    _remoteApiEndpoint = newUrl.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cloudExercisesUrlKey, _remoteApiEndpoint);
    notifyListeners();
  }

  /// İnternet sitesinden / Web API'den güncel egzersiz listesini ve GIF'leri çeker
  Future<bool> syncFromWeb({String? customUrl}) async {
    String urlToUse = customUrl?.trim() ?? _remoteApiEndpoint;
    if (customUrl == null) {
      try {
        final hostingBase = await CloudAuthService.instance.getHostingUrl();
        urlToUse = '$hostingBase/get_content.php?type=exercises';
      } catch (_) {}
    }
    try {
      final response = await http.get(Uri.parse(urlToUse)).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> items;
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map && decoded['exercises'] is List) {
          items = decoded['exercises'];
        } else {
          return false;
        }

        final List<Exercise> fetched = items.map((item) => Exercise.fromJson(item)).toList();
        if (fetched.isNotEmpty) {
          _exercises = fetched;
          await _saveToLocal();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("syncFromWeb error: $e");
    }
    return false;
  }

  /// JSON metnini doğrudan içe aktarır (Web sitesinden kopyalanan veya webhook ile gelen veriler)
  Future<bool> importFromJsonString(String jsonString) async {
    try {
      final dynamic decoded = jsonDecode(jsonString.trim());
      List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded['exercises'] is List) {
        items = decoded['exercises'];
      } else {
        return false;
      }

      final List<Exercise> parsed = items.map((item) => Exercise.fromJson(item)).toList();
      if (parsed.isNotEmpty) {
        _exercises = parsed;
        await _saveToLocal();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("importFromJsonString error: $e");
    }
    return false;
  }

  /// Mevcut egzersizlerin tümünü JSON metni olarak dışa aktarır (Web paneline yüklemek için)
  String exportToJsonString() {
    return const JsonEncoder.withIndent('  ').convert(_exercises.map((e) => e.toJson()).toList());
  }

  /// Tek bir egzersizi günceller (Form talimatı, ipuçları veya .gif linki)
  Future<void> updateExercise(Exercise updated) async {
    final index = _exercises.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _exercises[index] = updated;
      await _saveToLocal();
      notifyListeners();
    }
  }

  /// Yeni egzersiz & form ekler
  Future<void> addExercise(Exercise newExercise) async {
    _exercises.insert(0, newExercise);
    await _saveToLocal();
    notifyListeners();
  }

  /// Egzersizi siler
  Future<void> deleteExercise(String id) async {
    _exercises.removeWhere((e) => e.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  /// Fabrika ayarlarına / orijinal egzersiz listesine sıfırlar
  Future<void> resetToDefaults() async {
    _exercises = List<Exercise>.from(MockData.exercises);
    await _saveToLocal();
    notifyListeners();
  }

  /// Yerel SharedPreferences'a kalıcı olarak kaydeder
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _exercises.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint("ExerciseRepository save error: $e");
    }
  }
}
