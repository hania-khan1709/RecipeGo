
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _recipesCollection = 'recipes';

  Stream<List<RecipeModel>> getAllRecipes() {
    return _firestore
        .collection(_recipesCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<RecipeModel>> getRecipesByCategory(String category) {
    return _firestore
        .collection(_recipesCollection)
        .snapshots()
        .map((snapshot) {
      List<RecipeModel> allRecipes = snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.data(), doc.id);
      }).toList();
      if (category == 'All') {
        return allRecipes;
      }
      return allRecipes.where((recipe) => 
        recipe.category.toLowerCase() == category.toLowerCase()
      ).toList();
    });
  }

  Future<RecipeModel?> getRecipeById(String recipeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_recipesCollection)
          .doc(recipeId)
          .get();
      if (doc.exists) {
        return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<RecipeModel>> getRecipes() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_recipesCollection).get();
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<String?> addRecipe(RecipeModel recipe) async {
    try {
      print(' RECIPE SERVICE: Starting addRecipe for ID: ${recipe.id}');
      print(' RECIPE SERVICE: Recipe title: ${recipe.title}');
      print(' RECIPE SERVICE: Recipe category: ${recipe.category}');
      print(' RECIPE SERVICE: Recipe authorId: ${recipe.authorId}');
      print(' RECIPE SERVICE: Recipe imageUrl: ${recipe.imageUrl}');
      

      Map<String, dynamic> recipeMap = recipe.toMap();
      print(' RECIPE SERVICE: Recipe converted to map successfully');
      print(' RECIPE SERVICE: Map keys: ${recipeMap.keys.join(", ")}');

      print('🔄 RECIPE SERVICE: Attempting to write to Firestore...');
      await _firestore
          .collection(_recipesCollection)
          .doc(recipe.id)
          .set(recipeMap)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print(' RECIPE SERVICE: Firestore write timed out');
              throw Exception('Firestore operation timed out');
            },
          );
      
      print(' RECIPE SERVICE: Recipe saved successfully to Firestore');

      print(' RECIPE SERVICE: Verifying recipe was saved...');
      DocumentSnapshot verification = await _firestore
          .collection(_recipesCollection)
          .doc(recipe.id)
          .get();
      
      if (verification.exists) {
        print(' RECIPE SERVICE: Verification successful - recipe exists in Firestore');
      } else {
        print(' RECIPE SERVICE: Verification failed - recipe not found in Firestore');
        return 'Recipe was not saved properly';
      }
      
      return null;
    } on FirebaseException catch (e) {
      print(' RECIPE SERVICE: Firebase error: ${e.code} - ${e.message}');
      return 'Firebase error: ${e.message}';
    } catch (e, stackTrace) {
      print('RECIPE SERVICE: Error saving recipe: $e');
      print(' RECIPE SERVICE: Stack trace: $stackTrace');
      return 'Failed to add recipe: $e';
    }
  }
  Future<String?> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection(_recipesCollection).doc(recipeId).delete();
      return null;
    } catch (e) {
      return 'Failed to delete recipe: $e';
    }
  }
  List<String> getCategories() {
    return [
      'All',
      'Breakfast',
      'Lunch',
      'Dinner',
      'Dessert',
      'Snacks',
      'Drinks',
    ];
  }

  Future<String?> addToFavorites(String userId, String recipeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId)
          .set({
        'recipeId': recipeId,
        'addedAt': DateTime.now().toIso8601String(),
      });
      return null;
    } catch (e) {
      return 'Failed to add to favorites: $e';
    }
  }
  Future<String?> removeFromFavorites(String userId, String recipeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId)
          .delete();
      return null;
    } catch (e) {
      return 'Failed to remove from favorites: $e';
    }
  }

  Future<bool> isFavorite(String userId, String recipeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<List<RecipeModel>> getFavoriteRecipes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((snapshot) async {
      List<String> recipeIds = snapshot.docs.map((doc) => doc.id).toList();
      
      if (recipeIds.isEmpty) {
        return [];
      }
      List<RecipeModel> recipes = [];
      for (String recipeId in recipeIds) {
        RecipeModel? recipe = await getRecipeById(recipeId);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }
      return recipes;
    });
  }

  Future<String?> addComment({
    required String recipeId,
    required String userId,
    required String username,
    required String text,
    required double rating,
  }) async {
    try {
      await _firestore
          .collection(_recipesCollection)
          .doc(recipeId)
          .collection('comments')
          .add({
        'recipeId': recipeId,
        'userId': userId,
        'username': username,
        'text': text,
        'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _updateRecipeRating(recipeId);
      return null;
    } catch (e) {
      return 'Failed to add comment: $e';
    }
  }

  Stream<List<Map<String, dynamic>>> getComments(String recipeId) {
    return _firestore
        .collection(_recipesCollection)
        .doc(recipeId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _updateRecipeRating(String recipeId) async {
    try {
      QuerySnapshot comments = await _firestore
          .collection(_recipesCollection)
          .doc(recipeId)
          .collection('comments')
          .get();

      if (comments.docs.isEmpty) {
        return;
      }
      double totalRating = 0;
      for (var doc in comments.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'] ?? 0.0;
      }
      double averageRating = totalRating / comments.docs.length;

      await _firestore
          .collection(_recipesCollection)
          .doc(recipeId)
          .update({'rating': averageRating});
    } catch (e) {
    }
  }
  Future<List<RecipeModel>> getRelatedRecipes(String recipeId, String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recipesCollection)
          .where('category', isEqualTo: category)
          .limit(4)
          .get();

      List<RecipeModel> recipes = [];
      for (var doc in snapshot.docs) {
        if (doc.id != recipeId) {
          recipes.add(RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id));
        }
      }
      return recipes;
    } catch (e) {
      return [];
    }
  }

  Future<List<RecipeModel>> searchRecipes({
    required String query,
    String? category,
    int? maxCookTime,
  }) async {
    try {
      Query queryRef = _firestore.collection(_recipesCollection);

      if (category != null && category != 'All') {
        queryRef = queryRef.where('category', isEqualTo: category);
      }
      
      QuerySnapshot snapshot = await queryRef.get();
      List<RecipeModel> allRecipes = snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (query.isEmpty && maxCookTime == null) {
        return allRecipes;
      }
      String lowercaseQuery = query.toLowerCase();

      return allRecipes.where((recipe) {
        bool matchesQuery = true;
        if (query.isNotEmpty) {
          bool titleMatch = recipe.title.toLowerCase().contains(lowercaseQuery);
          bool ingredientMatch = recipe.ingredients.any(
            (ing) => ing.toLowerCase().contains(lowercaseQuery),
          );
          matchesQuery = titleMatch || ingredientMatch;
        }
        bool matchesTime = true;
        if (maxCookTime != null) {
          matchesTime = recipe.cookTime <= maxCookTime;
        }

        return matchesQuery && matchesTime;
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

