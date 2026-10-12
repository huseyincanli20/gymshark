import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final double _targetCalories = 2400;
  final double _targetProtein = 160;
  final double _targetCarbs = 260;
  final double _targetFat = 70;

  final List<LoggedMeal> _todayMeals = [
    LoggedMeal(food: MockData.foods[1], amountGrams: 80), // Yulaf
    LoggedMeal(food: MockData.foods[2], amountGrams: 150), // Yumurta
    LoggedMeal(food: MockData.foods[0], amountGrams: 200), // Tavuk
    LoggedMeal(food: MockData.foods[3], amountGrams: 200), // Pilav
  ];

  double get consumedCalories => _todayMeals.fold(0, (sum, m) => sum + m.totalCalories);
  double get consumedProtein => _todayMeals.fold(0, (sum, m) => sum + m.totalProtein);
  double get consumedCarbs => _todayMeals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get consumedFat => _todayMeals.fold(0, (sum, m) => sum + m.totalFat);

  void _showAddFoodModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Besin veya yemek ara...",
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {},
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: MockData.foods.length,
                    itemBuilder: (context, index) {
                      final food = MockData.foods[index];
                      return ListTile(
                        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "${food.calories.toStringAsFixed(0)} kcal | P: ${food.protein}g C: ${food.carbs}g F: ${food.fat}g (100g)",
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: AppTheme.accent),
                          onPressed: () {
                            setState(() {
                              _todayMeals.add(LoggedMeal(food: food, amountGrams: 100));
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${food.name} (100g) eklendi!")),
                            );
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
  }

  @override
  Widget build(BuildContext context) {
    final calorieRatio = (consumedCalories / _targetCalories).clamp(0.0, 1.0);

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
                              const Text(
                                "Kalan kcal",
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
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
                            _buildMacroRow("Protein", consumedProtein, _targetProtein, AppTheme.proteinColor),
                            const SizedBox(height: 12),
                            _buildMacroRow("Karb", consumedCarbs, _targetCarbs, AppTheme.carbColor),
                            const SizedBox(height: 12),
                            _buildMacroRow("Yağ", consumedFat, _targetFat, AppTheme.fatColor),
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
