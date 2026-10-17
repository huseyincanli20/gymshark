class AchievementBadge {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descTr;
  final String descEn;
  final String iconEmoji;
  final bool isUnlocked;
  final double progress; // 0.0 to 1.0
  final String progressText;
  final String category; // 'strength', 'streak', 'hydration', 'volume', 'nutrition'

  const AchievementBadge({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descTr,
    required this.descEn,
    required this.iconEmoji,
    required this.isUnlocked,
    required this.progress,
    required this.progressText,
    this.category = 'general',
  });

  String getTitle(bool isEnglish) => isEnglish ? titleEn : titleTr;
  String getDesc(bool isEnglish) => isEnglish ? descEn : descTr;
}
