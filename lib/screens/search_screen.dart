import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';

import 'recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RecipeService _recipeService = RecipeService();
  final TextEditingController _searchController = TextEditingController();
  List<RecipeModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  String? _selectedCategory;
  int? _maxCookTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    List<RecipeModel> results = await _recipeService.searchRecipes(
      query: _searchController.text.trim(),
      category: _selectedCategory,
      maxCookTime: _maxCookTime,
    );

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ..._recipeService.getCategories()
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (value) {
                      setStateModal(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Max Cook Time', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: (_maxCookTime ?? 120).toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: '${_maxCookTime ?? 120} min',
                    activeColor: const Color(0xFF66BB6A),
                    onChanged: (value) {
                      setStateModal(() => _maxCookTime = value.toInt());
                    },
                  ),
                  Center(child: Text('${_maxCookTime ?? 120} minutes or less')),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = null;
                              _maxCookTime = null;
                            });
                            Navigator.pop(context);
                            _performSearch();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = _selectedCategory;
                              _maxCookTime = _maxCookTime;
                            });
                            Navigator.pop(context);
                            _performSearch();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Search Recipes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search title or ingredients...',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: _showFilters,
                  style: IconButton.styleFrom(
                    backgroundColor: _selectedCategory != null || _maxCookTime != null
                        ? Colors.amber
                        : const Color(0xFF66BB6A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasSearched
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Find your next meal',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sentiment_dissatisfied, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No recipes found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _maxCookTime = null;
                                _searchController.clear();
                              });
                              _performSearch();
                            },
                            child: const Text('Clear all filters'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        RecipeModel recipe = _searchResults[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailsScreen(recipe: recipe),
                              ),
                            );
                          },
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
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: recipe.imageUrl.isNotEmpty
                                        ? Image.network(
                                            recipe.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                          )
                                        : _buildPlaceholder(),
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
                                        Text(
                                          recipe.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2E7D32),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        
                                        Text(
                                          recipe.description,
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
                                            Row(
                                              children: [
                                                Icon(Icons.timer_outlined, size: 14, color: Colors.grey[700]),
                                                const SizedBox(width: 4),
                                                Text('${recipe.cookTime}m', style: TextStyle(fontSize: 11, color: Colors.grey[800])),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.local_fire_department, size: 14, color: Colors.grey[700]),
                                                const SizedBox(width: 4),
                                                Text('${recipe.calories} kcal', style: TextStyle(fontSize: 11, color: Colors.grey[800])),
                                              ],
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
                      },
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
}
