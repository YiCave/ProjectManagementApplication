class Recipe {
  final String id;
  final String title;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookTimeMinutes;
  final String difficulty;
  final String imageUrl;
  final List<String> tags;
  final int matchPercentage;
  final int missingIngredients;
  final double score;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.instructions,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.imageUrl,
    required this.tags,
    this.matchPercentage = 0,
    this.missingIngredients = 0,
    this.score = 0.0,
  });

  /// Factory constructor to create Recipe from AI API response
  ///
  /// API response format:
  /// {
  ///   "id": 123,
  ///   "name": "Recipe Name",
  ///   "minutes": 30,
  ///   "difficulty": "easy",
  ///   "ingredients": ["ingredient1", "ingredient2"],
  ///   "coverage": 0.85,
  ///   "missing_ingredients": 2,
  ///   "score": 0.92
  /// }
  factory Recipe.fromApiResponse(Map<String, dynamic> json) {
    // Parse ingredients - can be a list of strings or a string that looks like a list
    List<String> parseIngredients(dynamic ingredientsData) {
      if (ingredientsData == null) return [];
      if (ingredientsData is List) {
        return ingredientsData.map((e) => e.toString()).toList();
      }
      if (ingredientsData is String) {
        // Handle string that looks like "['item1', 'item2']"
        String cleaned = ingredientsData
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll("'", '')
            .replaceAll('"', '');
        return cleaned
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    // Calculate match percentage from coverage (0.0-1.0 to 0-100)
    int calculateMatchPercentage(dynamic coverage) {
      if (coverage == null) return 0;
      if (coverage is num) {
        return (coverage * 100).round();
      }
      return 0;
    }

    // Capitalize difficulty
    String formatDifficulty(dynamic difficulty) {
      if (difficulty == null) return 'Medium';
      String diff = difficulty.toString().toLowerCase();
      return diff[0].toUpperCase() + diff.substring(1);
    }

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? 'Unknown Recipe',
      category: 'AI Recommended', // API doesn't provide category
      ingredients: parseIngredients(json['ingredients']),
      instructions: [], // API doesn't provide instructions
      cookTimeMinutes: json['minutes'] is num
          ? (json['minutes'] as num).toInt()
          : 0,
      difficulty: formatDifficulty(json['difficulty']),
      imageUrl: '', // API doesn't provide image
      tags: [], // API doesn't provide tags
      matchPercentage: calculateMatchPercentage(json['coverage']),
      missingIngredients: json['missing_ingredients'] is num
          ? (json['missing_ingredients'] as num).toInt()
          : 0,
      score: json['score'] is num ? (json['score'] as num).toDouble() : 0.0,
    );
  }

  Recipe copyWith({int? matchPercentage}) {
    return Recipe(
      id: id,
      title: title,
      category: category,
      ingredients: ingredients,
      instructions: instructions,
      cookTimeMinutes: cookTimeMinutes,
      difficulty: difficulty,
      imageUrl: imageUrl,
      tags: tags,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      missingIngredients: missingIngredients,
      score: score,
    );
  }
}

