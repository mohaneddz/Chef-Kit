"""Cooking instructions generation module.

Provides functionality to find the best matching recipe based on available ingredients
and time constraints using a scoring heuristic.
"""
from typing import List, Dict, Any, Optional
from supabase_client import supabase


def _parse_time(time_str: str) -> int:
    """Parse time string in format 'mm:ss' and return total minutes.
    
    Args:
        time_str: Time in format 'mm:ss' (e.g., '45:30' for 45 minutes 30 seconds)
        
    Returns:
        Total time in minutes (seconds are converted to fractional minutes)
    """
    try:
        parts = time_str.split(':')
        if len(parts) != 2:
            return 0
        minutes = int(parts[0])
        seconds = int(parts[1])
        return minutes + (seconds / 60.0)
    except (ValueError, AttributeError):
        return 0


def generate_cooking_instructions(ingredients: List[str], time: Optional[str] = None) -> List[Dict[str, Any]]:
    """Generate cooking instructions by finding the best matching recipes.
    
    Uses a heuristic to score recipes based on:
    - Number of matching ingredients (worth +5 points each)
    - Number of missing ingredients (worth -3 points each)
    - Time constraint penalty (worth -2 points per minute over desired time)
    
    Args:
        ingredients: List of available ingredient names (e.g., ['Potatoes', 'Carrots', 'Onions'])
        time: Optional time constraint in format 'mm:ss' (e.g., '45:00' for 45 minutes)
        
    Returns:
        List of top 10 recipes with their scores, sorted by score (highest first).
        Each item contains the full recipe data plus a 'score' field.
        Returns empty list if no recipes found or database error occurs.
    """
    try:
        # Parse desired time in minutes (input format: 'mm:ss')
        desired_time_minutes = _parse_time(time) if time else float('inf')
        
        # Fetch all recipes from database
        resp = supabase.table("recipe").select("*").execute()
        
        recipes = resp.data if resp.data else []
        
        if not recipes:
            return []
        
        # Normalize input ingredients to lowercase for case-insensitive matching
        normalized_input = [ing.lower().strip() for ing in ingredients]
        
        scored_recipes = []
        
        # Evaluate each recipe using the heuristic
        for recipe in recipes:
            # Get recipe ingredients and normalize
            recipe_ingredients = recipe.get('recipe_ingredients', [])
            if not isinstance(recipe_ingredients, list):
                continue
                
            normalized_recipe_ingredients = [ing.lower().strip() for ing in recipe_ingredients]
            
            # Count matching and missing ingredients
            ingredients_present = sum(
                1 for ing in normalized_recipe_ingredients 
                if any(input_ing in ing or ing in input_ing for input_ing in normalized_input)
            )
            ingredients_missing = len(normalized_recipe_ingredients) - ingredients_present
            
            # Calculate total recipe time (both are already in minutes as integers)
            prep_time = recipe.get('recipe_prep_time', 0) or 0
            cook_time = recipe.get('recipe_cook_time', 0) or 0
            total_recipe_time = prep_time + cook_time
            
            # Calculate time penalty (only if recipe exceeds desired time)
            time_penalty = max(total_recipe_time - desired_time_minutes, 0) * 2
            
            # Calculate final score using the heuristic
            score = (ingredients_present * 5) - (ingredients_missing * 3) - time_penalty
            
            # Add recipe with its score to the list
            recipe_with_score = {**recipe, 'score': score}
            scored_recipes.append(recipe_with_score)
        
        # Sort by score (descending) and return top 10
        scored_recipes.sort(key=lambda x: x['score'], reverse=True)
        return scored_recipes[:10]
        
    except Exception as e:
        print(f"Error in generate_cooking_instructions: {e}")
        return []

