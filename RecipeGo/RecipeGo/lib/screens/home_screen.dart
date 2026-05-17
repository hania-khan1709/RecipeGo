import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import 'recipe_details_screen.dart';
import 'create_recipe_screen.dart';
import 'search_screen.dart';
import 'meal_planner_screen.dart';
import 'profile_screen.dart';
import '../services/sample_data_helper.dart';
import '../services/spoonacular_service.dart';
import '../models/api_recipe_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  
  UserModel? _currentUser;
  bool _isLoadingUser = true;
  String _selectedCategory = 'All';
  List<ApiRecipeModel> _apiSuggestions = [];
  bool _isLoadingApiSuggestions = true;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchApiSuggestions();
  }

  Future<void> _loadUserData() async {
    if (_authService.getCurrentUser() != null) {
      UserModel? user = await _authService.getUserData(_authService.getCurrentUser()!.uid);
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _fetchApiSuggestions() async {
    setState(() {
      _isLoadingApiSuggestions = true;
      _apiError = null;
    });

    try {
      final suggestions = await SpoonacularService.fetchRandomRecipes(number: 6);
      setState(() {
        _apiSuggestions = suggestions;
        _isLoadingApiSuggestions = false;
      });
    } catch (e) {
      setState(() {
        _apiError = 'Failed to load suggestions';
        _isLoadingApiSuggestions = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBE7),
      appBar: AppBar(
        title: const Text('RecipeGO', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 26)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Icon(Icons.restaurant_menu, color: Colors.white, size: 54),
                   SizedBox(height: 12),
                   Text(
                    'RecipeGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home, color: Color(0xFF2E7D32)), title: const Text('Home'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)), title: const Text('Meal Planner'), onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MealPlannerScreen()));
            }),
            ListTile(leading: const Icon(Icons.person, color: Color(0xFF2E7D32)), title: const Text('Profile'), onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cloud_upload, color: Colors.orange), 
              title: const Text('Load Sample Data'), 
              subtitle: const Text('Tap once to fill recipe list'),
              onTap: () async {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adding sample recipes...')));
                  await SampleDataHelper.addSampleRecipes();
                  if (!mounted) return;
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Done! Pull to refresh or restart app.'))
                    );
                  }
            }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.redAccent), title: const Text('Logout', style: TextStyle(color: Colors.redAccent)), onTap: () {
                 Navigator.pop(context);
                 _logout();
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_currentUser?.username ?? 'Chef'}! 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'What are we cooking today?',
                  style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          Container(
            height: 70,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recipeService.getCategories().length,
              itemBuilder: (context, index) {
                String category = _recipeService.getCategories()[index];
                bool isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(category, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
                    selected: isSelected,
                    onSelected: (selected) => setState(() => _selectedCategory = category),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF81C784),
                    checkmarkColor: Colors.white,
                    elevation: 2,
                    pressElevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? const Color(0xFF388E3C) : Colors.transparent),
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF558B2F),
                    ),
                  ),
                );
              },
            ),
          ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  StreamBuilder<List<RecipeModel>>(
                    stream: _recipeService.getRecipesByCategory(_selectedCategory),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return SliverFillRemaining(
                          child: Center(child: Text('Error: ${snapshot.error}')),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text('No recipes found', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
                                const SizedBox(height: 8),
                                const Text('Try exploring another category', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }

                      List<RecipeModel> recipes = snapshot.data!;
                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => RecipeCard(recipe: recipes[index]),
                            childCount: recipes.length,
                          ),
                        ),
                      );
                    },
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFF81C784), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Suggested Recipes from the Internet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌐', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 220,
                      child: _isLoadingApiSuggestions
                          ? const Center(child: CircularProgressIndicator())
                          : _apiError != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(_apiError!, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _apiSuggestions.length,
                                  itemBuilder: (context, index) {
                                    return ApiRecipeCard(recipe: _apiSuggestions[index]);
                                  },
                                ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 80),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateRecipeScreen())),
        backgroundColor: const Color(0xFFFF7043),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Cook!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 4,
      ),
    );
  }
}

class RecipeCard extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeCard({super.key, required this.recipe});
  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  String? _userId;
  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      _userId = user.uid;
      bool isFav = await _recipeService.isFavorite(user.uid, widget.recipe.id);
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      await _recipeService.addToFavorites(_userId!, widget.recipe.id);
    } else {
      await _recipeService.removeFromFavorites(_userId!, widget.recipe.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RecipeDetailsScreen(recipe: widget.recipe)),
      ),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [

            Expanded(
              flex: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'recipe_${widget.recipe.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: widget.recipe.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.recipe.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F8E9),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.recipe.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleFavorite,
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.green : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      widget.recipe.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniBadge(Icons.timer_outlined, '${widget.recipe.cookTime}m'),
                        _buildMiniBadge(Icons.local_fire_department, '${widget.recipe.calories} kcal'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: const Center(
        child: Icon(
          Icons.restaurant,
          color: Color(0xFF2E7D32),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800])),
      ],
    );
  }
}

class ApiRecipeCard extends StatelessWidget {
  final ApiRecipeModel recipe;
  const ApiRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF81C784),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'API',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Text('🤖', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Color(0xFF2E7D32),
                              size: 60,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Color(0xFF81C784)),
                    const SizedBox(width: 8),
                    Text(
                      'Ready in ${recipe.readyInMinutes} minutes',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'This recipe is from Spoonacular API. Full details are available on their website.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: recipe.image.isNotEmpty
                      ? Image.network(
                          recipe.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              color: const Color(0xFFE8F5E9),
                              child: const Center(
                                child: Icon(
                                  Icons.restaurant,
                                  color: Color(0xFF2E7D32),
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 120,
                          color: const Color(0xFFE8F5E9),
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: Color(0xFF2E7D32),
                              size: 40,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'API',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text('🤖', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.readyInMinutes} min',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
