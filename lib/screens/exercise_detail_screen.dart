import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'exercise_edit_dialog.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Exercise _currentExercise;

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercise;
  }

  void _openEditDialog() async {
    final updated = await showDialog<Exercise>(
      context: context,
      builder: (ctx) => ExerciseEditDialog(exercise: _currentExercise),
    );
    if (updated != null && mounted) {
      setState(() {
        _currentExercise = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _currentExercise;
    final isAdmin = UserSession.current.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: "Formu & .GIF'i Düzenle (Yönetici)",
              icon: const Icon(Icons.edit_note_rounded, color: AppTheme.accent),
              onPressed: _openEditDialog,
            ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Hareket formu kopyalandı! 📋")),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Egzersiz Hareket Görseli (Doğru Form & Pozisyon Rehberi)
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Hero(
                  tag: 'exercise_${exercise.id}',
                  child: Image.network(
                    exercise.thumbnailUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: AppTheme.cardColor,
                      child: const Icon(Icons.fitness_center, size: 60, color: AppTheme.primary),
                    ),
                  ),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fitness_center, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              exercise.muscleGroup.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.5)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: AppTheme.accent),
                            SizedBox(width: 4),
                            Text(
                              "Görsel Form Rehberi",
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hareket Formu Adımları Kartı (1. Hazırlık, 2. Uygulama, 3. Dönüş & Nefes)
                  const Text(
                    "Hareket Formu ve Uygulanışı",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _buildFormStep(
                    stepNumber: "1",
                    title: "Başlangıç & Duruş Pozisyonu",
                    description: "Vücudunuzu dik tutun, hedef kas grubuna odaklanarak doğru başlangıç açısını yakalayın ve omurganızı nötr pozisyonda sabitleyin.",
                    icon: Icons.accessibility_new,
                    iconColor: AppTheme.accent,
                  ),
                  const SizedBox(height: 10),

                  _buildFormStep(
                    stepNumber: "2",
                    title: "Konsantrik Aşama (Kaldırma / İtiş)",
                    description: exercise.instructions,
                    icon: Icons.fitness_center,
                    iconColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 10),

                  _buildFormStep(
                    stepNumber: "3",
                    title: "Eksantrik Aşama (İndirme) & Nefes",
                    description: "Ağırlığı 2-3 saniye kontrollü indirin (savurmayın). Güç uygularken nefes verin, ağırlığı indirirken derin nefes alın.",
                    icon: Icons.air,
                    iconColor: Colors.blueAccent,
                  ),

                  const SizedBox(height: 24),

                  // Antrenör Form İpuçları & Hata Önleme
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accent.withOpacity(0.35)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Kritik Antrenör İpucu",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                exercise.tips,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Antrenmana Ekle Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                      label: const Text(
                        "Bugünkü Antrenmana Ekle",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context, exercise);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormStep({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconColor.withOpacity(0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: iconColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
