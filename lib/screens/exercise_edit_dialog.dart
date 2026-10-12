import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../theme/app_theme.dart';
import '../services/exercise_repository.dart';

class ExerciseEditDialog extends StatefulWidget {
  final Exercise? exercise; // Null ise yeni egzersiz ekleme modu

  const ExerciseEditDialog({super.key, this.exercise});

  @override
  State<ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<ExerciseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  late TextEditingController _videoUrlController;
  late TextEditingController _instructionsController;
  late TextEditingController _tipsController;
  MuscleGroup _selectedGroup = MuscleGroup.chest;

  // Popüler / Hazır Örnek Egzersiz GIF'leri (Kullanıcı tek tıkla seçebilsin veya kendi linkini yapıştırsın)
  final List<Map<String, String>> _sampleGifs = [
    {
      'name': 'Bench Press GIF',
      'url': 'https://media.giphy.com/media/d2Z8fX10rD15kFq0/giphy.gif',
    },
    {
      'name': 'Squat GIF',
      'url': 'https://media.giphy.com/media/26AHG5KGFxSkUWw1i/giphy.gif',
    },
    {
      'name': 'Deadlift GIF',
      'url': 'https://media.giphy.com/media/3o7TKMt1VVNkHV2PaE/giphy.gif',
    },
    {
      'name': 'Bicep Curl GIF',
      'url': 'https://media.giphy.com/media/3oriO13KWwDV4625Ow/giphy.gif',
    },
    {
      'name': 'Push Up / Şınav GIF',
      'url': 'https://media.giphy.com/media/3o7TKMGpx4Lkh0y0uY/giphy.gif',
    },
    {
      'name': 'Plank GIF',
      'url': 'https://media.giphy.com/media/3o7TKRBB3E7GE1388E/giphy.gif',
    },
  ];

