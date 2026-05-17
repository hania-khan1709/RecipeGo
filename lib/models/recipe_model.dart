
class RecipeModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int cookTime;
  final int calories;
  final double rating;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final String authorId;
  final String authorName;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookTime,
    required this.calories,
    this.rating = 0.0,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'cookTime': cookTime,
      'calories': calories,
      'rating': rating,
      'category': category,
      'ingredients': ingredients,
      'steps': steps,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static RecipeModel fromMap(Map<String, dynamic> map, String docId) {
    return RecipeModel(
      id: docId,
      title: map['title'] ?? 'Untitled Recipe',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      cookTime: map['cookTime'] ?? 0,
      calories: map['calories'] ?? 0,
      rating: map['rating'] != null ? map['rating'].toDouble() : 0.0,
      category: map['category'] ?? 'Other',
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients']) : [],
      steps: map['steps'] != null ? List<String>.from(map['steps']) : [],
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
