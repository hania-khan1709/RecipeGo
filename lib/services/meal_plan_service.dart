import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';

class MealPlanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'mealPlans';

  Future<String?> addToMealPlan({
    required String userId,
    required RecipeModel recipe,
    required String dayOfWeek,
    required String mealType,
    required DateTime date,
  }) async {
    try {
      String docId = '${userId}_${dayOfWeek}_$mealType';

      await _firestore.collection(_collection).doc(docId).set({
        'userId': userId,
        'recipeId': recipe.id,
        'recipeTitle': recipe.title,
        'recipeImageUrl': recipe.imageUrl,
        'dayOfWeek': dayOfWeek,
        'mealType': mealType,
        'date': date.toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Failed to add meal: $e';
    }
  }

  Future<String?> removeFromMealPlan(String userId, String dayOfWeek, String mealType) async {
    try {
      String docId = '${userId}_${dayOfWeek}_$mealType';
      await _firestore.collection(_collection).doc(docId).delete();
      return null;
    } catch (e) {
      return 'Failed to remove meal: $e';
    }
  }
  Stream<List<MealPlanModel>> getUserMealPlan(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MealPlanModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
