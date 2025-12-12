"""
Command line interface for AI functions.
This script acts as a bridge between Node.js and Python AI modules.

Usage:
    python ai_cli.py analyze-food <image_path>
    python ai_cli.py detect-ingredients <image_path>
    python ai_cli.py recommend-recipes <json_params>
"""

import sys
import json
import os

# Fix Windows encoding issues
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# Add current directory to path so we can import our modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from food_detection import analyze_food_image
from ai_recipes_suggestion import detect_ingredients_from_image, RecipeEngine

# Cache the recipe engine so we don't reload CSV every time
_recipe_engine = None

def get_recipe_engine():
    """
    Lazy load the recipe engine. We only want to load the CSV once
    since it's a pretty big file and takes time to process.
    """
    global _recipe_engine
    if _recipe_engine is None:
        csv_path = os.path.join(os.path.dirname(__file__), "RAW_recipes.csv")
        _recipe_engine = RecipeEngine(csv_path)
    return _recipe_engine


def handle_analyze_food(image_path):
    """
    Analyze a food image and return info about what food it is,
    whether it's halal, vegetarian, etc.
    """
    if not os.path.exists(image_path):
        return {"success": False, "error": f"Image not found: {image_path}"}
    
    try:
        result = analyze_food_image(image_path)
        return {"success": True, "data": result}
    except Exception as e:
        return {"success": False, "error": str(e)}


def handle_detect_ingredients(image_path):
    """
    Look at an image (like a photo of your fridge) and detect
    what ingredients are visible.
    """
    if not os.path.exists(image_path):
        return {"success": False, "error": f"Image not found: {image_path}"}
    
    try:
        ingredients = detect_ingredients_from_image(image_path)
        return {"success": True, "data": {"ingredients": ingredients}}
    except Exception as e:
        return {"success": False, "error": str(e)}


def handle_recommend_recipes(params_json):
    """
    Given a list of ingredients and some filters, recommend recipes
    that the user can make.
    """
    try:
        params = json.loads(params_json)
    except json.JSONDecodeError as e:
        return {"success": False, "error": f"Invalid JSON params: {e}"}
    
    # Extract parameters with defaults
    ingredients = params.get("ingredients", [])
    if not ingredients:
        return {"success": False, "error": "No ingredients provided"}
    
    max_minutes = params.get("maxMinutes", None)
    cuisines = params.get("cuisines", None)
    vegetarian = params.get("vegetarian", False)
    vegan = params.get("vegan", False)
    halal = params.get("halal", False)
    max_missing = params.get("maxMissingIngredients", 5)
    top_k = params.get("topK", 10)
    
    try:
        engine = get_recipe_engine()
        results = engine.recommend(
            pantry_ingredients=ingredients,
            max_minutes=max_minutes,
            cuisines=cuisines,
            vegetarian=vegetarian,
            vegan=vegan,
            halal=halal,
            max_missing_ingredients=max_missing,
            top_k=top_k
        )
        
        # Convert DataFrame to list of dicts for JSON serialization
        recipes = results.to_dict(orient="records")
        
        return {"success": True, "data": {"recipes": recipes, "count": len(recipes)}}
    except Exception as e:
        return {"success": False, "error": str(e)}


def main():
    """
    Main entry point. Parse command line args and call the appropriate handler.
    Output is always JSON so Node.js can parse it easily.
    """
    if len(sys.argv) < 2:
        result = {"success": False, "error": "No command provided. Use: analyze-food, detect-ingredients, or recommend-recipes"}
        print(json.dumps(result))
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "analyze-food":
        if len(sys.argv) < 3:
            result = {"success": False, "error": "Missing image path"}
        else:
            result = handle_analyze_food(sys.argv[2])
    
    elif command == "detect-ingredients":
        if len(sys.argv) < 3:
            result = {"success": False, "error": "Missing image path"}
        else:
            result = handle_detect_ingredients(sys.argv[2])
    
    elif command == "recommend-recipes":
        if len(sys.argv) < 3:
            result = {"success": False, "error": "Missing JSON params"}
        else:
            result = handle_recommend_recipes(sys.argv[2])
    
    else:
        result = {"success": False, "error": f"Unknown command: {command}"}
    
    # Always output valid JSON
    print(json.dumps(result))
    sys.exit(0 if result.get("success") else 1)


if __name__ == "__main__":
    main()
