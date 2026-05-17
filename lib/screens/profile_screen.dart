import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/recipe_service.dart';
import 'login_screen.dart';
import 'recipe_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final RecipeService _recipeService = RecipeService();
  
  late TabController _tabController;
  UserModel? _user;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUser();
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  Future<void> _loadUser() async {
    var user = _authService.getCurrentUser();
    if (user != null) {
      var userData = await _authService.getUserData(user.uid);
      setState(() {
        _user = userData;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFC8E6C9),
                  child: Text(
                    _user!.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _user!.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _user!.email,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2E7D32),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2E7D32),
              tabs: const [
                Tab(text: 'My Recipes'),
                Tab(text: 'Favorites'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipeList(
                  _recipeService.getAllRecipes().map((list) => 
                    list.where((r) => r.authorId == _user!.uid).toList()
                  )
                ),

                _buildRecipeList(
                  _recipeService.getFavoriteRecipes(_user!.uid)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRecipeList(Stream<List<RecipeModel>> stream) {
    return StreamBuilder<List<RecipeModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No recipes found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            RecipeModel recipe = snapshot.data![index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: recipe.imageUrl.isNotEmpty
                        ? Image.network(
                            recipe.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size: 24),
                          )
                        : _buildPlaceholder(size: 24),
                  ),
                ),
                title: Text(recipe.title),
                subtitle: Text('${recipe.cookTime} mins • ${recipe.calories} kcal • ${recipe.rating.toStringAsFixed(1)} ★'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailsScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder({double size = 40}) {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: const Color(0xFF2E7D32),
          size: size,
        ),
      ),
    );
  }
}