class RecipeDatabase {
  static List<Recipe> getAllRecipes() {
    return [
      Recipe(
        id: 'breakfast_1',
        title: 'Leftover Rice Breakfast Bowl',
        category: 'Breakfast',
        ingredients: [
          '1 cup cooked rice',
          '2 eggs',
          '1 tbsp soy sauce',
          '1 green onion, chopped',
          '1 tsp sesame oil',
          'Salt and pepper to taste',
        ],
        instructions: [
          'Heat oil in a pan over medium heat',
          'Add cooked rice and stir-fry for 2-3 minutes',
          'Push rice to one side, scramble eggs on the other side',
          'Mix everything together',
          'Add soy sauce, sesame oil, and seasonings',
          'Garnish with green onions and serve hot',
        ],
        cookTimeMinutes: 15,
        difficulty: 'Easy',
        imageUrl: 'assets/images/BreakfastBowls.jpg',
        tags: ['rice', 'eggs', 'quick', 'leftover'],
      ),
      Recipe(
        id: 'breakfast_2',
        title: 'Banana Pancakes',
        category: 'Breakfast',
        ingredients: [
          '2 ripe bananas',
          '2 eggs',
          '1/4 cup flour',
          '1 tsp baking powder',
          '1 tbsp honey',
          'Pinch of salt',
        ],
        instructions: [
          'Mash bananas in a bowl until smooth',
          'Beat in eggs and honey',
          'Mix flour, baking powder, and salt in separate bowl',
          'Combine wet and dry ingredients',
          'Cook pancakes in heated pan for 2-3 minutes each side',
          'Serve with fresh fruit or syrup',
        ],
        cookTimeMinutes: 20,
        difficulty: 'Easy',
        imageUrl: 'assets/images/Banana-Pancakes-13.jpg',
        tags: ['banana', 'eggs', 'flour', 'sweet'],
      ),
      Recipe(
        id: 'breakfast_3',
        title: 'Veggie Scramble',
        category: 'Breakfast',
        ingredients: [
          '3 eggs',
          '1/2 bell pepper, diced',
          '1/4 onion, diced',
          '1 tomato, diced',
          '2 tbsp olive oil',
          'Salt, pepper, herbs',
        ],
        instructions: [
          'Heat olive oil in pan over medium heat',
          'Sauté onion and bell pepper for 3-4 minutes',
          'Add tomato and cook for 2 minutes',
          'Beat eggs and pour into pan',
          'Scramble everything together until eggs are cooked',
          'Season with salt, pepper, and herbs',
        ],
        cookTimeMinutes: 12,
        difficulty: 'Easy',
        imageUrl: 'assets/images/veggiescramble.jpg',
        tags: ['eggs', 'vegetables', 'peppers', 'tomato', 'onion'],
      ),

      Recipe(
        id: 'lunch_1',
        title: 'Leftover Chicken Fried Rice',
        category: 'Lunch',
        ingredients: [
          '2 cups cooked rice',
          '1 cup leftover chicken, diced',
          '2 eggs',
          '1 carrot, diced',
          '1/2 cup peas',
          '3 tbsp soy sauce',
          '2 tbsp oil',
        ],
        instructions: [
          'Heat oil in large pan or wok',
          'Scramble eggs and set aside',
          'Add vegetables and stir-fry for 3 minutes',
          'Add rice and chicken, breaking up rice clumps',
          'Stir in soy sauce and scrambled eggs',
          'Cook for 2-3 minutes until heated through',
        ],
        cookTimeMinutes: 15,
        difficulty: 'Easy',
        imageUrl: 'assets/images/Bang-Bang-Chicken-Fried-Rice-2.jpg',
        tags: ['rice', 'chicken', 'eggs', 'vegetables', 'leftover'],
      ),
      Recipe(
        id: 'lunch_2',
        title: 'Quick Vegetable Soup',
        category: 'Lunch',
        ingredients: [
          '2 cups mixed vegetables',
          '4 cups vegetable broth',
          '1 onion, diced',
          '2 cloves garlic, minced',
          '1 tbsp olive oil',
          'Salt, pepper, herbs',
        ],
        instructions: [
          'Heat oil in large pot over medium heat',
          'Sauté onion and garlic for 3 minutes',
          'Add vegetables and cook for 5 minutes',
          'Pour in broth and bring to boil',
          'Simmer for 15-20 minutes until vegetables are tender',
          'Season with salt, pepper, and herbs',
        ],
        cookTimeMinutes: 30,
        difficulty: 'Easy',
        imageUrl:
            'assets/images/13338-quick-and-easy-vegetable-soup-DDMFS-4x3-402702f59e7a41519515cecccaba1b80.jpg',
        tags: ['vegetables', 'soup', 'healthy', 'broth'],
      ),
      Recipe(
        id: 'lunch_3',
        title: 'Pasta with Leftover Meat',
        category: 'Lunch',
        ingredients: [
          '300g pasta',
          '1 cup leftover meat, diced',
          '2 cups tomato sauce',
          '1 onion, diced',
          '2 cloves garlic, minced',
          'Herbs and spices',
        ],
        instructions: [
          'Cook pasta according to package directions',
          'Sauté onion and garlic in large pan',
          'Add leftover meat and heat through',
          'Stir in tomato sauce and simmer 10 minutes',
          'Drain pasta and mix with sauce',
          'Serve with herbs and cheese if desired',
        ],
        cookTimeMinutes: 25,
        difficulty: 'Easy',
        imageUrl:
            'assets/images/Greek-Spaghetti-with-Ground-Beef-Sauce-recipe-–-Makaronia-me-Kima-2.jpg',
        tags: ['pasta', 'meat', 'tomato', 'leftover'],
      ),
      Recipe(
        id: 'lunch_4',
        title: 'Grain Bowl with Roasted Vegetables',
        category: 'Lunch',
        ingredients: [
          '1 cup cooked quinoa or rice',
          '2 cups mixed vegetables',
          '2 tbsp olive oil',
          '1 tbsp lemon juice',
          '2 tbsp tahini or dressing',
          'Salt, pepper, spices',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C)',
          'Toss vegetables with olive oil, salt, and pepper',
          'Roast for 20-25 minutes until tender',
          'Prepare grains according to package instructions',
          'Whisk together tahini, lemon juice, and spices for dressing',
          'Serve roasted vegetables over grains with dressing',
        ],
        cookTimeMinutes: 35,
        difficulty: 'Medium',
        imageUrl: 'assets/images/grainbowlvege.jpg',
        tags: ['grains', 'vegetables', 'healthy', 'roasted'],
      ),

      Recipe(
        id: 'dinner_1',
        title: 'One-Pot Chicken and Rice',
        category: 'Dinner',
        ingredients: [
          '4 chicken thighs',
          '1.5 cups rice',
          '3 cups chicken broth',
          '1 onion, diced',
          '2 cloves garlic, minced',
          'Mixed vegetables',
        ],
        instructions: [
          'Season chicken with salt and pepper',
          'Brown chicken in large pot, then remove',
          'Sauté onion and garlic in same pot',
          'Add rice and stir for 2 minutes',
          'Return chicken to pot, add broth and vegetables',
          'Simmer covered for 20-25 minutes until rice is tender',
        ],
        cookTimeMinutes: 45,
        difficulty: 'Medium',
        imageUrl: 'assets/images/onepotchicrice.jpg',
        tags: ['chicken', 'rice', 'one-pot', 'vegetables'],
      ),
      Recipe(
        id: 'dinner_2',
        title: 'Vegetable Stir-fry',
        category: 'Dinner',
        ingredients: [
          '4 cups mixed vegetables',
          '2 tbsp vegetable oil',
          '3 tbsp soy sauce',
          '1 tbsp oyster sauce',
          '1 tsp cornstarch',
          'Ginger and garlic',
        ],
        instructions: [
          'Heat oil in wok or large pan over high heat',
          'Add ginger and garlic, stir-fry for 30 seconds',
          'Add harder vegetables first, cook 3-4 minutes',
          'Add softer vegetables, cook 2-3 minutes',
          'Mix sauces with cornstarch, add to pan',
          'Stir-fry until sauce thickens and coats vegetables',
        ],
        cookTimeMinutes: 15,
        difficulty: 'Easy',
        imageUrl: 'assets/images/grainbowlvege.jpg',
        tags: ['vegetables', 'stir-fry', 'quick', 'asian'],
      ),
      Recipe(
        id: 'dinner_3',
        title: 'Fish with Lemon Herbs',
        category: 'Dinner',
        ingredients: [
          '4 fish fillets',
          '2 lemons',
          '3 tbsp olive oil',
          'Fresh herbs (parsley, dill)',
          '2 cloves garlic, minced',
          'Salt and pepper',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C)',
          'Pat fish dry and season with salt and pepper',
          'Mix olive oil, lemon juice, garlic, and herbs',
          'Place fish in baking dish, pour mixture over top',
          'Bake for 12-15 minutes until fish flakes easily',
          'Serve with lemon wedges and fresh herbs',
        ],
        cookTimeMinutes: 25,
        difficulty: 'Easy',
        imageUrl: 'assets/images/lemon-and-herb-fish-with-wedges-75148-1.webp',
        tags: ['fish', 'lemon', 'herbs', 'healthy'],
      ),

