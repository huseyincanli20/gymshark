import 'package:flutter/material.dart';
import '../models/fitness_models.dart';
import '../models/workout_manager.dart';
import '../models/user_profile.dart';
import '../services/exercise_repository.dart';
import '../theme/app_theme.dart';
import 'exercise_detail_screen.dart';
import 'exercise_edit_dialog.dart';
import 'exercise_web_sync_modal.dart';

class AllExercisesScreen extends StatefulWidget {
  const AllExercisesScreen({super.key});

  @override
  State<AllExercisesScreen> createState() => _AllExercisesScreenState();
}

class _AllExercisesScreenState extends State<AllExercisesScreen> {
  String _selectedCategory = "Tümü";
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  final ExerciseRepository _repo = ExerciseRepository.instance;

  final List<String> _categories = [
    "Tümü",
    "Göğüs",
    "Sırt",
    "Bacak",
    "Omuz",
    "Kollar",
    "Karın",
  ];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoUpdated);
  }

  void _onRepoUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoUpdated);
    _searchController.dispose();
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

  List<Exercise> get _filteredExercises {
    return _repo.exercises.where((ex) {
      final muscleName = _getMuscleGroupName(ex.muscleGroup).toLowerCase();
      final matchesCategory = _selectedCategory == "Tümü" ||
          muscleName.contains(_selectedCategory.toLowerCase()) ||
          ex.muscleGroup.name.toLowerCase().contains(_selectedCategory.toLowerCase());

      final matchesSearch = _searchQuery.isEmpty ||
          ex.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          muscleName.contains(_searchQuery.toLowerCase()) ||
          ex.instructions.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => const ExerciseEditDialog(),
    );
  }

  void _openWebSyncModal() {
    showDialog(
      context: context,
      builder: (context) => const ExerciseWebSyncModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises;
    final isAdmin = UserSession.current.isAdmin;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Egzersiz Rehberi & Formlar",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (isAdmin) ...[
            IconButton(
              tooltip: "İnternet Sitesinden Senkronize Et & JSON",
              icon: const Icon(Icons.cloud_sync_rounded, color: AppTheme.accent),
              onPressed: _openWebSyncModal,
            ),
            IconButton(
              tooltip: "Yeni Egzersiz / GIF Ekle",
              icon: const Icon(Icons.add_circle, color: AppTheme.primary),
              onPressed: _openAddExerciseDialog,
            ),
          ],
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Egzersiz veya kas grubu ara...",
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Kategori Filtre Butonları
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.cardColor,
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.08),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Sonuç Sayısı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "${exercises.length} egzersiz listeleniyor",
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Alt alta Egzersiz Listesi
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 56, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text(
                          "Egzersiz bulunamadı",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return _buildExerciseCard(context, ex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise ex) {
    final muscleName = _getMuscleGroupName(ex.muscleGroup);
    final isAdmin = UserSession.current.isAdmin;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final result = await Navigator.push<Exercise>(
              context,
              MaterialPageRoute(builder: (context) => ExerciseDetailScreen(exercise: ex)),
            );
            if (result != null && context.mounted) {
              WorkoutManager.instance.addExercise(result);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${result.name} antrenmana eklendi!"),
                  backgroundColor: AppTheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Resim
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.network(
                        ex.thumbnailUrl,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 90,
                          height: 90,
                          color: Colors.white10,
                          child: const Icon(Icons.fitness_center, color: Colors.white54, size: 32),
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.menu_book, color: AppTheme.primary, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              muscleName,
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Form Rehberi",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ex.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ex.instructions.isNotEmpty
                            ? ex.instructions
                            : "Doğru form ve ipuçları için tıklayın",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),
                if (isAdmin)
                  IconButton(
                    tooltip: "Düzenle & GIF Değiştir",
                    icon: const Icon(Icons.edit_note_rounded, color: AppTheme.primary, size: 22),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => ExerciseEditDialog(exercise: ex),
                      );
                    },
                  ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white30,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
