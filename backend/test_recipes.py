
import os
import sys
from services import get_recipes_result

# Mock environment variables if needed, but services.py imports them from supabase_client
# which loads from .env or environment. 
# Assuming the environment is set up correctly in the terminal where I run this.

try:
    print("Calling get_recipes_result()...")
    recipes = get_recipes_result()
    print(f"Successfully retrieved {len(recipes)} recipes.")
    if len(recipes) > 0:
        r = recipes[0]
        print("First recipe sample keys:", r.keys())
        print("Ingredients type:", type(r.get('recipe_ingredients')))
        print("Instructions type:", type(r.get('recipe_instructions')))
        print("Ingredients sample:", r.get('recipe_ingredients'))
except Exception as e:
    print(f"Error: {e}")
