import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';
import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/meal_plan_service.dart';
import '../services/recipe_service.dart';


class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}
class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealPlanService _mealPlanService = MealPlanService();
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String _selectedDay = 'Mon';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner'];
  List<MealPlanModel> _currentMealPlan = [];

  void _showRecipeSelector(String mealType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select for $mealType',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<RecipeModel>>(
                  future: _recipeService.getRecipes(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<RecipeModel> recipes = snapshot.data!;
                    if (recipes.isEmpty) {
                      return const Center(child: Text('No recipes found'));
                    }

                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        RecipeModel recipe = recipes[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: recipe.imageUrl.isNotEmpty
                                ? Image.network(
                                    recipe.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => _buildPlaceholder(),
                                  )
                                : _buildPlaceholder(),
                          ),
                          title: Text(recipe.title),
                          subtitle: Text('${recipe.cookTime} min • ${recipe.calories} kcal'),
                          onTap: () async {
                            String? userId = _authService.getCurrentUser()?.uid;
                            if (userId != null) {
                              await _mealPlanService.addToMealPlan(
                                userId: userId,
                                recipe: recipe,
                                dayOfWeek: _selectedDay,
                                mealType: mealType,
                                date: DateTime.now(),
                              );
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _removeMeal(String mealType) async {
    String? userId = _authService.getCurrentUser()?.uid;
    if (userId != null) {
      await _mealPlanService.removeFromMealPlan(userId, _selectedDay, mealType);
    }
  }
  @override
  Widget build(BuildContext context) {
    String? userId = _authService.getCurrentUser()?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to use Meal Planner')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Meal Planner'),
      ),
      body: StreamBuilder<List<MealPlanModel>>(
        stream: _mealPlanService.getUserMealPlan(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _currentMealPlan = snapshot.data!;
          }
          return Column(
            children: [
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _days[index] == _selectedDay;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_days[index]),
                        selected: isSelected,
                        selectedColor: const Color(0xFF66BB6A),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedDay = _days[index]);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _mealTypes.length,
                  itemBuilder: (context, index) {
                    String type = _mealTypes[index];

                    MealPlanModel? plannedMeal;
                    try {
                      plannedMeal = _currentMealPlan.firstWhere(
                        (m) => m.dayOfWeek == _selectedDay && m.mealType == type
                      );
                    } catch (e) {
                      plannedMeal = null;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  type == 'Breakfast' ? Icons.wb_sunny_outlined :
                                  type == 'Lunch' ? Icons.restaurant : Icons.nights_stay_outlined,
                                  color: const Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  type,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          plannedMeal != null
                              ? ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      plannedMeal.recipeImageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                  title: Text(plannedMeal.recipeTitle),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _removeMeal(type),
                                  ),
                                  onTap: () {
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _showRecipeSelector(type),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Meal'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF66BB6A),
                                        elevation: 0,
                                        side: const BorderSide(color: Color(0xFF66BB6A)),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildPlaceholder() => Container(
        width: 50,
        height: 50,
        color: const Color(0xFFC8E6C9),
        child: const Center(
          child: Icon(Icons.fastfood_rounded, color: Colors.green, size: 20),
        ),
      );
}
