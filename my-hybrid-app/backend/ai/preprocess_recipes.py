"""
Preprocess RAW_recipes.csv to Pickle format for faster loading.
Run this once: python preprocess_recipes.py
"""
import pandas as pd
import ast
import re
import os
import time

def convert_to_python_list(x):
    if isinstance(x, list):
        return x
    try:
        return ast.literal_eval(x)
    except Exception:
        return []

def normalize_token(s: str) -> str:
    s = s.lower().strip()
    s = re.sub(r"[^a-z0-9\s\-]", "", s)
    s = re.sub(r"\s+", " ", s)
    return s

def preprocess():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, "RAW_recipes.csv")
    pickle_path = os.path.join(script_dir, "recipes_processed.pkl")
    
    print("Loading CSV...")
    start = time.time()
    df = pd.read_csv(csv_path)
    print(f"CSV loaded in {time.time() - start:.2f}s, {len(df)} rows")
    
    print("Processing columns...")
    start = time.time()
    
    for col in ["ingredients", "tags", "steps"]:
        if col in df.columns:
            df[col] = df[col].apply(convert_to_python_list)
        else:
            df[col] = [[] for _ in range(len(df))]
    
    df["ingredients_norm"] = df["ingredients"].apply(
        lambda lst: [normalize_token(i) for i in lst]
    )
    
    df["tags_norm"] = df["tags"].apply(
        lambda lst: " ".join(normalize_token(t) for t in lst)
    )
    
    df["n_steps"] = df["steps"].apply(len)
    
    def calc_difficulty(row):
        if row["minutes"] <= 20 and row["n_steps"] <= 5:
            return "easy"
        if row["minutes"] <= 45 and row["n_steps"] <= 8:
            return "medium"
        return "hard"
    
    df["difficulty"] = df.apply(calc_difficulty, axis=1)
    
    columns_to_keep = [
        "id", "name", "minutes", "n_steps", "difficulty",
        "ingredients", "ingredients_norm", "tags", "tags_norm", "steps"
    ]
    df = df[[c for c in columns_to_keep if c in df.columns]]
    
    print(f"Processing done in {time.time() - start:.2f}s")
    
    print("Saving to Pickle...")
    start = time.time()
    df.to_pickle(pickle_path)
    print(f"Saved to {pickle_path} in {time.time() - start:.2f}s")
    
    print("\nVerifying Pickle load time...")
    start = time.time()
    df_test = pd.read_pickle(pickle_path)
    print(f"Pickle loaded in {time.time() - start:.2f}s, {len(df_test)} rows")
    
    print("\nPreprocessing complete!")

if __name__ == "__main__":
    preprocess()
