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

  void _showAddWeightDialog() {
    final controller = TextEditingController(text: UserSession.current.weightKg.toString());
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.monitor_weight_outlined, color: AppTheme.accent),
            SizedBox(width: 8),
            Text("Yeni Kilo Kaydı Ekle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Kilo (${UserSession.current.weightUnit})",
                suffixText: UserSession.current.weightUnit,
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: "Not (Örn: Sabah aç karnına)",
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              final w = double.tryParse(controller.text.replaceAll(',', '.'));
              if (w != null && w > 0) {
                UserSession.current.updateProfile(newWeight: w);
                UserSession.current.addWeightLog(w, note: noteController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Kilo kaydı ($w ${UserSession.current.weightUnit}) grafiğe eklendi! 📉"),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              }
            },
            child: const Text("Kaydet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddPRDialog() {
    final nameCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final repsCtrl = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text("Yeni Rekor (PR) Ekle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: "Egzersiz Adı",
                hintText: "Örn: Barbell Bench Press",
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Ağırlık (${UserSession.current.weightUnit})",
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: repsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Tekrar",
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final w = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0;
              final r = int.tryParse(repsCtrl.text) ?? 1;
              if (name.isNotEmpty && w > 0) {
                UserSession.current.addOrUpdatePR(exerciseName: name, weight: w, reps: r);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$name PR kaydı eklendi! 🏆"), backgroundColor: AppTheme.accent),
                );
              }
            },
            child: const Text("Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        title: const Text("İlerleme ve İstatistikler"),
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
            tooltip: "Hesap & Ayarlar",
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
                  child: _buildMetricCard("Mevcut Kilo", "${profile.weightKg} ${profile.weightUnit}", "Boy: ${profile.heightCm.toInt()} ${profile.heightUnit}", AppTheme.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard("Hedef Kilo", "${profile.targetWeightKg} ${profile.weightUnit}", "Fark: ${(profile.weightKg - profile.targetWeightKg).abs().toStringAsFixed(1)} ${profile.weightUnit}", AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // KİLO GRAFİĞİ BAŞLIĞI & AKSİYONLARI (Sıfırla & Ekle)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.show_chart, color: AppTheme.primary, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "Kilo Değişim Grafiği",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textSecondary),
                      tooltip: "Grafiği Sıfırla",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.cardColor,
                            title: const Text("Kilo Grafiğini Sıfırla"),
                            content: const Text("Kilo geçmişi sıfırlanıp sadece güncel kilonuz korunacaktır. Emin misiniz?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                onPressed: () {
                                  profile.resetWeightHistory();
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Kilo grafiği sıfırlandı! 🔄")),
                                  );
                                },
                                child: const Text("Sıfırla", style: TextStyle(color: Colors.white)),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 22, color: AppTheme.accent),
                      tooltip: "Yeni Kilo Kaydı Ekle",
                      onPressed: _showAddWeightDialog,
                    ),
                  ],
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
                  ? const Center(
                      child: Text("Henüz kilo kaydı bulunmuyor. '+' butonu ile ekleyebilirsiniz.", style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  : LineChart(
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
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Kişisel Rekorlar (PR)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (profile.personalRecords.isNotEmpty)
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: const Text("Tümünü Sil", style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: const Text("Rekorları Sil"),
                              content: const Text("Tüm kişisel rekorlarınızı silmek istediğinize emin misiniz?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () {
                                    profile.clearAllPRs();
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Tüm rekorlar temizlendi! 🗑️")),
                                    );
                                  },
                                  child: const Text("Sil", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 22, color: AppTheme.accent),
                      tooltip: "Yeni Rekor Ekle",
                      onPressed: _showAddPRDialog,
                    ),
                  ],
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
                    const Text(
                      "Henüz kayıtlı bir rekor yok",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Canlı antrenman takibinden setlerinizi tamamladığınızda veya '+' butonuna basarak yeni rekor ekleyebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
          "Tahmini 1RM: ${pr.calculated1RM.toStringAsFixed(1)} kg • (${pr.reps} tekrar)",
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
