/// Helper class to generate placeholder images for recipes
/// Uses free image APIs to provide realistic food images for demo/prototype purposes
class RecipeImageHelper {
  /// Generate a food image URL based on recipe name
  /// Uses Unsplash Source API for high-quality food images
  static String getImageUrl(String recipeName, {int width = 400, int height = 300}) {
    // Extract main food keyword from recipe name
    final keyword = _extractFoodKeyword(recipeName);
    
    // Use Unsplash Source API - free, no API key needed
    // Format: https://source.unsplash.com/WIDTHxHEIGHT/?KEYWORD
    return 'https://source.unsplash.com/${width}x$height/?$keyword,food';
  }

  /// Alternative: Use Lorem Picsum for consistent placeholder images
  /// Good for when you want consistent images that don't change
  static String getConsistentImageUrl(String recipeName, {int width = 400, int height = 300}) {
    // Generate a consistent seed from recipe name
    final seed = recipeName.hashCode.abs() % 1000;
    return 'https://picsum.photos/seed/$seed/$width/$height';
  }

  /// Use Foodish API for random food images
  /// Returns category-specific food images
  static String getFoodishImageUrl(String recipeName) {
    final category = _getFoodishCategory(recipeName);
    return 'https://foodish-api.com/images/$category/${(recipeName.hashCode.abs() % 20) + 1}.jpg';
  }

  /// Extract the main food keyword from recipe name for better image search
  static String _extractFoodKeyword(String recipeName) {
    final name = recipeName.toLowerCase();
    
    // Common food keywords to look for
    final foodKeywords = {
      // Proteins
      'chicken': 'chicken',
      'beef': 'beef',
      'pork': 'pork',
      'fish': 'fish',
      'salmon': 'salmon',
      'shrimp': 'shrimp',
      'lamb': 'lamb',
      'turkey': 'turkey',
      'tofu': 'tofu',
      'egg': 'eggs',
      
      // Dishes
      'pasta': 'pasta',
      'spaghetti': 'spaghetti',
      'noodle': 'noodles',
      'rice': 'rice',
      'soup': 'soup',
      'salad': 'salad',
      'sandwich': 'sandwich',
      'burger': 'burger',
      'pizza': 'pizza',
      'taco': 'tacos',
      'curry': 'curry',
      'stir fry': 'stir-fry',
      'stew': 'stew',
      'roast': 'roast',
      'grill': 'grilled',
      'fried': 'fried',
      'baked': 'baked',
      
      // Asian
      'sushi': 'sushi',
      'ramen': 'ramen',
      'dim sum': 'dim-sum',
      'teriyaki': 'teriyaki',
      'kung pao': 'kung-pao',
      'pad thai': 'pad-thai',
      
      // Italian
      'lasagna': 'lasagna',
      'risotto': 'risotto',
      'carbonara': 'carbonara',
      
      // Mexican
      'burrito': 'burrito',
      'enchilada': 'enchilada',
      'quesadilla': 'quesadilla',
      
      // Desserts
      'cake': 'cake',
      'cookie': 'cookies',
      'pie': 'pie',
      'brownie': 'brownies',
      'ice cream': 'ice-cream',
      'pudding': 'pudding',
      
      // Breakfast
      'pancake': 'pancakes',
      'waffle': 'waffles',
      'omelette': 'omelette',
      'french toast': 'french-toast',
      
      // Vegetables
      'vegetable': 'vegetables',
      'broccoli': 'broccoli',
      'spinach': 'spinach',
      'mushroom': 'mushroom',
      'potato': 'potato',
      'tomato': 'tomato',
    };
    
    // Search for keywords in recipe name
    for (final entry in foodKeywords.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Default to generic food image
    return 'delicious,meal';
  }

  /// Map recipe name to Foodish API category
  static String _getFoodishCategory(String recipeName) {
    final name = recipeName.toLowerCase();
    
    if (name.contains('rice')) return 'rice';
    if (name.contains('pasta') || name.contains('spaghetti')) return 'pasta';
    if (name.contains('pizza')) return 'pizza';
    if (name.contains('burger')) return 'burger';
    if (name.contains('dessert') || name.contains('cake') || name.contains('cookie')) return 'dessert';
    if (name.contains('biryani')) return 'biryani';
    if (name.contains('dosa')) return 'dosa';
    if (name.contains('idly')) return 'idly';
    
    // Default categories
    final categories = ['rice', 'pasta', 'pizza', 'burger', 'dessert'];
    return categories[recipeName.hashCode.abs() % categories.length];
  }

  /// Get a list of curated food image URLs for common recipe types
  /// These are hand-picked high-quality images that always work
  static String getCuratedImageUrl(String recipeName) {
    final name = recipeName.toLowerCase();
    
    // Curated Unsplash image IDs for specific food types
    final curatedImages = {
      'chicken': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6?w=400&h=300&fit=crop',
      'beef': 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=400&h=300&fit=crop',
      'pasta': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&h=300&fit=crop',
      'salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop',
      'soup': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&h=300&fit=crop',
      'pizza': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400&h=300&fit=crop',
      'burger': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop',
      'sushi': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400&h=300&fit=crop',
      'rice': 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=400&h=300&fit=crop',
      'noodle': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&h=300&fit=crop',
      'curry': 'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=300&fit=crop',
      'sandwich': 'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=400&h=300&fit=crop',
      'cake': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop',
      'cookie': 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&h=300&fit=crop',
      'fish': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&h=300&fit=crop',
      'shrimp': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&h=300&fit=crop',
      'steak': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?w=400&h=300&fit=crop',
      'breakfast': 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400&h=300&fit=crop',
      'egg': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&h=300&fit=crop',
      'vegetable': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop',
      'fruit': 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=400&h=300&fit=crop',
      'dessert': 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=400&h=300&fit=crop',
      'smoothie': 'https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=400&h=300&fit=crop',
      'taco': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400&h=300&fit=crop',
    };
    
    // Find matching curated image
    for (final entry in curatedImages.entries) {
      if (name.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Fallback to a variety of general food images based on hash
    final fallbackImages = [
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop', // Food platter
      'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=400&h=300&fit=crop', // Healthy bowl
      'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?w=400&h=300&fit=crop', // Breakfast
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop', // Meal prep
      'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400&h=300&fit=crop', // Fish dish
      'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=400&h=300&fit=crop', // Pasta dish
      'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=400&h=300&fit=crop', // Asian food
      'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&h=300&fit=crop', // Restaurant dish
      'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=400&h=300&fit=crop', // Pasta
      'https://images.unsplash.com/photo-1484723091739-30a097e8f929?w=400&h=300&fit=crop', // Breakfast
    ];
    
    return fallbackImages[recipeName.hashCode.abs() % fallbackImages.length];
  }
}
