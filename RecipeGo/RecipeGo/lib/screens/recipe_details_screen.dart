import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/auth_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});
  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  final RecipeService _recipeService = RecipeService();
  final AuthService _authService = AuthService();
  bool _isFavorite = false;
  bool _isLoadingFavorite = true;
  List<RecipeModel> _relatedRecipes = [];

  final _commentController = TextEditingController();
  double _userRating = 5.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    String? userId = _authService.getCurrentUser()?.uid;
    
    if (userId != null) {
      bool isFav = await _recipeService.isFavorite(userId, widget.recipe.id);
      setState(() {
        _isFavorite = isFav;
        _isLoadingFavorite = false;
      });
    } else {
      setState(() => _isLoadingFavorite = false);
    }

    List<RecipeModel> related = await _recipeService.getRelatedRecipes(
      widget.recipe.id,
      widget.recipe.category,
    );
    setState(() => _relatedRecipes = related);
  }

  Future<void> _toggleFavorite() async {
    String? userId = _authService.getCurrentUser()?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }

    setState(() => _isLoadingFavorite = true);
    String? error;
    if (_isFavorite) {
      error = await _recipeService.removeFromFavorites(userId, widget.recipe.id);
    } else {
      error = await _recipeService.addToFavorites(userId, widget.recipe.id);
    }

    if (error == null) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoadingFavorite = false;
      });
    } else {
      setState(() => _isLoadingFavorite = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _addComment() async {
    String? userId = _authService.getCurrentUser()?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add comments')),
      );
      return;
    }
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }
    var userData = await _authService.getUserData(userId);
    String username = userData?.username ?? 'User';
    String? error = await _recipeService.addComment(
      recipeId: widget.recipe.id,
      userId: userId,
      username: username,
      text: commentText,
      rating: _userRating,
    );
    if (error == null) {
      _commentController.clear();
      setState(() => _userRating = 5.0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: SizedBox(
                height: 160,
                child: widget.recipe.imageUrl.isNotEmpty 
                    ? Image.network(
                        widget.recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(height: 160),
                      )
                    : _buildPlaceholder(height: 160),
              ),
            ),
            actions: [
              _isLoadingFavorite
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.recipe.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                Icons.access_time,
                                '${widget.recipe.cookTime} min',
                              ),
                              _buildInfoChip(
                                Icons.local_fire_department,
                                '${widget.recipe.calories} kcal',
                                color: Colors.orange,
                              ),
                              _buildInfoChip(
                                Icons.star,
                                widget.recipe.rating.toStringAsFixed(1),
                                color: Colors.amber,
                              ),
                              _buildInfoChip(
                                Icons.category,
                                widget.recipe.category,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'By ${widget.recipe.authorName}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.recipe.ingredients.map((ingredient) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF66BB6A),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.recipe.steps.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF66BB6A),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.recipe.steps[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Comments & Ratings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add your review',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Rating: '),
                              ...List.generate(5, (index) {
                                return IconButton(
                                  icon: Icon(
                                    index < _userRating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                  ),
                                  onPressed: () {
                                    setState(() => _userRating = index + 1.0);
                                  },
                                );
                              }),
                            ],
                          ),
                          TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Write your comment...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _addComment,
                            child: const Text('Submit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _recipeService.getComments(widget.recipe.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No comments yet. Be the first to review!'),
                          ),
                        );
                      }

                      return Column(
                        children: snapshot.data!.map((comment) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment['username'] ?? 'User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < (comment['rating'] ?? 0)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment['text'] ?? ''),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(comment['createdAt']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_relatedRecipes.isNotEmpty) ...[
                    const Text(
                      'Related Recipes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _relatedRecipes.length,
                        itemBuilder: (context, index) {
                          RecipeModel recipe = _relatedRecipes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailsScreen(recipe: recipe),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 150,
                                height: 220,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: recipe.imageUrl.isNotEmpty
                                            ? Image.network(
                                                recipe.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(size: 30),
                                              )
                                            : _buildPlaceholder(size: 30),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF1F8E9),
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              recipe.title,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2E7D32),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, size: 10, color: Colors.amber),
                                                const SizedBox(width: 2),
                                                Text(
                                                  recipe.rating.toStringAsFixed(1),
                                                  style: const TextStyle(fontSize: 10),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${recipe.cookTime}m',
                                                  style: const TextStyle(fontSize: 10),
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
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration diff = now.difference(date);

      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
  Widget _buildPlaceholder({double? height, double size = 40}) {
    return Container(
      height: height,
      width: double.infinity,
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
