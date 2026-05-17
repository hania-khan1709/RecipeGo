
class CommentModel {
  final String id;
  final String recipeId;
  final String userId;
  final String username;
  final String text;
  final double rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.username,
    required this.text,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'userId': userId,
      'username': username,
      'text': text,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static CommentModel fromMap(Map<String, dynamic> map, String docId) {
    return CommentModel(
      id: docId,
      recipeId: map['recipeId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'Anonymous',
      text: map['text'] ?? '',
      rating: map['rating'] != null ? map['rating'].toDouble() : 0.0,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }
}