      Recipe(
        id: 'snack_1',
        title: 'Fruit and Nut Energy Balls',
        category: 'Snacks',
        ingredients: [
          '1 cup dates, pitted',
          '1/2 cup mixed nuts',
          '2 tbsp coconut flakes',
          '1 tbsp chia seeds',
          '1 tsp vanilla extract',
          'Pinch of salt',
        ],
        instructions: [
          'Process dates in food processor until paste forms',
          'Add nuts and pulse until roughly chopped',
          'Add coconut, chia seeds, vanilla, and salt',
          'Mix until everything sticks together',
          'Roll mixture into small balls',
          'Chill in refrigerator for 30 minutes before serving',
        ],
        cookTimeMinutes: 15,
        difficulty: 'Easy',
        imageUrl: 'assets/images/nobakefruitnutenergyballs.jpg',
        tags: ['dates', 'nuts', 'healthy', 'no-bake'],
      ),
      Recipe(
        id: 'snack_2',
        title: 'Vegetable Chips',
        category: 'Snacks',
        ingredients: [
          '2 large sweet potatoes or beets',
          '2 tbsp olive oil',
          '1 tsp sea salt',
          '1/2 tsp paprika',
          'Black pepper to taste',
        ],
        instructions: [
          'Preheat oven to 400°F (200°C)',
          'Wash and slice vegetables very thinly',
          'Toss slices with olive oil and seasonings',
          'Arrange in single layer on baking sheets',
          'Bake for 15-20 minutes, flipping halfway',
          'Cool completely before serving',
        ],
        cookTimeMinutes: 30,
        difficulty: 'Easy',
        imageUrl:
            'assets/images/homemade-vegetable-chips-102105-hero-01-5be2062fc9e77c0051eb8529.jpg',
        tags: ['vegetables', 'healthy', 'baked', 'crispy'],
      ),
      Recipe(
        id: 'snack_3',
        title: 'Quick Hummus',
        category: 'Snacks',
        ingredients: [
          '1 can chickpeas, drained',
          '2 tbsp tahini',
          '2 tbsp lemon juice',
          '2 cloves garlic',
          '3 tbsp olive oil',
          'Salt and cumin',
        ],
        instructions: [
          'Reserve some chickpea liquid before draining',
          'Add all ingredients to food processor',
          'Process until smooth and creamy',
          'Add reserved liquid if needed for consistency',
          'Taste and adjust seasonings',
          'Serve with vegetables or pita bread',
        ],
        cookTimeMinutes: 10,
        difficulty: 'Easy',
        imageUrl:
            'assets/images/232962-super-easy-hummus-ddmfs-1X2-0316-bf44d147efde4432b6f3b4a0c251ac06.jpg',
        tags: ['chickpeas', 'healthy', 'dip', 'protein'],
      ),

