import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/body_measurement.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';
import '../utils/device_image_picker.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const String _prefBeforeKey = 'gymtrack_custom_before_photo';
  static const String _prefAfterKey = 'gymtrack_custom_after_photo';
  static const String _prefBeforeDateKey = 'gymtrack_custom_before_date';
  static const String _prefAfterDateKey = 'gymtrack_custom_after_date';

  // Varsayılan / Özel Before & After Görselleri
  final String _defaultBeforeUrl = 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=500&q=80';
  final String _defaultAfterUrl = 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?auto=format&fit=crop&w=500&q=80';

  String? _customBeforeBase64;
  String? _customAfterBase64;
  String _beforeDate = '1 Ocak 2026';
  String _afterDate = 'Bugün';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCustomBeforeAfterPhotos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomBeforeAfterPhotos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _customBeforeBase64 = prefs.getString(_prefBeforeKey);
        _customAfterBase64 = prefs.getString(_prefAfterKey);
        _beforeDate = prefs.getString(_prefBeforeDateKey) ?? _beforeDate;
        _afterDate = prefs.getString(_prefAfterDateKey) ?? _afterDate;
      });
    } catch (_) {}
  }

  Future<void> _saveCustomBeforePhoto(String base64, String dateStr) async {
    setState(() {
      _customBeforeBase64 = base64;
      _beforeDate = dateStr;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefBeforeKey, base64);
      await prefs.setString(_prefBeforeDateKey, dateStr);
    } catch (_) {}
  }

  Future<void> _saveCustomAfterPhoto(String base64, String dateStr) async {
    setState(() {
      _customAfterBase64 = base64;
      _afterDate = dateStr;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefAfterKey, base64);
      await prefs.setString(_prefAfterDateKey, dateStr);
    } catch (_) {}
  }

  ImageProvider? _getImageProvider(String? base64String) {
    if (base64String == null || base64String.trim().isEmpty) return null;
    try {
      final pure = base64String.contains(',') ? base64String.split(',').last : base64String;
      return MemoryImage(base64Decode(pure.trim()));
    } catch (_) {
      return null;
    }
  }

  void _showAddMeasurementDialog() {
    final chestCtrl = TextEditingController();
    final armCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final hipsCtrl = TextEditingController();
    final thighCtrl = TextEditingController();
    final shouldersCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String? selectedPhotoBase64;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.straighten_rounded, color: AppTheme.accent),
              const SizedBox(width: 8),
              Text(AppLocale.get('add_measurement'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 14),

                // Form Fotoğrafı Ekleme Alanı
                if (selectedPhotoBase64 != null) ...[
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accent, width: 2),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                              image: _getImageProvider(selectedPhotoBase64)!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.7),
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setModalState(() {
                                  selectedPhotoBase64 = null;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Form Fotoğrafı Seçildi",
                                  style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: const BorderSide(color: AppTheme.accent, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 20),
                    label: const Text(
                      "📸 Form / Vücut Fotoğrafı Ekle",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      pickDeviceImage((base64Result) {
                        if (base64Result.isNotEmpty) {
                          setModalState(() {
                            selectedPhotoBase64 = base64Result;
                          });
                        }
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(AppLocale.get('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                  photoBase64: selectedPhotoBase64,
                );

                UserSession.current.addBodyMeasurement(newEntry);
                Navigator.pop(dialogCtx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(selectedPhotoBase64 != null
                        ? (AppLocale.isEnglish ? 'Measurement & Photo logged! 📏📸' : 'Ölçüm ve form fotoğrafı kaydedildi! 📏📸')
                        : (AppLocale.isEnglish ? 'Measurement logged! 📏' : 'Ölçüm kaydedildi! 📏')),
                    backgroundColor: AppTheme.accent,
                  ),
                );
              },
              child: Text(AppLocale.get('save'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _attachPhotoToMeasurement(BodyMeasurement m, String base64Result) {
    final updated = BodyMeasurement(
      id: m.id,
      date: m.date,
      weightKg: m.weightKg,
      chestCm: m.chestCm,
      armCm: m.armCm,
      waistCm: m.waistCm,
      hipsCm: m.hipsCm,
      thighCm: m.thighCm,
      shouldersCm: m.shouldersCm,
      note: m.note,
      photoBase64: base64Result,
    );
    UserSession.current.updateBodyMeasurement(updated);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Form fotoğrafı ölçüme başarıyla eklendi! 📸"),
        backgroundColor: AppTheme.accent,
      ),
    );
  }

  void _showPhotoDialog(BodyMeasurement m) {
    final imgProvider = _getImageProvider(m.photoBase64);
    if (imgProvider == null) return;

    final dateStr = "${m.date.day}.${m.date.month}.${m.date.year}";

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image(
                  image: imgProvider,
                  fit: BoxFit.contain,
                  height: 380,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "📅 $dateStr",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (m.weightKg > 0)
                          Text(
                            "⚖️ ${m.weightKg} kg",
                            style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Kol: ${m.armCm}cm • Bel: ${m.waistCm}cm • Göğüs: ${m.chestCm}cm • Omuz: ${m.shouldersCm}cm",
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    if (m.note.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text("Not: ${m.note}", style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text("Önce Yap", style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              _saveCustomBeforePhoto(m.photoBase64!, dateStr);
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Bu fotoğraf 'Önce / Before' olarak ayarlandı!"), backgroundColor: AppTheme.accent),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.black),
                            label: const Text("Sonra Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            onPressed: () {
                              _saveCustomAfterPhoto(m.photoBase64!, dateStr);
                              Navigator.pop(dialogCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Bu fotoğraf 'Sonra / After' olarak ayarlandı!"), backgroundColor: AppTheme.accent),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final measurementsWithPhotos = measurements.where((m) => m.photoBase64 != null && m.photoBase64!.isNotEmpty).toList();

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
                            child: GestureDetector(
                              onTap: () {
                                pickDeviceImage((base64Result) {
                                  if (base64Result.isNotEmpty) {
                                    _saveCustomBeforePhoto(base64Result, 'Önceki Form');
                                  }
                                });
                              },
                              child: Column(
                                children: [
                                  Text(_beforeDate, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _customBeforeBase64 != null && _getImageProvider(_customBeforeBase64) != null
                                        ? Image(image: _getImageProvider(_customBeforeBase64)!, height: 260, fit: BoxFit.cover)
                                        : Image.network(_defaultBeforeUrl, height: 260, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app_rounded, size: 12, color: Colors.white70),
                                        SizedBox(width: 4),
                                        Text("ÖNCE (Değiştir)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                pickDeviceImage((base64Result) {
                                  if (base64Result.isNotEmpty) {
                                    _saveCustomAfterPhoto(base64Result, 'Son Form');
                                  }
                                });
                              },
                              child: Column(
                                children: [
                                  Text(_afterDate, style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _customAfterBase64 != null && _getImageProvider(_customAfterBase64) != null
                                        ? Image(image: _getImageProvider(_customAfterBase64)!, height: 260, fit: BoxFit.cover)
                                        : Image.network(_defaultAfterUrl, height: 260, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.touch_app_rounded, size: 12, color: AppTheme.accent),
                                        SizedBox(width: 4),
                                        Text("SONRA (Değiştir)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.accent)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.touch_app_outlined, color: AppTheme.accent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              isEn ? 'Tap photos to change with your own form photos' : 'Kendi fotoğraflarını yüklemek için görsellere dokun',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Kayıtlı Ölçüm Form Fotoğrafları Galerisi
                Text(
                  isEn ? 'Saved Progress Photos' : 'Kayıtlı Form Fotoğrafları',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  isEn
                      ? 'Tap any photo to view full details or set it as Before/After.'
                      : 'Herhangi bir fotoğrafa dokunarak detayları görebilir veya Önce/Sonra olarak seçebilirsin.',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),

                if (measurementsWithPhotos.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.white24),
                        SizedBox(height: 8),
                        Text(
                          "Henüz fotoğraflı mezura ölçümü eklenmedi",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "\"Ölçümler\" sekmesinden yeni ölçüm girerken 'Form Fotoğrafı Ekle' butonunu kullanabilirsiniz.",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: measurementsWithPhotos.length,
                      itemBuilder: (context, index) {
                        final m = measurementsWithPhotos[index];
                        final img = _getImageProvider(m.photoBase64);
                        final dateStr = "${m.date.day}.${m.date.month}.${m.date.year}";
                        return GestureDetector(
                          onTap: () => _showPhotoDialog(m),
                          child: Container(
                            width: 130,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: img != null
                                        ? Image(image: img, fit: BoxFit.cover)
                                        : Container(color: Colors.white10),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dateStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      Text(
                                        "Bel: ${m.waistCm}cm",
                                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 30),
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
    final imageProvider = _getImageProvider(m.photoBase64);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: imageProvider != null
            ? GestureDetector(
                onTap: () => _showPhotoDialog(m),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.accent, width: 1.5),
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.zoom_in, color: Colors.white, size: 12),
                    ),
                  ),
                ),
              )
            : Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined, size: 20, color: AppTheme.textSecondary),
                  tooltip: "Fotoğraf Ekle",
                  onPressed: () {
                    pickDeviceImage((base64Result) {
                      if (base64Result.isNotEmpty) {
                        _attachPhotoToMeasurement(m, base64Result);
                      }
                    });
                  },
                ),
              ),
        title: Row(
          children: [
            Text(
              "${m.date.day}.${m.date.month}.${m.date.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (m.photoBase64 != null && m.photoBase64!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text("📸 Fotoğraf Var", style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(
          "Kol: ${m.armCm}cm • Bel: ${m.waistCm}cm • Göğüs: ${m.chestCm}cm${m.shouldersCm > 0 ? ' • Omuz: ${m.shouldersCm}cm' : ''}",
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
