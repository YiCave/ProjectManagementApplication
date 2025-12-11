import google.generativeai as genai
from PIL import Image
import json
import os
from dotenv import load_dotenv
import pandas as pd
import ast
import re
from typing import List, Optional

load_dotenv()
gemini_api_key = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=gemini_api_key)

# AI image Analyzer
def detect_ingredients_from_image(image_path: str):
    """
    Detects the food ingredients found in the image captured by user
    """
    img = Image.open(image_path)

    prompt = """
    You are a professional Food Ingredients Analyzer.
    You will analyze the food ingredients found in the image and **ONLY** return specific format JSON

    **IMPORTANT RULES**:
    - Use generic food names, not brands.
    - If unsure, guess based on packaging shape.
    - Output ONLY valid JSON, no explanation.

    JSON template:
    {
    "ingredients" = [{"ingredient_name": "name", "confidence": "0.0"}]
    }
    """

    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content([img, prompt])

    # Debug: Print raw response
    print("=== RAW MODEL RESPONSE ===")
    print(response.text)
    print("=== END RAW RESPONSE ===\n")

    # Clean the response - remove markdown code blocks if present
    response_text = response.text.strip()
    if response_text.startswith("```json"):
        response_text = response_text[7:]  # Remove ```json
    elif response_text.startswith("```"):
        response_text = response_text[3:]  # Remove ```
    
    if response_text.endswith("```"):
        response_text = response_text[:-3]  # Remove trailing ```
    
    response_text = response_text.strip()

    try:
        result = json.loads(response_text)
    except json.JSONDecodeError as e:
        print(f"JSON Parse Error: {e}")
        result = {"error": "Model did not return valid JSON", "raw_response": response.text}

    # Extracts the ingredients with high AI confidence level (>= 0.80) into list
    filtered_ingredients = []

    for item in result.get("ingredients", []):
        try:
            if float(item.get("confidence", 0)) >= 0.80:
                filtered_ingredients.append(item.get("ingredient_name").strip().lower())
        except (ValueError, AttributeError):
            pass
    
    return filtered_ingredients

# Recipe Pipeline
class RecipeEngine:
    def __init__(self, csv_path: str):
        """
        Initialize the recipe engine with the RAW_recipes.csv
        """
        self.df = pd.read_csv(csv_path)
        self._prepare_dataframe()

    @staticmethod
    def _convert_to_python_list (x):
        """
        RAW_recipes stores lists as string like "['a','b']"
        This safely converts the string to Python valid lists.
        """
        if isinstance(x, list):
            return x
        try:
            return ast.literal_eval(x) # "['a','b']" -> ['a','b']
        except Exception as e:
            print(f"Error to convert to python list: {e}")
            return []
        
    @staticmethod
    def _normalize_token(s: str) -> str:
        """
        Basic normalization for ingredient/cuisine/tag:
        - lowercase
        - strip spaces
        - remove extra punctuation
        """
        s = s.lower().strip()
        s = re.sub(r"[^a-z0-9\s\-]", "", s)
        s = re.sub(r"\s+", " ", s)
        return s
    
    def _prepare_dataframe(self):
        """
        Parse and enrich the raw recipes dataframe.
        """
        df = self.df.copy()

        # Convert stringified lists into Python lists
        for col in ["ingredients", "tags", "steps"]:
            if col in df.columns:
                df[col] = df[col].apply(self._convert_to_python_list)
            else:
                df[col] = [[] for _ in range(len(df))]

        # Normalized ingredients list
        df["ingredients_norm"] = df["ingredients"].apply(
            lambda lst: [self._normalize_token(i) for i in lst]
        )

        # Tags to one long string for easy text search
        df["tags_norm"] = df["tags"].apply(
            lambda lst: " ".join(self._normalize_token(t) for t in lst)
        )

        # Steps count and rough difficulty
        df["n_steps"] = df["steps"].apply(len)

        def _difficulty(row):
            if row["minutes"] <= 20 and row["n_steps"] <= 5:
                return "easy"
            if row["minutes"] <= 45 and row["n_steps"] <= 8:
                return "medium"
            return "hard"

        df["difficulty"] = df.apply(_difficulty, axis=1)

        # Cache
        self.df = df

    def recommend(
        self,
        pantry_ingredients: List[str],
        max_minutes: Optional[int] = None,
        cuisines: Optional[List[str]] = None,
        vegetarian: bool = False,
        vegan: bool = False,
        halal: bool = False,
        max_missing_ingredients: int = 5,
        top_k: int = 10,
    ) -> pd.DataFrame:

        df = self.df
        pantry_norm = [self._normalize_token(i) for i in pantry_ingredients]

        query_str_parts = []
        if max_minutes is not None:
            query_str_parts.append("minutes <= @max_minutes")

        if query_str_parts:
            candidates = df.query(" & ".join(query_str_parts)).copy()
        else:
            candidates = df.copy()

        mask = pd.Series(True, index=candidates.index)

        if cuisines:
            cuisines_norm = [self._normalize_token(c) for c in cuisines]
            pattern = "|".join(re.escape(c) for c in cuisines_norm)
            mask &= candidates["tags_norm"].str.contains(pattern, regex=True)

        if vegetarian:
            mask &= candidates["tags_norm"].str.contains("vegetarian", regex=False)
        if vegan:
            mask &= candidates["tags_norm"].str.contains("vegan", regex=False)

        if halal:
            non_halal_pattern = "pork|bacon|ham|wine|beer|prosciutto|lard"
            mask &= ~candidates["ingredients_norm"].apply(
                lambda ingr: any(re.search(non_halal_pattern, ing) for ing in ingr)
            )

        candidates = candidates[mask]
        if candidates.empty:
            return candidates

        def coverage_and_missing(ingredients_norm):
            matches = sum(
                1 for ing in ingredients_norm 
                if any(p in ing or ing in p for p in pantry_norm)
            )
            return matches / len(ingredients_norm), len(ingredients_norm) - matches

        cov_missing = candidates["ingredients_norm"].apply(coverage_and_missing)
        candidates["coverage"] = cov_missing.apply(lambda x: x[0])
        candidates["missing_ingredients"] = cov_missing.apply(lambda x: x[1])
        candidates = candidates[candidates["missing_ingredients"] <= max_missing_ingredients]

        def score_row(row):
            base = row["coverage"]
            time_penalty = (row["minutes"] / max_minutes) * 0.2 if max_minutes else 0
            missing_penalty = row["missing_ingredients"] * 0.05
            return base - time_penalty - missing_penalty

        candidates["score"] = candidates.apply(score_row, axis=1)

        return (
            candidates.sort_values("score", ascending=False)
            .loc[:, ["id", "name", "minutes", "difficulty", "ingredients", "coverage", "missing_ingredients", "score"]]
            .head(top_k)
        )
    
# Tester method
if __name__ == "__main__":
    # AI food ingredients detector testing
    script_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_dir, "raw_food_ingredients.webp")
    # result = detect_ingredients_from_image(image_path)
    # print(json.dumps(result, indent=2))

    csv_path = os.path.join(script_dir, "RAW_recipes.csv")
    engine = RecipeEngine(csv_path)

    pantry = detect_ingredients_from_image(image_path)

    print("\nDetected Items:", pantry)

    recs = engine.recommend(
        pantry_ingredients=pantry,
        halal=True,
        max_minutes=30,
        top_k=5,
    )

    pd.set_option("display.max_colwidth", 140)
    pd.set_option("display.max_columns", None)  # Show all columns
    pd.set_option("display.width", None)        # Auto-detect width
    print("\nRecommended recipes:\n")
    print(recs)


