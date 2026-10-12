import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fitness_models.dart';

class OpenFoodFactsService {
  /// Open Food Facts API üzerinden barkod numarasıyla gerçek ürün sorgular
  static Future<FoodItem?> fetchFoodByBarcode(String barcode) async {
    try {
      final cleanCode = barcode.trim();
      if (cleanCode.isEmpty) return null;

      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$cleanCode.json');
      final response = await http.get(url, headers: {
        'User-Agent': 'GymTrack - Flutter Fitness App - Android/iOS',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 && data['product'] != null) {
          final p = data['product'];
          final nutriments = p['nutriments'] ?? {};

          // Ürün adı
          String name = (p['product_name_tr'] != null && (p['product_name_tr'] as String).trim().isNotEmpty)
              ? p['product_name_tr']
              : (p['product_name'] ?? 'Barkodlu Besin ($cleanCode)');

          // Marka bilgisi varsa başa ekle
          if (p['brands'] != null && (p['brands'] as String).trim().isNotEmpty) {
            final brand = (p['brands'] as String).split(',').first.trim();
            if (!name.toLowerCase().contains(brand.toLowerCase())) {
              name = "$brand $name";
            }
          }

          // 100g/ml için besin değerleri
          double calories = _toDouble(nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal']);
          if (calories == 0) {
            // Eğer kJ cinsindense kcal'ye çevir (1 kcal ≈ 4.184 kJ)
            final energyKj = _toDouble(nutriments['energy_100g'] ?? nutriments['energy']);
            if (energyKj > 0) {
              calories = energyKj / 4.184;
            }
          }

          final protein = _toDouble(nutriments['proteins_100g'] ?? nutriments['proteins']);
          final carbs = _toDouble(nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates']);
          final fat = _toDouble(nutriments['fat_100g'] ?? nutriments['fat']);

          // Kategori
          String category = 'Paketli Ürün';
          if (p['categories'] != null) {
            final cats = (p['categories'] as String).toLowerCase();
            if (cats.contains('beverage') || cats.contains('içecek') || cats.contains('drink') || cats.contains('milk') || cats.contains('süt')) {
              category = 'İçecek';
            } else if (cats.contains('snack') || cats.contains('bar') || cats.contains('atıştırmalık') || cats.contains('chocolate') || cats.contains('biscuit')) {
              category = 'Atıştırmalık';
            } else if (cats.contains('meat') || cats.contains('chicken') || cats.contains('et') || cats.contains('tavuk') || cats.contains('protein')) {
              category = 'Et & Protein';
            } else if (cats.contains('bread') || cats.contains('cereal') || cats.contains('oat') || cats.contains('yulaf') || cats.contains('rice') || cats.contains('pasta')) {
              category = 'Karbonhidrat';
            }
          }

          return FoodItem(
            id: 'barcode_$cleanCode',
            name: name,
            calories: calories > 0 ? calories : 150.0,
            protein: protein,
            carbs: carbs,
            fat: fat,
            category: category,
          );
        }
      }
    } catch (_) {
      // Ağ hatası veya zaman aşımı durumunda fallback çalışır
    }
    return null;
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }
}
