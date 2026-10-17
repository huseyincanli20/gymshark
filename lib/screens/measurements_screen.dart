import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Örnek Before/After görselleri (kullanıcı değiştirebilir)
  final String _beforePhotoUrl = 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=500&q=80';
  final String _afterPhotoUrl = 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&q=80';
  final String _beforeDate = '1 Ocak 2026';
  final String _afterDate = 'Bugün';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddMeasurementDialog() {
    final chestCtrl = TextEditingController();
    final armCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final hipsCtrl = TextEditingController();
    final thighCtrl = TextEditingController();
    final shouldersCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocale.get('add_measurement'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMeasureInput(chestCtrl, AppLocale.get('chest_cm')),
              _buildMeasureInput(armCtrl, AppLocale.get('arm_cm')),
              _buildMeasureInput(waistCtrl, AppLocale.get('waist_cm')),
              _buildMeasureInput(hipsCtrl, AppLocale.get('hips_cm')),
              _buildMeasureInput(thighCtrl, AppLocale.get('thigh_cm')),
              _buildMeasureInput(shouldersCtrl, AppLocale.get('shoulders_cm')),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: AppLocale.isEnglish ? 'Note' : 'Not (Opsiyonel)',
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocale.get('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
            onPressed: () {
              final newEntry = BodyMeasurement(
                id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                date: DateTime.now(),
                weightKg: UserSession.current.weightKg,
                chestCm: double.tryParse(chestCtrl.text) ?? 0.0,
                armCm: double.tryParse(armCtrl.text) ?? 0.0,
                waistCm: double.tryParse(waistCtrl.text) ?? 0.0,
                hipsCm: double.tryParse(hipsCtrl.text) ?? 0.0,
                thighCm: double.tryParse(thighCtrl.text) ?? 0.0,
                shouldersCm: double.tryParse(shouldersCtrl.text) ?? 0.0,
                note: noteCtrl.text.trim(),
              );

              UserSession.current.addBodyMeasurement(newEntry);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocale.isEnglish ? 'Measurement logged! 📏' : 'Ölçüm kaydedildi! 📏'),
                  backgroundColor: AppTheme.accent,
                ),
              );
            },
            child: Text(AppLocale.get('save'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureInput(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: "$label (cm)",
          suffixText: "cm",
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocale.isEnglish;
    final profile = UserSession.current;
    final measurements = profile.bodyMeasurements;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('measurements_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: AppLocale.get('measurements_title'), icon: const Icon(Icons.straighten, size: 20)),
            Tab(text: AppLocale.get('compare_photos_title'), icon: const Icon(Icons.compare, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: MEZURA ÖLÇÜMLERİ
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Son Ölçüm Kartı
                if (measurements.isNotEmpty) ...[
                  Text(
                    isEn ? 'Latest Measurements:' : 'Son Kayıtlı Ölçümler:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _buildCurrentMetricsGrid(measurements.first),
                  const SizedBox(height: 20),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Measurement History' : 'Ölçüm Geçmişi',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        AppLocale.get('add_measurement'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: _showAddMeasurementDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (measurements.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.straighten, size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(
                          isEn ? 'No measurements logged yet' : 'Henüz mezura ölçümü kaydedilmedi',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn
                              ? 'Tap "+ Add New Measurement" to track your biceps, chest, waist, and thighs progression.'
                              : 'Kol, göğüs, bel ve bacak gelişimini takip etmek için "+ Yeni Ölçüm Ekle" butonuna dokun.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                else
                  ...measurements.map((m) => _buildMeasurementTile(m, isEn)),
              ],
            ),
          ),

          // TAB 2: BEFORE & AFTER FOTOĞRAF KIYASLAMA
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? 'Visual Body Transformation' : 'Görsel Vücut Değişimi',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Compare your progress photos side by side to see muscular hypertrophy and fat loss.'
                      : 'Form fotoğraflarını yan yana kıyaslayarak kas gelişimini ve yağ kaybını net şekilde gör.',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),

                // Yan Yana Kıyaslama Kartı
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(_beforeDate, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_beforePhotoUrl, height: 260, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                                  child: const Text("ÖNCE / BEFORE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                Text(_afterDate, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(_afterPhotoUrl, height: 260, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Text("SONRA / AFTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.accent)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_down, color: AppTheme.accent, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            isEn ? 'Net Difference: -2.4 kg & Leaner Waist' : 'Net Değişim: -2.4 kg & Daha İnce Bel',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMetricsGrid(BodyMeasurement m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricChip(AppLocale.get('chest_cm'), "${m.chestCm} cm"),
              _buildMetricChip(AppLocale.get('arm_cm'), "${m.armCm} cm"),
              _buildMetricChip(AppLocale.get('waist_cm'), "${m.waistCm} cm"),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricChip(AppLocale.get('hips_cm'), "${m.hipsCm} cm"),
              _buildMetricChip(AppLocale.get('thigh_cm'), "${m.thighCm} cm"),
              _buildMetricChip(AppLocale.get('shoulders_cm'), "${m.shouldersCm} cm"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
      ],
    );
  }

  Widget _buildMeasurementTile(BodyMeasurement m, bool isEn) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          "${m.date.day}/${m.date.month}/${m.date.year}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Kol: ${m.armCm}cm • Bel: ${m.waistCm}cm • Göğüs: ${m.chestCm}cm",
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          onPressed: () {
            UserSession.current.deleteBodyMeasurement(m.id);
            setState(() {});
          },
        ),
      ),
    );
  }
}
