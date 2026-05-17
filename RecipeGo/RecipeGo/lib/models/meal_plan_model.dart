
class MealPlanModel {
  final String id;
  final String userId;
  final String recipeId;
  final String recipeTitle;
  final String recipeImageUrl;
  final String dayOfWeek;
  final String mealType;
  final DateTime date;

  MealPlanModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImageUrl,
    required this.dayOfWeek,
    required this.mealType,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'recipeImageUrl': recipeImageUrl,
      'dayOfWeek': dayOfWeek,
      'mealType': mealType,
      'date': date.toIso8601String(),
    };
  }

  static MealPlanModel fromMap(Map<String, dynamic> map, String docId) {
    return MealPlanModel(
      id: docId,
      userId: map['userId'] ?? '',
      recipeId: map['recipeId'] ?? '',
      recipeTitle: map['recipeTitle'] ?? 'Unknown Recipe',
      recipeImageUrl: map['recipeImageUrl'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? 'Monday',
      mealType: map['mealType'] ?? 'Breakfast',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
