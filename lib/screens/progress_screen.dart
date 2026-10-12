import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/user_profile.dart';
import '../utils/app_locale.dart';
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
    final history = profile.weightHistory;

    // Grafik min ve max değerlerini dinamik hesaplama
    double minWeight = profile.weightKg;
    double maxWeight = profile.weightKg;
    if (history.isNotEmpty) {
      final weights = history.map((e) => e.weight).toList();
      minWeight = weights.reduce((a, b) => a < b ? a : b);
      maxWeight = weights.reduce((a, b) => a > b ? a : b);
    }
    final chartMinY = (minWeight - 2).floorToDouble();
    final chartMaxY = (maxWeight + 2).ceilToDouble();

    final List<FlSpot> spots = [];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), history[i].weight));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('progress_title')),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: profile.avatarImage,
                  child: profile.avatarImage == null
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
            tooltip: AppLocale.get('account_title'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
              setState(() {});
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
                  child: _buildMetricCard(AppLocale.get('current_weight'), "${profile.weightKg} ${profile.weightUnit}", "${AppLocale.get('height_label')}: ${profile.heightCm.toInt()} ${profile.heightUnit}", AppTheme.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(AppLocale.get('target_weight_card'), "${profile.targetWeightKg} ${profile.weightUnit}", "${AppLocale.get('diff_label')}: ${(profile.weightKg - profile.targetWeightKg).abs().toStringAsFixed(1)} ${profile.weightUnit}", AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KİLO GRAFİĞİ BAŞLIĞI & AKSİYONLARI (Sıfırla & Ekle)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      AppLocale.get('weight_chart'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                  tooltip: AppLocale.get('reset_chart'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppTheme.cardColor,
                        title: Text(AppLocale.get('reset_chart')),
                        content: Text(AppLocale.isEnglish
                            ? "Weight history will be reset keeping only your current weight. Are you sure?"
                            : "Kilo geçmişi sıfırlanıp sadece güncel kilonuz korunacaktır. Emin misiniz?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocale.get('cancel'))),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () {
                              profile.resetWeightHistory();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocale.isEnglish ? "Weight chart reset! 🔄" : "Kilo grafiği sıfırlandı! 🔄")),
                              );
                            },
                            child: Text(AppLocale.get('reset'), style: const TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Kilo Grafiği Kartı
            Container(
              height: 230,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: spots.isEmpty
                  ? Center(
                      child: Text(AppLocale.get('no_weight_logs'), style: const TextStyle(color: AppTheme.textSecondary)),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
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
                              reservedSize: 36,
                              interval: (chartMaxY - chartMinY > 6) ? 2 : 1,
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
                                final index = value.toInt();
                                if (index >= 0 && index < history.length) {
                                  final d = history[index].date;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "${d.day}/${d.month}",
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
                        maxX: (spots.length > 1) ? (spots.length - 1).toDouble() : 1,
                        minY: chartMinY,
                        maxY: chartMaxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: spots.length > 2,
                            color: AppTheme.accent,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.accent.withOpacity(0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 28),

            // KİŞİSEL REKORLAR (PR) BAŞLIĞI & AKSİYONLARI (Tümünü Sil & Ekle)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      AppLocale.get('personal_records'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (profile.personalRecords.isNotEmpty)
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: Text(AppLocale.get('delete_all'), style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.cardColor,
                          title: Text(AppLocale.isEnglish ? "Delete Records" : "Rekorları Sil"),
                          content: Text(AppLocale.isEnglish
                              ? "Are you sure you want to delete all your personal records?"
                              : "Tüm kişisel rekorlarınızı silmek istediğinize emin misiniz?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocale.get('cancel'))),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () {
                                profile.clearAllPRs();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(AppLocale.isEnglish ? "All records cleared! 🗑️" : "Tüm rekorlar temizlendi! 🗑️")),
                                );
                              },
                              child: Text(AppLocale.get('delete'), style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (profile.personalRecords.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.military_tech_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(height: 10),
                    Text(
                      AppLocale.get('no_records_yet'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocale.get('no_records_hint'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...profile.personalRecords.map((pr) {
                return _buildPrItem(pr);
              }),

            const SizedBox(height: 20),
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
        border: Border.all(color: Colors.white10),
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

  Widget _buildPrItem(PersonalRecord pr) {
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
        title: Text(pr.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${AppLocale.get('est_1rm')}: ${pr.calculated1RM.toStringAsFixed(1)} kg • (${pr.reps} ${AppLocale.isEnglish ? 'reps' : 'tekrar'})",
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${pr.weight.toStringAsFixed(1)} ${UserSession.current.weightUnit}",
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              onPressed: () {
                UserSession.current.deletePR(pr.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${pr.exerciseName} rekoru silindi.")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
