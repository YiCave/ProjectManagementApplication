import google.generativeai as genai
from PIL import Image
from dotenv import load_dotenv
import json
import os
import sys

# Fix Windows encoding issues
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

# Load Gemini API Key from .env
load_dotenv()
gemini_api_key = os.getenv("GOOGLE_API_KEY")
genai.configure(api_key=gemini_api_key)

def analyze_food_image (image_path: str) -> dict:
    """
    Docstring for analyze_food_image
    
    Parameters:
        image_path(str): Local file path of image to analyze
    
    Returns:
        dict: Analysis results including food name, food category and halal
    """
    img = Image.open(image_path)

    # Gemini prompt
    prompt = """
    You are a food recognition AI.
    Analyze the image and respond **ONLY** in valid JSON format using this schema:

    {
     "food_name":"string"
     "food_category":["vegan", "vegetarian", "halal", "non-vegetarian"]
     "possible_ingredients":["string",...]
     "halal": boolean
     "description": "short human readable summary"
    }

    **DO NOT** include any extra explanation outside the JSON.
    """

    model = genai.GenerativeModel( "gemini-2.5-flash")
    response = model.generate_content([prompt,img])

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
        
    return result

# Tester main method
if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_dir, "ramen.jpeg")
    
    result = analyze_food_image(image_path)
    print(json.dumps(result, indent=2))