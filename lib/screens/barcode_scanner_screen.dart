import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/fitness_models.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../services/open_food_facts_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

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
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _fetchAndProcessBarcode(String code) async {
    if (!_isScanning) return;
    setState(() => _isScanning = false);

    // Yükleniyor bildirimi göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              const CircularProgressIndicator(color: AppTheme.accent),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  "İnternetten ürün araştırılıyor...\n($code)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 1. Önce Open Food Facts API üzerinden gerçek ürünü sorgula
    FoodItem? internetFood = await OpenFoodFactsService.fetchFoodByBarcode(code);

    if (mounted) {
      Navigator.pop(context); // Yükleniyor dialogunu kapat
    }

    if (internetFood != null) {
      _onBarcodeDetected(internetFood, code, isFromInternet: true);
      return;
    }

    // 2. İnternette bulunamazsa yerel hazır barkod veritabanını kontrol et
    final sampleMatch = _sampleBarcodes.firstWhere(
      (item) => item['code'] == code,
      orElse: () => {'food': null},
    );

    if (sampleMatch['food'] != null) {
      _onBarcodeDetected(sampleMatch['food'] as FoodItem, code);
      return;
    }

    // 3. Hiçbir yerde yoksa kullanıcıya özel manuel giriş oluştur
    final fallbackFood = FoodItem(
      id: 'barcode_$code',
      name: 'Taranan Ürün ($code)',
      calories: 160.0,
      protein: 8.0,
      carbs: 20.0,
      fat: 5.0,
      category: 'Barkod Ürünü',
    );
    _onBarcodeDetected(fallbackFood, code);
  }

  void _onBarcodeDetected(FoodItem food, String code, {bool isFromInternet = false}) {
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
                        Row(
                          children: [
                            const Text("Barkod Okundu! 🎉", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(width: 6),
                            if (isFromInternet)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.public, size: 10, color: Colors.blueAccent),
                                    SizedBox(width: 3),
                                    Text("Canlı Veri", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Besin Değerleri Detay Kartı
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("100g / 100ml Başına Kalori:", style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        Text(
                          "${food.calories.toStringAsFixed(0)} kcal",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionBadge("Protein", "${food.protein}g", AppTheme.proteinColor),
                        _buildNutritionBadge("Karbonhidrat", "${food.carbs}g", AppTheme.carbColor),
                        _buildNutritionBadge("Yağ", "${food.fat}g", AppTheme.fatColor),
                      ],
                    ),
                  ],
                ),
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

  Widget _buildNutritionBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  void _handleLiveBarcodeCapture(BarcodeCapture capture) {
    if (!_isScanning) return;
    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && code.trim().isNotEmpty) {
        _fetchAndProcessBarcode(code.trim());
      }
    }
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
              if (code.isNotEmpty) {
                _fetchAndProcessBarcode(code);
              }
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
              _cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => _cameraController.switchCamera(),
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
          // Gerçek Canlı Kamera Akışı (Telefonda ve webde kamerayı açar)
          MobileScanner(
            controller: _cameraController,
            onDetect: _handleLiveBarcodeCapture,
            errorBuilder: (context, error, child) {
              return Container(
                color: const Color(0xFF101418),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off_outlined, size: 70, color: Colors.white.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      const Text(
                        "Kamera başlatılamadı veya izin verilmedi.\nLütfen kamera iznini kontrol edin.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            },
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
                        "Barkodu veya QR kodu kameraya gösterin",
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Hızlı Barkod Test Butonları (Test amaçlı da kullanılabilir)
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
