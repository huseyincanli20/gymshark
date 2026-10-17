import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';

class GymToolsScreen extends StatefulWidget {
  const GymToolsScreen({super.key});

  @override
  State<GymToolsScreen> createState() => _GymToolsScreenState();
}

class _GymToolsScreenState extends State<GymToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- 1. PLAKA HESAPLAYICI DURUMU ---
  double _targetTotalWeight = 100.0;
  double _barWeight = 20.0;

  // Standart Olimpik Plaka Çeşitleri ve Renkleri
  final List<Map<String, dynamic>> _availablePlates = [
    {'weight': 25.0, 'color': const Color(0xFFE53935), 'height': 80.0}, // Kırmızı
    {'weight': 20.0, 'color': const Color(0xFF1E88E5), 'height': 74.0}, // Mavi
    {'weight': 15.0, 'color': const Color(0xFFFDD835), 'height': 68.0}, // Sarı
    {'weight': 10.0, 'color': const Color(0xFF43A047), 'height': 60.0}, // Yeşil
    {'weight': 5.0, 'color': const Color(0xFFFFFFFF), 'height': 50.0},  // Beyaz
    {'weight': 2.5, 'color': const Color(0xFF424242), 'height': 42.0},  // Siyah
    {'weight': 1.25, 'color': const Color(0xFFB0BEC5), 'height': 34.0}, // Gümüş
  ];

  List<Map<String, dynamic>> _calculatePlatesPerSide() {
    double remainingPerSide = (_targetTotalWeight - _barWeight) / 2;
    if (remainingPerSide <= 0) return [];

    final List<Map<String, dynamic>> result = [];
    for (final plate in _availablePlates) {
      final double pWeight = plate['weight'] as double;
      while (remainingPerSide >= pWeight) {
        result.add(plate);
        remainingPerSide -= pWeight;
      }
    }
    return result;
  }

  // --- 2. 1RM HESAPLAYICI DURUMU ---
  double _calcWeight = 80.0;
  int _calcReps = 6;

  double get _oneRepMax {
    if (_calcReps <= 1) return _calcWeight;
    // Brzycki Formülü: weight * (36 / (37 - reps))
    if (_calcReps >= 37) return _calcWeight;
    return _calcWeight * (36 / (37 - _calcReps));
  }

  // --- 3. HIIT / TABATA ZAMANLAYICI DURUMU ---
  Timer? _timer;
  int _totalRounds = 8;
  int _currentRound = 1;
  int _workSeconds = 20;
  int _restSeconds = 10;
  final int _prepareSeconds = 5;

  String _currentPhase = 'IDLE'; // 'IDLE', 'PREPARE', 'WORK', 'REST', 'FINISHED'
  int _phaseSecondsLeft = 5;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;

    if (_currentPhase == 'IDLE' || _currentPhase == 'FINISHED') {
      _currentPhase = 'PREPARE';
      _phaseSecondsLeft = _prepareSeconds;
      _currentRound = 1;
    }

    setState(() {
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phaseSecondsLeft > 1) {
        setState(() {
          _phaseSecondsLeft--;
        });
      } else {
        _advancePhase();
      }
    });
  }

  void _advancePhase() {
    if (_currentPhase == 'PREPARE') {
      setState(() {
        _currentPhase = 'WORK';
        _phaseSecondsLeft = _workSeconds;
      });
    } else if (_currentPhase == 'WORK') {
      if (_currentRound >= _totalRounds) {
        setState(() {
          _currentPhase = 'FINISHED';
          _isTimerRunning = false;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _currentPhase = 'REST';
          _phaseSecondsLeft = _restSeconds;
        });
      }
    } else if (_currentPhase == 'REST') {
      setState(() {
        _currentRound++;
        _currentPhase = 'WORK';
        _phaseSecondsLeft = _workSeconds;
      });
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _currentPhase = 'IDLE';
      _phaseSecondsLeft = _prepareSeconds;
      _currentRound = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocale.isEnglish;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('gym_tools_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: AppLocale.get('plate_calc'), icon: const Icon(Icons.blur_circular, size: 20)),
            Tab(text: AppLocale.get('one_rm_calc'), icon: const Icon(Icons.calculate_outlined, size: 20)),
            Tab(text: AppLocale.get('hiit_timer'), icon: const Icon(Icons.timer_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlateCalculatorTab(isEn),
          _buildOneRmCalculatorTab(isEn),
          _buildHiitTimerTab(isEn),
        ],
      ),
    );
  }

  // ================= 1. TAB: PLAKA HESAPLAYICI =================
  Widget _buildPlateCalculatorTab(bool isEn) {
    final plates = _calculatePlatesPerSide();
    final weightPerSide = plates.fold(0.0, (sum, p) => sum + (p['weight'] as double));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barbell Görsel Alanı
          Container(
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bar Ucu
                Container(width: 25, height: 18, color: Colors.grey[700]),
                Container(width: 8, height: 40, color: Colors.grey[500]),
                // Plakalar
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: plates.map((p) {
                        return Container(
                          width: 14,
                          height: p['height'] as double,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: p['color'] as Color,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: Colors.black45),
                          ),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                "${p['weight']}",
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Bar Gövdesi
                Container(width: 60, height: 14, color: Colors.grey[400]),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sonuç Özeti Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(isEn ? 'Each Side' : 'Her Bir Yana', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("${weightPerSide.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                  ],
                ),
                Container(width: 1, height: 35, color: Colors.white12),
                Column(
                  children: [
                    Text(isEn ? 'Barbell' : 'Bar Ağırlığı', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("${_barWeight.toInt()} kg", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(width: 1, height: 35, color: Colors.white12),
                Column(
                  children: [
                    Text(isEn ? 'Total Weight' : 'Toplam Ağırlık', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text("${_targetTotalWeight.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Ağırlık Kaydırıcısı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isEn ? 'Target Weight:' : 'Hedef Toplam Ağırlık:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${_targetTotalWeight.toStringAsFixed(1)} kg", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Slider(
            value: _targetTotalWeight,
            min: 20.0,
            max: 250.0,
            divisions: 92,
            activeColor: AppTheme.accent,
            onChanged: (val) {
              setState(() {
                _targetTotalWeight = (val * 2).round() / 2; // 0.5 kg hassasiyet
              });
            },
          ),

          // Hızlı Seçim Butonları
          Wrap(
            spacing: 8,
            children: [40.0, 60.0, 80.0, 100.0, 120.0, 140.0].map((w) {
              return ActionChip(
                label: Text("${w.toInt()} kg"),
                backgroundColor: _targetTotalWeight == w ? AppTheme.accent : AppTheme.surfaceColor,
                labelStyle: TextStyle(
                  color: _targetTotalWeight == w ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onPressed: () => setState(() => _targetTotalWeight = w),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Bar Seçimi
          Text(isEn ? 'Select Barbell Weight:' : 'Bar Ağırlığını Seçin:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBarRadio(20.0, isEn ? '20 kg (Olympic)' : '20 kg (Olimpik)'),
              const SizedBox(width: 8),
              _buildBarRadio(15.0, isEn ? '15 kg (Women)' : '15 kg (Kadın)'),
              const SizedBox(width: 8),
              _buildBarRadio(10.0, isEn ? '10 kg (EZ Bar)' : '10 kg (EZ Bar)'),
            ],
          ),

          const SizedBox(height: 20),

          // Takılacak Plaka Listesi Dökümü
          Text(isEn ? 'Plates to Load on Each Side:' : 'Her Bir Yana Takılacak Plakalar:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (plates.isEmpty)
            Text(isEn ? 'Only empty bar' : 'Sadece boş bar', style: const TextStyle(color: AppTheme.textSecondary))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: plates.map((p) {
                return Chip(
                  avatar: CircleAvatar(backgroundColor: p['color'] as Color, radius: 8),
                  label: Text("${p['weight']} kg", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  backgroundColor: AppTheme.surfaceColor,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBarRadio(double weight, String label) {
    final isSelected = _barWeight == weight;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _barWeight = weight),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppTheme.primary : Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= 2. TAB: 1RM HESAPLAYICI =================
  Widget _buildOneRmCalculatorTab(bool isEn) {
    final oneRm = _oneRepMax;
    final percentages = [
      {'pct': 100, 'reps': 1},
      {'pct': 95, 'reps': 2},
      {'pct': 90, 'reps': 3},
      {'pct': 85, 'reps': 5},
      {'pct': 80, 'reps': 8},
      {'pct': 75, 'reps': 10},
      {'pct': 70, 'reps': 12},
      {'pct': 65, 'reps': 15},
      {'pct': 60, 'reps': 20},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1RM Başlık Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Estimated 1RM (Max Weight)' : 'Tahmini 1RM (Tek Tekrar Maksimum)',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${oneRm.toStringAsFixed(1)} kg",
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${_calcWeight.toInt()} kg x $_calcReps ${isEn ? 'reps' : 'tekrar baz alındı'}",
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const Icon(Icons.emoji_events, size: 54, color: Colors.amberAccent),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Ağırlık ve Tekrar Girişi
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEn ? 'Lifted Weight (kg):' : 'Kaldırılan Ağırlık (kg):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (_calcWeight > 5) setState(() => _calcWeight -= 2.5);
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text("${_calcWeight.toStringAsFixed(1)} kg", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _calcWeight += 2.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isEn ? 'Completed Reps:' : 'Tamamlanan Tekrar:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (_calcReps > 1) setState(() => _calcReps--);
                          },
                        ),
                        Expanded(
                          child: Center(
                            child: Text("$_calcReps", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _calcReps++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Yüzde Tablosu
          Text(isEn ? 'Training Intensity & Percentage Table:' : 'Antrenman Şiddeti & Yüzde Tablosu:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),

          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: AppTheme.surfaceColor),
                children: [
                  Padding(padding: const EdgeInsets.all(10), child: Text(isEn ? '% 1RM' : '% 1RM', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(10), child: Text(isEn ? 'Weight' : 'Ağırlık', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: const EdgeInsets.all(10), child: Text(isEn ? 'Est. Reps' : 'Tahmini Tekrar', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
              ...percentages.map((p) {
                final pctVal = p['pct'] as int;
                final weightAtPct = oneRm * (pctVal / 100);
                return TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(10), child: Text("%$pctVal", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent))),
                    Padding(padding: const EdgeInsets.all(10), child: Text("${weightAtPct.toStringAsFixed(1)} kg", style: const TextStyle(fontWeight: FontWeight.w600))),
                    Padding(padding: const EdgeInsets.all(10), child: Text("${p['reps']} ${isEn ? 'reps' : 'tekrar'}", style: const TextStyle(color: AppTheme.textSecondary))),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 3. TAB: HIIT / TABATA ZAMANLAYICI =================
  Widget _buildHiitTimerTab(bool isEn) {
    Color phaseColor;
    String phaseLabel;

    switch (_currentPhase) {
      case 'PREPARE':
        phaseColor = Colors.orangeAccent;
        phaseLabel = AppLocale.get('prepare');
        break;
      case 'WORK':
        phaseColor = AppTheme.accent;
        phaseLabel = AppLocale.get('work');
        break;
      case 'REST':
        phaseColor = Colors.redAccent;
        phaseLabel = AppLocale.get('rest');
        break;
      case 'FINISHED':
        phaseColor = Colors.amber;
        phaseLabel = isEn ? 'FINISHED!' : 'TEBRİKLER BİTTİ!';
        break;
      default:
        phaseColor = AppTheme.primary;
        phaseLabel = isEn ? 'READY' : 'HAZIR';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hazır Mod Butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimerPresetChip('Tabata 20/10', 20, 10, 8),
              _buildTimerPresetChip('HIIT 40/20', 40, 20, 8),
              _buildTimerPresetChip('EMOM 60s', 50, 10, 10),
            ],
          ),

          const SizedBox(height: 30),

          // Büyük Dairesel Kronometre
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardColor,
              border: Border.all(color: phaseColor, width: 8),
              boxShadow: [
                BoxShadow(
                  color: phaseColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  phaseLabel,
                  style: TextStyle(color: phaseColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  "$_phaseSecondsLeft",
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${AppLocale.get('round')}: $_currentRound / $_totalRounds",
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // Kontrol Butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                onPressed: _resetTimer,
              ),
              const SizedBox(width: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTimerRunning ? Colors.orangeAccent : phaseColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                ),
                onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                child: Icon(
                  _isTimerRunning ? Icons.pause : Icons.play_arrow,
                  size: 36,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Ayarlar Kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildTimerSettingRow(isEn ? 'Work Time (s)' : 'Çalışma Süresi (sn)', _workSeconds, (val) {
                  if (!_isTimerRunning) setState(() => _workSeconds = val);
                }),
                const Divider(color: Colors.white10),
                _buildTimerSettingRow(isEn ? 'Rest Time (s)' : 'Dinlenme Süresi (sn)', _restSeconds, (val) {
                  if (!_isTimerRunning) setState(() => _restSeconds = val);
                }),
                const Divider(color: Colors.white10),
                _buildTimerSettingRow(isEn ? 'Total Rounds' : 'Toplam Tur Sayısı', _totalRounds, (val) {
                  if (!_isTimerRunning) setState(() => _totalRounds = val);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerPresetChip(String label, int work, int rest, int rounds) {
    final isSelected = _workSeconds == work && _restSeconds == rest && _totalRounds == rounds;
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.accent : AppTheme.surfaceColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onPressed: () {
        if (!_isTimerRunning) {
          setState(() {
            _workSeconds = work;
            _restSeconds = rest;
            _totalRounds = rounds;
            _resetTimer();
          });
        }
      },
    );
  }

  Widget _buildTimerSettingRow(String title, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () {
                if (value > 5) onChanged(value - 5);
              },
            ),
            Text("$value", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () => onChanged(value + 5),
            ),
          ],
        )
      ],
    );
  }
}
