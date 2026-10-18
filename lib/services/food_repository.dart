import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import 'cloud_auth_service.dart';

/// Besinleri ve kalori/makro verilerini (görseller, kaloriler, protein, karbonhidrat, yağ)
/// hem hosting MySQL veritabanı üzerinden hem de yerel önbellekte yöneten servis.
class FoodRepository extends ChangeNotifier {
  static final FoodRepository instance = FoodRepository._();
  FoodRepository._();

  static const String _storageKey = 'gymtrack_cached_foods_v2';
  List<FoodItem> _foods = [];
  bool _isInitialized = false;

  List<FoodItem> get foods => _foods;
  bool get isInitialized => _isInitialized;

  /// Servisi başlatır; yerel önbelleği yükler ve sunucudan arka planda senkronize eder
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);

      if (savedData != null && savedData.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedData);
        _foods = decoded.map((item) => FoodItem.fromJson(item)).toList();
      } else {
        _foods = List<FoodItem>.from(MockData.foods);
        await _saveToLocal();
      }
    } catch (e) {
      debugPrint("FoodRepository init error: $e");
      _foods = List<FoodItem>.from(MockData.foods);
    }
    _isInitialized = true;
    notifyListeners();

    // Hosting veritabanından en güncel besinleri ve resimleri çek
    syncFromWeb();
  }

  /// Hosting MySQL veritabanından güncel besin listesini ve fotoğraflarını çeker
  Future<bool> syncFromWeb() async {
    try {
      final hostingBase = await CloudAuthService.instance.getHostingUrl();
      final endpoint = '$hostingBase/get_content.php?type=foods';
      final response = await http.get(Uri.parse(endpoint)).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic>? items;
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map && decoded['foods'] is List) {
          items = decoded['foods'];
        }

        if (items != null && items.isNotEmpty) {
          final List<FoodItem> fetched = items.map((item) => FoodItem.fromJson(item)).toList();
          _foods = fetched;
          await _saveToLocal();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("FoodRepository syncFromWeb error: $e");
    }
    return false;
  }

  /// Yeni besin ekler
  Future<void> addFood(FoodItem food) async {
    _foods.insert(0, food);
    await _saveToLocal();
    notifyListeners();
  }

  /// Mevcut besini günceller
  Future<void> updateFood(FoodItem updated) async {
    final index = _foods.indexWhere((f) => f.id == updated.id);
    if (index != -1) {
      _foods[index] = updated;
      await _saveToLocal();
      notifyListeners();
    }
  }

  /// Besini siler
  Future<void> deleteFood(String id) async {
    _foods.removeWhere((f) => f.id == id);
    await _saveToLocal();
    notifyListeners();
  }

  /// Varsayılan mock verilerine sıfırlar
  Future<void> resetToDefaults() async {
    _foods = List<FoodItem>.from(MockData.foods);
    await _saveToLocal();
    notifyListeners();
  }

  /// Yerel SharedPreferences'a kaydeder
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _foods.map((f) => f.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint("FoodRepository save error: $e");
    }
  }
}
