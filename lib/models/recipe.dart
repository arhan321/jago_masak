class Recipe {
  final int id;
  final String title;
  final String category;
  final DateTime createdAt;
  final String imageUrl;
  final String description;

  const Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    required this.imageUrl,
    required this.description,
  });

  Recipe copyWith({
    String? title,
    String? category,
    String? imageUrl,
    String? description,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      createdAt: createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }
}
