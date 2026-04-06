class Outfit {
  final String outfitId;
  final String clothingName;
  final String color;
  final String category;
  final DateTime dateAdded;
  final String? imagePath;

  Outfit({
    required this.outfitId,
    required this.clothingName,
    required this.color,
    required this.category,
    required this.dateAdded,
    this.imagePath,
  });

  Outfit copyWith({
    String? clothingName,
    String? color,
    String? category,
    String? imagePath,
  }) {
    return Outfit(
      outfitId: outfitId,
      clothingName: clothingName ?? this.clothingName,
      color: color ?? this.color,
      category: category ?? this.category,
      dateAdded: dateAdded,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
