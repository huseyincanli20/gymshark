import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import 'account_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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

  @override
  Widget build(BuildContext context) {
    final profile = UserSession.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text("İlerleme ve İstatistikler"),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                      ? NetworkImage(profile.photoUrl!)
                      : null,
                  child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                      ? Icon(
                          profile.isLoggedIn ? Icons.account_circle : Icons.account_circle_outlined,
                          size: 26,
                          color: profile.isLoggedIn ? AppTheme.accent : AppTheme.textPrimary,
                        )
                      : null,
                ),
                if (!profile.isLoggedIn)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: "Hesap & Ayarlar",
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
              setState(() {}); // Profil güncellendiyse ekranı yenile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Özet Metrik Kartları
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard("Mevcut Kilo", "${profile.weightKg} ${profile.weightUnit}", "Boy: ${profile.heightCm.toInt()} ${profile.heightUnit}", AppTheme.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard("Hedef Kilo", "${profile.targetWeightKg} ${profile.weightUnit}", "Fark: ${(profile.weightKg - profile.targetWeightKg).abs().toStringAsFixed(1)} ${profile.weightUnit}", AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              "Kilo Değişim Grafiği (Son 6 Hafta)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Kilo Grafiği
            Container(
              height: 220,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.surfaceColor,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.toInt()}",
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const weeks = ['H1', 'H2', 'H3', 'H4', 'H5', 'H6'];
                          final intVal = value.toInt();
                          if (value == intVal.toDouble() && intVal >= 0 && intVal < weeks.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                weeks[intVal],
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 74,
                  maxY: 80,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 78.5),
                        FlSpot(1, 78.0),
                        FlSpot(2, 77.8),
                        FlSpot(3, 77.1),
                        FlSpot(4, 76.9),
                        FlSpot(5, 76.4),
                      ],
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primary.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Kişisel Rekorlar (PR)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildPrItem("Barbell Bench Press", "105 kg", "1RM: 118 kg"),
            _buildPrItem("Barbell Back Squat", "140 kg", "1RM: 155 kg"),
            _buildPrItem("Deadlift", "170 kg", "1RM: 190 kg"),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPrItem(String exercise, String best, String calculated1rm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber),
        ),
        title: Text(exercise, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(calculated1rm, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: Text(
          best,
          style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
