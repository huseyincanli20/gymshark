import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/fitness_models.dart';
import '../models/user_profile.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

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

  final List<LoggedMeal> _todayMeals = [
    LoggedMeal(food: MockData.foods[1], amountGrams: 80), // Yulaf
    LoggedMeal(food: MockData.foods[2], amountGrams: 150), // Yumurta
    LoggedMeal(food: MockData.foods[0], amountGrams: 200), // Tavuk
    LoggedMeal(food: MockData.foods[3], amountGrams: 200), // Pilav
  ];

  double get targetCalories => UserSession.current.dailyCalorieGoal;
  // Hedef kaloriye göre dengeli protein (25%), karbonhidrat (50%), yağ (25%)
  double get targetProtein => (targetCalories * 0.25) / 4;
  double get targetCarbs => (targetCalories * 0.50) / 4;
  double get targetFat => (targetCalories * 0.25) / 9;

  double get consumedCalories => _todayMeals.fold(0, (sum, m) => sum + m.totalCalories);
  double get consumedProtein => _todayMeals.fold(0, (sum, m) => sum + m.totalProtein);
  double get consumedCarbs => _todayMeals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get consumedFat => _todayMeals.fold(0, (sum, m) => sum + m.totalFat);

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
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.45,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
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
                          return ListTile(
                            title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                _showGramPicker(food);
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

  void _showGramPicker(FoodItem food) {
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
                          label: Text("${amount}${food.category.contains('İçecek') ? 'ml' : 'g'}"),
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
                      Navigator.pop(context); // Dialog kapat
                      Navigator.pop(context); // Modal kapat
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
        title: const Text("Beslenme & Makrolar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppTheme.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Barkod tarayıcı açılıyor...")),
              );
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
                            _buildMacroRow("Protein", consumedProtein, targetProtein, AppTheme.proteinColor),
                            const SizedBox(height: 12),
                            _buildMacroRow("Karb", consumedCarbs, targetCarbs, AppTheme.carbColor),
                            const SizedBox(height: 12),
                            _buildMacroRow("Yağ", consumedFat, targetFat, AppTheme.fatColor),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bugün Yenilenler Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Bugünün Öğünleri",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18, color: AppTheme.primary),
                  label: const Text("Besin Ekle", style: TextStyle(color: AppTheme.primary)),
                  onPressed: _showAddFoodModal,
                )
              ],
            ),

            const SizedBox(height: 8),

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