  @override
  void initState() {
    super.initState();
    final ex = widget.exercise;
    _nameController = TextEditingController(text: ex?.name ?? '');
    _imageUrlController = TextEditingController(text: ex?.thumbnailUrl ?? '');
    _videoUrlController = TextEditingController(text: ex?.videoUrl ?? '');
    _instructionsController = TextEditingController(text: ex?.instructions ?? '');
    _tipsController = TextEditingController(text: ex?.tips ?? '');
    if (ex != null) {
      _selectedGroup = ex.muscleGroup;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _instructionsController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  String _getMuscleGroupName(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.chest:
        return "Göğüs";
      case MuscleGroup.back:
        return "Sırt";
      case MuscleGroup.legs:
        return "Bacak";
      case MuscleGroup.shoulders:
        return "Omuz";
      case MuscleGroup.arms:
        return "Kollar";
      case MuscleGroup.core:
        return "Karın";
      case MuscleGroup.cardio:
        return "Kardiyo";
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ExerciseRepository.instance;
    final id = widget.exercise?.id ?? 'ex_${DateTime.now().millisecondsSinceEpoch}';

    final updated = Exercise(
      id: id,
      name: _nameController.text.trim(),
      muscleGroup: _selectedGroup,
      videoUrl: _videoUrlController.text.trim().isNotEmpty
          ? _videoUrlController.text.trim()
          : _imageUrlController.text.trim(),
      thumbnailUrl: _imageUrlController.text.trim(),
      instructions: _instructionsController.text.trim(),
      tips: _tipsController.text.trim(),
    );

    if (widget.exercise == null) {
      await repo.addExercise(updated);
    } else {
      await repo.updateExercise(updated);
    }

    if (mounted) {
      Navigator.pop(context, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.exercise == null ? "Yeni egzersiz başarıyla eklendi! 🎉" : "Egzersiz ve hareket formu güncellendi! ✅"),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.exercise != null;

    return Dialog(
      backgroundColor: AppTheme.cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_note_rounded : Icons.add_circle_outline,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? "Egzersiz & Form Düzenle" : "Yeni Egzersiz & GIF Ekle",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Form İçeriği
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Egzersiz Adı
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Egzersiz Adı *",
                            hintText: "Örn: Incline Dumbbell Press",
                            prefixIcon: const Icon(Icons.fitness_center, color: AppTheme.primary),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? "Egzersiz adı zorunludur" : null,
                        ),
                        const SizedBox(height: 14),

                        // Kas Grubu Seçimi
                        DropdownButtonFormField<MuscleGroup>(
                          value: _selectedGroup,
                          dropdownColor: AppTheme.surfaceColor,
                          decoration: InputDecoration(
                            labelText: "Hedef Kas Grubu *",
                            prefixIcon: const Icon(Icons.accessibility_new, color: AppTheme.accent),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          items: MuscleGroup.values.map((group) {
                            return DropdownMenuItem(
                              value: group,
                              child: Text(_getMuscleGroupName(group)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedGroup = val);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Görsel / Hareketli .GIF URL
                        TextFormField(
                          controller: _imageUrlController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: "Hareketli .GIF / Görsel Linki (URL) *",
                            hintText: "https://.../exercise.gif veya .png/.jpg",
                            prefixIcon: const Icon(Icons.gif_box_outlined, color: AppTheme.accent),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            suffixIcon: _imageUrlController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => setState(() => _imageUrlController.clear()),
                                  )
                                : null,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? "Görsel veya .gif linki zorunludur" : null,
                        ),
                        const SizedBox(height: 8),

                        // Örnek GIF Seçici Butonları
                        const Text(
                          "Hızlı .GIF Örnekleri (Tıklayıp Kullanabilirsiniz):",
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: _sampleGifs.map((sample) {
                            return ActionChip(
                              backgroundColor: AppTheme.surfaceColor,
                              side: BorderSide(color: AppTheme.accent.withOpacity(0.3)),
                              avatar: const Icon(Icons.play_circle_fill, size: 16, color: AppTheme.accent),
                              label: Text(sample['name']!, style: const TextStyle(fontSize: 11, color: Colors.white)),
                              onPressed: () {
                                setState(() {
                                  _imageUrlController.text = sample['url']!;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        // GIF Önizleme
                        if (_imageUrlController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  _imageUrlController.text.trim(),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.redAccent, size: 36),
                                      SizedBox(height: 4),
                                      Text("Görsel yüklenemedi, URL'yi kontrol edin", style: TextStyle(color: Colors.white54, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text("ÖNİZLEME", style: TextStyle(color: AppTheme.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Form Uygulama Talimatı
                        TextFormField(
                          controller: _instructionsController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Doğru Hareket Formu ve Uygulanışı *",
                            hintText: "Örn: Dirseklerinizi 90 derece bükün, göğsünüzü gergin tutarak ağırlığı yukarı itin.",
                            prefixIcon: const Icon(Icons.format_list_numbered, color: AppTheme.primary),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? "Form talimatı zorunludur" : null,
                        ),
                        const SizedBox(height: 14),

                        // Antrenör Form İpuçları
                        TextFormField(
                          controller: _tipsController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: "Antrenör İpuçları & Kritik Hata Önleme",
                            hintText: "Örn: Beli sehpaya yapışık tutun, omuzları geriye kilitleyin.",
                            prefixIcon: const Icon(Icons.lightbulb_outline, color: AppTheme.accent),
                            filled: true,
                            fillColor: AppTheme.surfaceColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Butonlar
                Row(
                  children: [
                    if (isEdit)
                      IconButton(
                        tooltip: "Egzersizi Sil",
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppTheme.cardColor,
                              title: const Text("Egzersizi Sil"),
                              content: Text("${widget.exercise!.name} silinsin mi?"),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Vazgeç")),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text("Sil", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ExerciseRepository.instance.deleteExercise(widget.exercise!.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Egzersiz silindi")),
                              );
                            }
                          }
                        },
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("İptal"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(isEdit ? "Değişiklikleri Kaydet" : "Egzersizi Ekle", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: _save,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
