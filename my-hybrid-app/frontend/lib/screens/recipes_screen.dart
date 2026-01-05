import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_theme.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  final List<String>? initialIngredients;

  const RecipesScreen({super.key, this.initialIngredients});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  // Recipe data
  List<Recipe> _aiRecipes = [];
  List<Recipe> _localRecipes = [];
  List<Recipe> _filteredRecipes = [];

  // UI state
  bool _isLoading = false;
  bool _showFilters = false;
  bool _useAiSearch = false;
  String? _errorMessage;
  String _selectedCategory = 'All';

  // Ingredient input
  final List<String> _userIngredients = [];
  final TextEditingController _ingredientController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Filter options
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isHalal = false;
  int? _maxCookingTime;
  int _maxMissingIngredients = 5;

  @override
  void initState() {
    super.initState();
    _loadLocalRecipes();

    // If initial ingredients were passed, use them
    if (widget.initialIngredients != null &&
        widget.initialIngredients!.isNotEmpty) {
      _userIngredients.addAll(widget.initialIngredients!);
      _useAiSearch = true;
      // Auto-search with initial ingredients
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchRecipesWithAI();
      });
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _loadLocalRecipes() {
    setState(() {
      _localRecipes = RecipeDatabase.getAllRecipes();
      _filterLocalRecipes();
    });
  }

  void _filterLocalRecipes() {
    setState(() {
      if (_userIngredients.isNotEmpty && !_useAiSearch) {
        _filteredRecipes = RecipeDatabase.searchRecipesByIngredients(
          _userIngredients,
        );
        if (_selectedCategory != 'All') {
          _filteredRecipes = _filteredRecipes
              .where((recipe) => recipe.category == _selectedCategory)
              .toList();
        }
      } else if (!_useAiSearch) {
        _filteredRecipes = _selectedCategory == 'All'
            ? _localRecipes
            : RecipeDatabase.getRecipesByCategory(_selectedCategory);
      }
    });
  }

  Future<void> _searchRecipesWithAI() async {
    if (_userIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _useAiSearch = true;
    });

    try {
      final result = await ApiService.recommendRecipes(
        ingredients: _userIngredients,
        maxMinutes: _maxCookingTime,
        vegetarian: _isVegetarian,
        vegan: _isVegan,
        halal: _isHalal,
        maxMissingIngredients: _maxMissingIngredients,
        topK: 15,
      );

      if (result['success'] == true && result['data'] != null) {
        final recipesData = result['data']['recipes'] as List<dynamic>?;

        if (recipesData != null) {
          setState(() {
            _aiRecipes = recipesData
                .map(
                  (json) =>
                      Recipe.fromApiResponse(json as Map<String, dynamic>),
                )
                .toList();
            _filteredRecipes = _aiRecipes;
          });
        } else {
          setState(() {
            _aiRecipes = [];
            _filteredRecipes = [];
          });
        }
      } else {
        throw Exception(result['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _detectIngredientsFromImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Scan ingredients with camera'),
              onTap: () async {
                Navigator.pop(context);
                await _processImageForIngredients(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.primaryGreen,
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select an existing photo'),
              onTap: () async {
                Navigator.pop(context);
                await _processImageForIngredients(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processImageForIngredients(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await ApiService.detectIngredients(File(image.path));

      if (result['success'] == true && result['data'] != null) {
        final ingredients = result['data']['ingredients'] as List<dynamic>?;

        if (ingredients != null && ingredients.isNotEmpty) {
          setState(() {
            for (var ingredient in ingredients) {
              final ingredientStr = ingredient.toString().toLowerCase().trim();
              if (!_userIngredients.contains(ingredientStr)) {
                _userIngredients.add(ingredientStr);
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detected ${ingredients.length} ingredients!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No ingredients detected. Try another image.'),
              backgroundColor: AppTheme.accentOrange,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: AppTheme.warningRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _userIngredients.clear();
      _aiRecipes.clear();
      _useAiSearch = false;
      _errorMessage = null;
      _filterLocalRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          if (_userIngredients.isNotEmpty || _useAiSearch)
            _buildIngredientSection(),
          if (_showFilters) _buildFilterSection(),
          if (!_useAiSearch) _buildCategoryChips(),
          const SizedBox(height: 8),
          _buildResultsHeader(),
          const SizedBox(height: 8),
          Expanded(child: _buildRecipeList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recipe Discovery',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: AppTheme.primaryGreen,
                    ),
                    tooltip: 'Filters',
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _useAiSearch ? Icons.restaurant : Icons.auto_awesome,
                      color: AppTheme.primaryGreen,
                    ),
                    tooltip: _useAiSearch ? 'Show local recipes' : 'AI Search',
                    onPressed: () {
                      if (_useAiSearch) {
                        _clearSearch();
                      } else {
                        setState(() {
                          _useAiSearch = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _useAiSearch
                ? 'Find recipes based on your ingredients'
                : 'Browse local recipe collection',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),

          // Ingredient input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: InputDecoration(
                    hintText: 'Add ingredient (e.g., chicken)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: AppTheme.primaryGreen,
                      ),
                      tooltip: 'Scan ingredients',
                      onPressed: _detectIngredientsFromImage,
                    ),
                  ),
                  onSubmitted: _addIngredient,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _addIngredient(_ingredientController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _userIngredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                onDeleted: () => _removeIngredient(ingredient),
                deleteIcon: const Icon(Icons.close, size: 16),
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
                deleteIconColor: AppTheme.primaryGreen,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _searchRecipesWithAI,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                  label: Text(
                    _isLoading ? 'Searching...' : 'Find AI Recipes',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: _clearSearch, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('🥬 Vegetarian'),
                selected: _isVegetarian,
                onSelected: (selected) {
                  setState(() {
                    _isVegetarian = selected;
                    if (selected) _isVegan = false;
                  });
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
              FilterChip(
                label: const Text('🌱 Vegan'),
                selected: _isVegan,
                onSelected: (selected) {
                  setState(() {
                    _isVegan = selected;
                    if (selected) _isVegetarian = false;
                  });
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
              FilterChip(
                label: const Text('☪️ Halal'),
                selected: _isHalal,
                onSelected: (selected) {
                  setState(() {
                    _isHalal = selected;
                  });
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Max Cooking Time',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Any'),
                selected: _maxCookingTime == null,
                onSelected: (selected) {
                  if (selected) setState(() => _maxCookingTime = null);
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text('≤15 min'),
                selected: _maxCookingTime == 15,
                onSelected: (selected) {
                  setState(() => _maxCookingTime = selected ? 15 : null);
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text('≤30 min'),
                selected: _maxCookingTime == 30,
                onSelected: (selected) {
                  setState(() => _maxCookingTime = selected ? 30 : null);
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
              ChoiceChip(
                label: const Text('≤60 min'),
                selected: _maxCookingTime == 60,
                onSelected: (selected) {
                  setState(() => _maxCookingTime = selected ? 60 : null);
                },
                selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                'Max Missing Ingredients: $_maxMissingIngredients',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '$_maxMissingIngredients',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxMissingIngredients.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: AppTheme.primaryGreen,
            onChanged: (value) {
              setState(() {
                _maxMissingIngredients = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: RecipeDatabase.getAllCategories().length,
        itemBuilder: (context, index) {
          final category = RecipeDatabase.getAllCategories()[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _filterLocalRecipes();
                });
              },
              selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryGreen,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_useAiSearch && _aiRecipes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'AI Powered',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          Text(
            '${_filteredRecipes.length} recipes found',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            SizedBox(height: 16),
            Text('Finding the best recipes for you...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.warningRed.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _searchRecipesWithAI,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRecipes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = _filteredRecipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            _useAiSearch
                ? 'Try adding different ingredients or adjust filters'
                : 'Try selecting a different category',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (_useAiSearch && _userIngredients.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _detectIngredientsFromImage,
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text(
                'Scan Ingredients',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    final bool isAiRecipe = _useAiSearch && recipe.category == 'AI Recommended';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recipe image or placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recipe.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppTheme.cardBackground,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Recipe details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    if (isAiRecipe)
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI Recommended',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      )
                    else
                      Text(
                        recipe.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookTimeMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          _getDifficultyIcon(recipe.difficulty),
                          size: 16,
                          color: _getDifficultyColor(recipe.difficulty),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _getDifficultyColor(recipe.difficulty),
                              ),
                        ),
                      ],
                    ),

                    // Match percentage for AI recipes
                    if (isAiRecipe && recipe.matchPercentage > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: recipe.matchPercentage / 100,
                                backgroundColor: AppTheme.textSecondary
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  recipe.matchPercentage >= 70
                                      ? AppTheme.successGreen
                                      : recipe.matchPercentage >= 40
                                      ? AppTheme.accentOrange
                                      : AppTheme.warningRed,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${recipe.matchPercentage}% match',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ] else if (!isAiRecipe &&
                        _userIngredients.isNotEmpty &&
                        recipe.matchPercentage > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${recipe.matchPercentage}% match',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],

                    // Missing ingredients info for AI recipes
                    if (isAiRecipe && recipe.missingIngredients > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${recipe.missingIngredients} ingredient${recipe.missingIngredients > 1 ? 's' : ''} missing',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: AppTheme.primaryGreen,
        size: 40,
      ),
    );
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Icons.star;
      case 'medium':
        return Icons.star_half;
      case 'hard':
        return Icons.star_border;
      default:
        return Icons.star;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.successGreen;
      case 'medium':
        return AppTheme.accentOrange;
      case 'hard':
        return AppTheme.warningRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _addIngredient(String ingredient) {
    if (ingredient.trim().isNotEmpty &&
        !_userIngredients.contains(ingredient.trim().toLowerCase())) {
      setState(() {
        _userIngredients.add(ingredient.trim().toLowerCase());
        _ingredientController.clear();
        if (!_useAiSearch) {
          _filterLocalRecipes();
        }
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _userIngredients.remove(ingredient);
      if (_useAiSearch && _userIngredients.isEmpty) {
        _aiRecipes.clear();
        _filteredRecipes.clear();
      } else if (!_useAiSearch) {
        _filterLocalRecipes();
      }
    });
  }
}
