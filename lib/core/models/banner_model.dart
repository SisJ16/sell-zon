class HomeBanner {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String targetType;
  final String targetValue;

  const HomeBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.targetType,
    required this.targetValue,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      subtitle: (json["subtitle"] ?? "").toString(),
      image: (json["image"] ?? "").toString(),
      targetType: (json["targetType"] ?? "").toString(),
      targetValue: (json["targetValue"] ?? "").toString(),
    );
  }
}
