import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isTorchOn = false;
  bool _isScanning = true;

  // Örnek taranabilir ürünler
  final List<Map<String, dynamic>> _sampleBarcodes = [
    {
      'code': '8690504123456',
      'name': 'Pınar Protein Süt (Vanilyalı)',
      'food': FoodItem(
        id: 'scan_1',
        name: 'Pınar Protein Süt',
        calories: 61,
        protein: 5.2,
        carbs: 4.8,
        fat: 1.5,
        category: 'İçecek',
      ),
    },
    {
      'code': '8690637890123',
      'name': 'Eti Lifalif Yulaf Ezmesi',
      'food': MockData.foods[1], // Yulaf
    },
    {
      'code': '8690123456789',
      'name': 'Fellas Yüksek Protein Bar',
      'food': FoodItem(
        id: 'scan_2',
        name: 'Fellas Protein Bar',
        calories: 360,
        protein: 30.0,
        carbs: 35.0,
        fat: 11.0,
        category: 'Atıştırmalık',
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(FoodItem food, String code) {
    if (!_isScanning) return;
    setState(() => _isScanning = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppTheme.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Barkod Başarıyla Okundu! 🎉", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Barkod Kodu: $code\nBesin Değerleri (100g/ml için): ${food.calories.toStringAsFixed(0)} kcal • P: ${food.protein}g • K: ${food.carbs}g • Y: ${food.fat}g",
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Öğüne Ekle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () {
                    Navigator.pop(context); // Modal kapat
                    Navigator.pop(context, food); // Barkod ekranından besini döndür
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) setState(() => _isScanning = true);
    });
  }

  void _manualCodeEntry() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Barkod Numarası Gir"),
        content: TextField(
          controller: codeCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Örn: 8690504123456",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              final code = codeCtrl.text.trim();
              Navigator.pop(context);
              final match = _sampleBarcodes.firstWhere(
                (item) => item['code'] == code,
                orElse: () => {
                  'code': code,
                  'name': 'Bilinmeyen Besin ($code)',
                  'food': FoodItem(
                    id: 'custom_scan_${DateTime.now().millisecondsSinceEpoch}',
                    name: 'Taranan Ürün ($code)',
                    calories: 180,
                    protein: 8.0,
                    carbs: 22.0,
                    fat: 4.0,
                    category: 'Barkod Ürünü',
                  )
                },
              );
              _onBarcodeDetected(match['food'] as FoodItem, code);
            },
            child: const Text("Sorgula", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Barkod & QR Okuyucu", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: _isTorchOn ? AppTheme.accent : Colors.white),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isTorchOn ? "Flaş açıldı 🔦" : "Flaş kapatıldı"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.keyboard, color: Colors.white),
            tooltip: "Elle Barkod Gir",
            onPressed: _manualCodeEntry,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Kamera Simülasyonu & Grid Arka Planı
          Container(
            color: const Color(0xFF101418),
            child: Center(
              child: Opacity(
                opacity: 0.25,
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 260,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ),

          // Karartılmış Kamera Vizörü (Overlay)
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 2.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // 4 Köşe Vurguları
                  _buildCorner(top: 0, left: 0),
                  _buildCorner(top: 0, right: 0),
                  _buildCorner(bottom: 0, left: 0),
                  _buildCorner(bottom: 0, right: 0),

                  // Lazer Tarama Çizgisi
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * 250,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Alt Bilgi & Hızlı Simülasyon Butonları
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.accent, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Barkodu veya QR kodu çerçevenin içine hizalayın",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Hızlı Barkod Test Butonları
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _sampleBarcodes.map((item) {
                    return ActionChip(
                      backgroundColor: AppTheme.cardColor,
                      avatar: const Icon(Icons.qr_code, size: 16, color: AppTheme.primary),
                      label: Text(
                        item['name'] as String,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      onPressed: () {
                        _onBarcodeDetected(item['food'] as FoodItem, item['code'] as String);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? const BorderSide(color: AppTheme.accent, width: 4) : BorderSide.none,
            bottom: bottom != null ? const BorderSide(color: AppTheme.accent, width: 4) : BorderSide.none,
            left: left != null ? const BorderSide(color: AppTheme.accent, width: 4) : BorderSide.none,
            right: right != null ? const BorderSide(color: AppTheme.accent, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