      Recipe(
        id: 'dessert_1',
        title: 'Banana Nice Cream',
        category: 'Desserts',
        ingredients: [
          '3 ripe bananas, frozen',
          '2 tbsp almond milk',
          '1 tbsp peanut butter',
          '1 tsp vanilla extract',
          'Optional: cocoa powder, berries',
        ],
        instructions: [
          'Let frozen bananas thaw for 5 minutes',
          'Add bananas to food processor',
          'Process until it starts to break down',
          'Add almond milk, peanut butter, and vanilla',
          'Process until smooth and creamy',
          'Serve immediately or freeze for firmer texture',
        ],
        cookTimeMinutes: 10,
        difficulty: 'Easy',
        imageUrl: 'assets/images/bananaicecream.jpg',
        tags: ['banana', 'healthy', 'frozen', 'dairy-free'],
      ),
      Recipe(
        id: 'dessert_2',
        title: 'No-Bake Chocolate Oat Cookies',
        category: 'Desserts',
        ingredients: [
          '2 cups rolled oats',
          '1/2 cup cocoa powder',
          '1/2 cup honey',
          '1/3 cup peanut butter',
          '1 tsp vanilla extract',
          'Pinch of salt',
        ],
        instructions: [
          'Mix oats, cocoa powder, and salt in large bowl',
          'Heat honey and peanut butter in saucepan until smooth',
          'Remove from heat, stir in vanilla',
          'Pour over oat mixture and stir well',
          'Drop spoonfuls onto parchment paper',
          'Chill for 30 minutes until set',
        ],
        cookTimeMinutes: 20,
        difficulty: 'Easy',
        imageUrl: 'assets/images/chocoatcookies.jpg',
        tags: ['oats', 'chocolate', 'no-bake', 'sweet'],
      ),
    ];
  }

  static List<Recipe> getRecipesByCategory(String category) {
    return getAllRecipes()
        .where((recipe) => recipe.category == category)
        .toList();
  }

  static List<Recipe> searchRecipesByIngredients(
    List<String> availableIngredients,
  ) {
    final allRecipes = getAllRecipes();
    final List<Recipe> matchedRecipes = [];

    for (final recipe in allRecipes) {
      int matchCount = 0;
      for (final ingredient in availableIngredients) {
        for (final recipeIngredient in recipe.ingredients) {
          if (recipeIngredient.toLowerCase().contains(
                ingredient.toLowerCase(),
              ) ||
              recipe.tags.any(
                (tag) => tag.toLowerCase().contains(ingredient.toLowerCase()),
              )) {
            matchCount++;
            break;
          }
        }
      }

      if (matchCount > 0) {
        final matchPercentage =
            ((matchCount / availableIngredients.length) * 100).round();
        matchedRecipes.add(recipe.copyWith(matchPercentage: matchPercentage));
      }
    }

    matchedRecipes.sort(
      (a, b) => b.matchPercentage.compareTo(a.matchPercentage),
    );
    return matchedRecipes;
  }

  static List<String> getAllCategories() {
    return ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks', 'Desserts'];
  }
}
