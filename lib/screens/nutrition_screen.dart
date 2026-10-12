import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/fitness_models.dart';
import '../models/user_profile.dart';
import '../utils/app_locale.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'barcode_scanner_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    UserSession.current.addListener(_onProfileChanged);
  }

  void _onProfileChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    UserSession.current.removeListener(_onProfileChanged);
    super.dispose();
  }

  final List<LoggedMeal> _todayMeals = [];

  double get targetCalories => UserSession.current.dailyCalorieGoal;
  // Sağlık ayrıntılarına (boy, kilo, yaş, cinsiyet) göre otomatik hesaplanan dinamik makrolar:
  double get targetProtein => UserSession.current.targetProteinGrams;
  double get targetCarbs => UserSession.current.targetCarbsGrams;
  double get targetFat => UserSession.current.targetFatGrams;

  double get consumedCalories => _todayMeals.fold(0, (sum, m) => sum + m.totalCalories);
  double get consumedProtein => _todayMeals.fold(0, (sum, m) => sum + m.totalProtein);
  double get consumedCarbs => _todayMeals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get consumedFat => _todayMeals.fold(0, (sum, m) => sum + m.totalFat);

  void _showCreateCustomFoodDialog({VoidCallback? onCreated}) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    String selectedCategory = 'Özel / Tarif';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.restaurant_menu, color: AppTheme.accent, size: 22),
                  SizedBox(width: 8),
                  Text("Kendi Besinini Ekle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kendi hazırladığın yiyecek veya tarifin 100g/ml değerlerini gir:",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Besin / Yemek Adı",
                        hintText: "Örn: Anne Köftesi, Protein Pankek",
                        filled: true,
                        fillColor: AppTheme.surfaceColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: calController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Kalori (kcal)",
                              suffixText: "kcal",
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            dropdownColor: AppTheme.surfaceColor,
                            decoration: InputDecoration(
                              labelText: "Kategori",
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Özel / Tarif', child: Text('Özel / Tarif', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Et & Protein', child: Text('Et & Protein', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Karbonhidrat', child: Text('Karbonhidrat', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'İçecek', child: Text('İçecek', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Atıştırmalık', child: Text('Atıştırmalık', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() => selectedCategory = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Makro Değerleri (100g için):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Protein (g)",
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: carbsController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Karb (g)",
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: fatController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: "Yağ (g)",
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Vazgeç"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final cal = double.tryParse(calController.text.replaceAll(',', '.')) ?? 0;
                    final protein = double.tryParse(proteinController.text.replaceAll(',', '.')) ?? 0;
                    final carbs = double.tryParse(carbsController.text.replaceAll(',', '.')) ?? 0;
                    final fat = double.tryParse(fatController.text.replaceAll(',', '.')) ?? 0;

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Lütfen besin adı giriniz!")),
                      );
                      return;
                    }

                    final newFood = FoodItem(
                      id: "custom_${DateTime.now().millisecondsSinceEpoch}",
                      name: name,
                      calories: cal,
                      protein: protein,
                      carbs: carbs,
                      fat: fat,
                      category: selectedCategory,
                    );

                    // Listeye en başa ekle
                    MockData.foods.insert(0, newFood);
                    Navigator.pop(context);
                    if (onCreated != null) {
                      onCreated();
                    } else {
                      setState(() {});
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✨ \"$name\" besinler listesine eklendi!"),
                        backgroundColor: AppTheme.accent,
                      ),
                    );

                    // Hemen gram seçme ekranını aç
                    _showGramPicker(newFood);
                  },
                  child: const Text("Kaydet & Ekle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddFoodModal() {
    String searchQuery = "";
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredFoods = MockData.foods.where((f) {
              return f.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                     f.category.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.45,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Üst Başlık & Kendi Besinini Ekle Butonu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Besin Listesi & Ekleme",
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Kendi Besinini Ekle", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              _showCreateCustomFoodDialog(
                                onCreated: () {
                                  setModalState(() {});
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "Yiyecek, içecek veya kategori ara...",
                                  border: InputBorder.none,
                                ),
                                onChanged: (val) {
                                  setModalState(() {
                                    searchQuery = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredFoods.length,
                        itemBuilder: (context, index) {
                          final food = filteredFoods[index];
                          final isCustom = food.id.startsWith("custom_");
                          return ListTile(
                            title: Row(
                              children: [
                                Expanded(child: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                                if (isCustom)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text("ÖZEL", style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              "${food.category} • ${food.calories.toStringAsFixed(0)} kcal | P:${food.protein}g C:${food.carbs}g Y:${food.fat}g (100g/ml)",
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Gram Seç", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                _showGramPicker(food, closeModal: true);
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showGramPicker(FoodItem food, {bool closeModal = false}) {
    double selectedGrams = 100;
    final controller = TextEditingController(text: "100");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final calculatedCal = (food.calories * selectedGrams) / 100;
            final calculatedProtein = (food.protein * selectedGrams) / 100;
            final calculatedCarbs = (food.carbs * selectedGrams) / 100;
            final calculatedFat = (food.fat * selectedGrams) / 100;

            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Porsiyon / Gramaj Miktarı (${food.category.contains('İçecek') ? 'ml' : 'g'}):",
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              suffixText: food.category.contains('İçecek') ? 'ml' : 'g',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedGrams = double.tryParse(val) ?? 0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Hızlı Porsiyon Butonları
                    Wrap(
                      spacing: 8,
                      children: [50, 100, 150, 200, 300].map((amount) {
                        return ChoiceChip(
                          label: Text("$amount${food.category.contains('İçecek') ? 'ml' : 'g'}"),
                          selected: selectedGrams == amount,
                          onSelected: (selected) {
                            setDialogState(() {
                              selectedGrams = amount.toDouble();
                              controller.text = amount.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Hesaplanan Besin Değerleri Özeti
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Toplam Kalori:", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "${calculatedCal.toStringAsFixed(0)} kcal",
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("P: ${calculatedProtein.toStringAsFixed(1)}g", style: const TextStyle(color: AppTheme.proteinColor, fontSize: 12)),
                              Text("K: ${calculatedCarbs.toStringAsFixed(1)}g", style: const TextStyle(color: AppTheme.carbColor, fontSize: 12)),
                              Text("Y: ${calculatedFat.toStringAsFixed(1)}g", style: const TextStyle(color: AppTheme.fatColor, fontSize: 12)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Vazgeç"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (selectedGrams > 0) {
                      setState(() {
                        _todayMeals.add(LoggedMeal(food: food, amountGrams: selectedGrams));
                      });
                      Navigator.pop(context); // Gram picker dialogunu kapat
                      if (closeModal && Navigator.canPop(context)) {
                        Navigator.pop(context); // Yalnızca liste modalından açıldıysa modalı kapat
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${food.name} (${selectedGrams.toInt()}${food.category.contains('İçecek') ? 'ml' : 'g'}) eklendi! 🥗"),
                          backgroundColor: AppTheme.surfaceColor,
                        ),
                      );
                    }
                  },
                  child: const Text("Öğüne Ekle", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calorieRatio = (consumedCalories / targetCalories).clamp(0.0, 1.0);
    final energyUnit = UserSession.current.energyUnit;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('nutrition_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primary),
            tooltip: AppLocale.get('barcode_scan'),
            onPressed: () async {
              final detectedFood = await Navigator.push<FoodItem>(
                context,
                MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
              );
              if (detectedFood != null && mounted) {
                _showGramPicker(detectedFood);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Kalori & Makro Özeti Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CircularPercentIndicator(
                          radius: 65.0,
                          lineWidth: 10.0,
                          percent: calorieRatio,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                consumedCalories.toStringAsFixed(0),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                "/ ${targetCalories.toStringAsFixed(0)} $energyUnit",
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          progressColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceColor,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMacroRow(AppLocale.get('protein'), consumedProtein, targetProtein, AppTheme.proteinColor),
                            const SizedBox(height: 12),
                            _buildMacroRow(AppLocale.get('carbs'), consumedCarbs, targetCarbs, AppTheme.carbColor),
                            const SizedBox(height: 12),
                            _buildMacroRow(AppLocale.get('fat'), consumedFat, targetFat, AppTheme.fatColor),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bugün Yenilenler Başlığı & Aksiyonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocale.get('today_meals'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    if (_todayMeals.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.redAccent, size: 20),
                        tooltip: AppLocale.get('reset_meals'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: Text(AppLocale.get('reset_meals')),
                              content: Text(AppLocale.isEnglish
                                  ? "Are you sure you want to reset all meals logged today?"
                                  : "Bugünkü eklenen tüm öğünleri sıfırlamak istediğinize emin misiniz?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocale.get('cancel'))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _todayMeals.clear();
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocale.isEnglish ? "Today's meals reset! 🔄" : "Bugünkü öğünler sıfırlandı! 🔄")),
                                    );
                                  },
                                  child: Text(AppLocale.get('reset'), style: const TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      icon: const Icon(Icons.restaurant_menu, size: 16),
                      label: Text(AppLocale.get('custom_food'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () => _showCreateCustomFoodDialog(),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppLocale.get('add_food'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: _showAddFoodModal,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (_todayMeals.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.no_meals_rounded, size: 54, color: Colors.white.withOpacity(0.25)),
                    const SizedBox(height: 12),
                    Text(
                      AppLocale.get('no_meals_yet'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocale.get('no_meals_hint'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _todayMeals.length,
              itemBuilder: (context, index) {
                final meal = _todayMeals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(meal.food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      "${meal.amountGrams.toStringAsFixed(0)}g | ${meal.totalCalories.toStringAsFixed(0)} kcal • P: ${meal.totalProtein.toStringAsFixed(1)}g",
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () {
                        setState(() {
                          _todayMeals.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String title, double current, double target, Color color) {
    final ratio = (current / target).clamp(0.0, 1.0);
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(
                "${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}g",
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            lineHeight: 6.0,
            percent: ratio,
            progressColor: color,
            backgroundColor: AppTheme.surfaceColor,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          )
        ],
      ),
    );
  }
}
