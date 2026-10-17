import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../utils/app_locale.dart';
import 'workout_routines_screen.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _questionCtrl = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Başlangıç AI Koç selamlama mesajı
    final profile = UserSession.current;
    final isEn = AppLocale.isEnglish;
    _chatMessages.add({
      'sender': 'ai',
      'text': isEn
          ? "Hello ${profile.name}! I am your AI Coach. With a weight of ${profile.weightKg} kg and target of ${profile.targetWeightKg} kg, I'm here to optimize your training and nutrition. What would you like to achieve today?"
          : "Merhaba ${profile.name}! Ben senin GymTrack AI Kişisel Antrenörünüm. Mevcut ${profile.weightKg} kg ve hedef ${profile.targetWeightKg} kg bilgine göre antrenman ve beslenmeni en üst seviyeye çıkarmaya hazırım. Bugün neyi geliştirmek istersin?",
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  void _sendQuestion(String question) {
    if (question.trim().isEmpty) return;

    setState(() {
      _chatMessages.add({'sender': 'user', 'text': question.trim()});
      _questionCtrl.clear();
      _isGenerating = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final isEn = AppLocale.isEnglish;
      final answer = _generateAiAnswer(question, isEn);

      setState(() {
        _isGenerating = false;
        _chatMessages.add({'sender': 'ai', 'text': answer});
      });
    });
  }

  String _generateAiAnswer(String q, bool isEn) {
    final lower = q.toLowerCase();
    final profile = UserSession.current;

    if (lower.contains('kreatin') || lower.contains('creatine')) {
      return isEn
          ? "Creatine Monohydrate is one of the most researched supplements. Take 3-5 grams daily with water or carbs. Timing doesn't matter much; consistency is key to saturating muscle phosphocreatine stores."
          : "Kreatin Monohidrat spor biliminde en çok kanıtlanmış takviyedir. Günde 3-5 gram bol su ile alınması yeterlidir. Yükleme yapmana gerek yoktur; antrenman öncesi veya sonrası düzenli aldığında 2-3 hafta içinde güç ve toparlanma artışı başlar.";
    } else if (lower.contains('kardiyo') || lower.contains('cardio')) {
      return isEn
          ? "If your primary goal is hypertrophy/strength, perform cardio AFTER weight lifting or in a separate session. 20-25 minutes of steady-state zone 2 cardio 3 times a week will boost heart health without compromising muscle."
          : "Kas kütlesi ve kuvvet önceliğinse kardiyoyu ağırlık antrenmanından SONRA veya ayrı bir gün yapmalısın. Antrenman sonrası 20-25 dakika orta tempolu yürüyüş (incline walk) kas kaybı yaşamadan yağ yakımını hızlandırır.";
    } else if (lower.contains('plato') || lower.contains('plateau') || lower.contains('durdu')) {
      return isEn
          ? "Plateaus happen due to adaptive resistance. Try: 1) Deload for 1 week at 50% volume, 2) Change rep ranges (e.g. switch 8-10 reps to 5x5 or vice-versa), 3) Ensure 2.0g protein/kg and at least 7.5 hours of sleep."
          : "Platodan çıkmak için 'Progressive Overload' prensibini çeşitlendir: 1) Bir hafta deload (yarı ağırlık) yap, 2) Tekrar aralığını değiştir (örn: 8-10 tekrar yerine 5x5 güç protokolüne geç), 3) Günlük protein alımının kilo başına en az 2g olduğundan ve 7.5 saat kaliteli uykudan emin ol.";
    } else {
      return isEn
          ? "Based on your metrics (${profile.heightCm.toInt()} cm, ${profile.weightKg} kg, daily goal: ${profile.dailyCalorieGoal.toInt()} kcal), consistency in progressive overload and hitting your daily protein target (${profile.targetProteinGrams.toInt()}g) will produce optimal results within 4 to 6 weeks."
          : "Mevcut profil değerlerine göre (${profile.heightCm.toInt()} cm, ${profile.weightKg} kg, günlük hedef: ${profile.dailyCalorieGoal.toInt()} kcal), antrenmanlarında her hafta ağırlık veya tekrarı az da olsa artırman (Progressive Overload) ve günlük ${profile.targetProteinGrams.toInt()}g protein hedefini tutturman 4-6 hafta içinde çok net sonuç verecektir.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEn = AppLocale.isEnglish;
    final profile = UserSession.current;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.get('ai_coach_title')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: isEn ? 'Workout Plan' : 'Antrenman', icon: const Icon(Icons.fitness_center_rounded, size: 20)),
            Tab(text: isEn ? 'Meal Plan' : 'Beslenme', icon: const Icon(Icons.restaurant_menu_rounded, size: 20)),
            Tab(text: isEn ? 'Ask Coach' : 'Soru-Cevap', icon: const Icon(Icons.auto_awesome, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAiWorkoutPlanTab(profile, isEn),
          _buildAiMealPlanTab(profile, isEn),
          _buildAiChatTab(isEn),
        ],
      ),
    );
  }

  // --- TAB 1: AI ANTRENMAN PLANI ---
  Widget _buildAiWorkoutPlanTab(UserProfile profile, bool isEn) {
    final isFatLoss = profile.targetWeightKg < profile.weightKg;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analiz Kartı
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary.withOpacity(0.8), AppTheme.surfaceColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 40, color: Colors.amberAccent),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'AI Biometric Assessment' : 'AI Biyometrik Değerlendirme',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEn
                            ? "${profile.name} • ${profile.age} yrs • ${isFatLoss ? 'Fat Loss & Definition' : 'Lean Muscle Hypertrophy'}"
                            : "${profile.name} • ${profile.age} Yaş • ${isFatLoss ? 'Yağ Yakımı & Definisyon' : 'Kas Kazanımı & Hipertrofi'}",
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            isEn ? 'Recommended 4-Day Periodized Split:' : 'Tavsiye Edilen 4 Günlük Antrenman Programı:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          _buildDayScheduleItem(
            day: isEn ? 'Day 1: Upper Hypertrophy' : '1. Gün: Üst Gövde Hipertrofi',
            focus: isEn ? 'Bench Press, Overhead Press, Rows, Triceps' : 'Bench Press, Omuz Press, Barbell Row, Triceps',
            setsInfo: isEn ? '4 Exercises • 14 Sets • RPE 8' : '4 Egzersiz • 14 Set • RPE 8',
          ),
          _buildDayScheduleItem(
            day: isEn ? 'Day 2: Lower Power & Core' : '2. Gün: Alt Gövde Güç & Karın',
            focus: isEn ? 'Back Squats, Romanian Deadlifts, Calves, Plank' : 'Squat, RDL, Kalf Kaldırma, Plank',
            setsInfo: isEn ? '4 Exercises • 15 Sets • RPE 8.5' : '4 Egzersiz • 15 Set • RPE 8.5',
          ),
          _buildDayScheduleItem(
            day: isEn ? 'Day 3: Rest & Active Recovery' : '3. Gün: Dinlenme & Toparlanma',
            focus: isEn ? 'Light mobility, 8,000 steps, stretching' : 'Hafif esneme, 8.000 adım, su tüketimi',
            setsInfo: isEn ? 'Recovery Focus' : 'Toparlanma Odaklı',
            isRest: true,
          ),
          _buildDayScheduleItem(
            day: isEn ? 'Day 4: Push & Pull Synergy' : '4. Gün: İtiş & Çekiş Sinerjisi',
            focus: isEn ? 'Incline Press, Lat Pulldowns, Lateral Raises, Biceps' : 'Eğimli Göğüs, Lat Pulldown, Lateral Raise, Biceps',
            setsInfo: isEn ? '5 Exercises • 16 Sets • RPE 8' : '5 Egzersiz • 16 Set • RPE 8',
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.playlist_add_check, color: Colors.black),
              label: Text(
                isEn ? 'View & Start Routines' : 'Programları Gör & Başlat',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutRoutinesScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayScheduleItem({required String day, required String focus, required String setsInfo, bool isRest = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isRest ? Colors.white10 : AppTheme.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: isRest ? AppTheme.textSecondary : AppTheme.accent)),
              Text(setsInfo, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(focus, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  // --- TAB 2: AI BESLENME & MENÜ PLANI ---
  Widget _buildAiMealPlanTab(UserProfile profile, bool isEn) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Günlük Hedef Makro Şeridi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroSummary(isEn ? 'Calories' : 'Kalori', "${profile.dailyCalorieGoal.toInt()} kcal", AppTheme.primary),
                _buildMacroSummary('Protein', "${profile.targetProteinGrams.toInt()}g", AppTheme.proteinColor),
                _buildMacroSummary(isEn ? 'Carbs' : 'Karb', "${profile.targetCarbsGrams.toInt()}g", AppTheme.carbColor),
                _buildMacroSummary(isEn ? 'Fat' : 'Yağ', "${profile.targetFatGrams.toInt()}g", AppTheme.fatColor),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            isEn ? "Today's AI Custom Meal Plan:" : "Günün AI Kişiselleştirilmiş Menüsü:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          _buildMealCard(
            mealName: isEn ? 'Breakfast (Energetic Start)' : 'Kahvaltı (Enerjik Başlangıç)',
            items: isEn
                ? '3 Whole Eggs + 2 Egg Whites, 60g Rolled Oats with cinnamon and berries.'
                : '3 Tam Yumurta + 2 Beyaz, 60g Yulaf ezmesi, çilek veya yaban mersini.',
            macros: 'P: 35g • C: 45g • F: 18g | 480 kcal',
          ),
          _buildMealCard(
            mealName: isEn ? 'Lunch (High Protein Core)' : 'Öğle Yemeği (Yüksek Protein)',
            items: isEn
                ? '180g Grilled Chicken Breast, 150g Basmati Rice, olive oil green salad.'
                : '180g Izgara Tavuk Göğsü, 150g Basmati Pirinç pilavı, zeytinyağlı yeşil salata.',
            macros: 'P: 48g • C: 50g • F: 12g | 520 kcal',
          ),
          _buildMealCard(
            mealName: isEn ? 'Pre/Post Workout Snack' : 'Antrenman Öncesi / Sonrası Ara Öğün',
            items: isEn
                ? '1 Scoop Whey Protein, 1 Medium Banana, 20g raw almonds.'
                : '1 Ölçek Whey Protein, 1 Orta Boy Muz, 20g Çiğ Badem.',
            macros: 'P: 28g • C: 32g • F: 10g | 330 kcal',
          ),
          _buildMealCard(
            mealName: isEn ? 'Dinner (Clean Recovery)' : 'Akşam Yemeği (Hafif & Besleyici)',
            items: isEn
                ? '200g Lean Beef or Salmon, 200g Baked Sweet Potatoes, steamed broccoli.'
                : '200g Yağsız Dana Kıyma veya Somon, 200g Fırın Patates, buharda brokoli.',
            macros: 'P: 45g • C: 40g • F: 15g | 490 kcal',
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSummary(String title, String val, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMealCard({required String mealName, required String items, required String macros}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(items, style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(macros, style: const TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // --- TAB 3: AI DANIŞMAN & CHAT ---
  Widget _buildAiChatTab(bool isEn) {
    return Column(
      children: [
        // Hızlı Soru Butonları
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            children: [
              _buildQuickQuestionChip(isEn ? 'Creatine timing?' : 'Kreatin nasıl kullanılır?'),
              _buildQuickQuestionChip(isEn ? 'Cardio before or after?' : 'Kardiyo ağırlıktan önce mi sonra mı?'),
              _buildQuickQuestionChip(isEn ? 'Break muscle plateau?' : 'Platodan nasıl çıkarım?'),
            ],
          ),
        ),

        // Mesaj Listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              final isAi = msg['sender'] == 'ai';
              return Align(
                alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: isAi ? AppTheme.cardColor : AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                    border: isAi ? Border.all(color: Colors.white10) : null,
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: TextStyle(
                      color: isAi ? AppTheme.textPrimary : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (_isGenerating)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                const SizedBox(width: 8),
                Text(isEn ? 'AI is thinking...' : 'AI Koç yanıtlıyor...', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),

        // Mesaj Gönderme Kutusu
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surfaceColor,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionCtrl,
                  decoration: InputDecoration(
                    hintText: isEn ? 'Ask your AI coach anything...' : 'AI Antrenörüne bir soru sor...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: _sendQuestion,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send_rounded, color: AppTheme.accent),
                onPressed: () => _sendQuestion(_questionCtrl.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickQuestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11)),
        backgroundColor: AppTheme.surfaceColor,
        onPressed: () => _sendQuestion(text),
      ),
    );
  }
}
