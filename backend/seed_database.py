"""
Database Seed Script
Seeds the Supabase database with sample chefs and recipes.

Usage:
    cd backend
    python seed_database.py
"""

import os
import uuid
from dotenv import load_dotenv

load_dotenv()

from supabase_client import supabase_admin

if not supabase_admin:
    raise ValueError("supabase_admin not initialized. Check SUPABASE_SERVICE_ROLE_KEY in .env")


# Sample chef users to create/update
SAMPLE_CHEFS = [
    {
        "user_full_name": "Chef Gordon",
        "user_email": "gordon@example.com",
        "user_is_chef": True,
        "user_is_on_fire": True,
        "user_bio": "Award-winning chef with 25 years of experience in fine dining.",
        "user_story": "Started cooking at age 8 in my grandmother's kitchen.",
        "user_specialties": ["French Cuisine", "Seafood", "Grilling"],
        "user_avatar": "https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=200",
    },
    {
        "user_full_name": "Chef Maria",
        "user_email": "maria@example.com",
        "user_is_chef": True,
        "user_is_on_fire": True,
        "user_bio": "Passionate about Mediterranean and Italian cuisine.",
        "user_story": "Learned the art of pasta-making in Naples.",
        "user_specialties": ["Italian", "Mediterranean", "Pasta"],
        "user_avatar": "https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?w=200",
    },
    {
        "user_full_name": "Chef Yuki",
        "user_email": "yuki@example.com",
        "user_is_chef": True,
        "user_is_on_fire": False,
        "user_bio": "Master of Japanese cuisine and sushi artistry.",
        "user_story": "Trained for 10 years in Tokyo before opening my own restaurant.",
        "user_specialties": ["Japanese", "Sushi", "Ramen"],
        "user_avatar": "https://images.unsplash.com/photo-1607631568010-a87245c0daf8?w=200",
    },
    {
        "user_full_name": "Chef Carlos",
        "user_email": "carlos@example.com",
        "user_is_chef": True,
        "user_is_on_fire": False,
        "user_bio": "Bringing authentic Mexican flavors to the world.",
        "user_story": "My abuela's recipes are my inspiration.",
        "user_specialties": ["Mexican", "Tacos", "Street Food"],
        "user_avatar": "https://images.unsplash.com/photo-1583394293214-28ez38e0f43a?w=200",
    },
]

# Sample recipes - column names match database schema
SAMPLE_RECIPES = [
    {
        "recipe_name": "Classic Beef Burger",
        "recipe_description": "A juicy, perfectly seasoned beef burger with all the fixings.",
        "recipe_image_url": "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400",
        "recipe_servings_count": 4,
        "recipe_prep_time": 15,
        "recipe_cook_time": 15,
        "recipe_calories": 550,
        "recipe_ingredients": ["500g ground beef", "4 burger buns", "1 tomato sliced", "Lettuce leaves", "Cheese slices", "Salt and pepper"],
        "recipe_instructions": ["Mix beef with salt and pepper", "Form into 4 patties", "Grill for 4 min each side", "Toast buns", "Assemble with toppings"],
        "recipe_tags": ["American", "Burgers", "Grilling"],
        "basic_ingredients": "beef, bread, tomato, lettuce, cheese",
        "recipe_is_trending": True,
        "recipe_is_seasonal": False,
    },
    {
        "recipe_name": "Spaghetti Carbonara",
        "recipe_description": "Creamy Italian pasta with pancetta and parmesan.",
        "recipe_image_url": "https://images.unsplash.com/photo-1612874742237-6526221588e3?w=400",
        "recipe_servings_count": 2,
        "recipe_prep_time": 10,
        "recipe_cook_time": 20,
        "recipe_calories": 650,
        "recipe_ingredients": ["200g spaghetti", "100g pancetta", "2 eggs", "50g parmesan", "Black pepper"],
        "recipe_instructions": ["Cook pasta al dente", "Fry pancetta until crispy", "Mix eggs with parmesan", "Combine pasta with pancetta", "Add egg mixture off heat", "Season with pepper"],
        "recipe_tags": ["Italian", "Pasta", "Comfort Food"],
        "basic_ingredients": "pasta, eggs, cheese",
        "recipe_is_trending": True,
        "recipe_is_seasonal": False,
    },
    {
        "recipe_name": "Chicken Tikka Masala",
        "recipe_description": "Tender chicken in a rich, creamy tomato-based curry sauce.",
        "recipe_image_url": "https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400",
        "recipe_servings_count": 4,
        "recipe_prep_time": 30,
        "recipe_cook_time": 30,
        "recipe_calories": 480,
        "recipe_ingredients": ["500g chicken breast", "1 cup yogurt", "2 tbsp tikka paste", "400ml tomato sauce", "200ml cream", "Rice for serving"],
        "recipe_instructions": ["Marinate chicken in yogurt and spices", "Grill chicken until charred", "Simmer tomato sauce with spices", "Add cream and chicken", "Serve with rice"],
        "recipe_tags": ["Indian", "Curry", "Spicy"],
        "basic_ingredients": "chicken, yogurt, tomato, cream, rice",
        "recipe_is_trending": True,
        "recipe_is_seasonal": False,
    },
    {
        "recipe_name": "Winter Vegetable Soup",
        "recipe_description": "Hearty soup with root vegetables, perfect for cold days.",
        "recipe_image_url": "https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400",
        "recipe_servings_count": 6,
        "recipe_prep_time": 20,
        "recipe_cook_time": 40,
        "recipe_calories": 180,
        "recipe_ingredients": ["2 carrots", "2 potatoes", "1 onion", "2 celery stalks", "1L vegetable broth", "Herbs"],
        "recipe_instructions": ["Dice all vegetables", "Sauté onion and celery", "Add remaining vegetables", "Pour in broth", "Simmer until tender", "Season and serve"],
        "recipe_tags": ["Soup", "Vegetarian", "Winter"],
        "basic_ingredients": "carrot, potato, onion, broth",
        "recipe_is_trending": False,
        "recipe_is_seasonal": True,
    },
    {
        "recipe_name": "Apple Cinnamon Pancakes",
        "recipe_description": "Fluffy pancakes with fresh apples and warm cinnamon.",
        "recipe_image_url": "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400",
        "recipe_servings_count": 4,
        "recipe_prep_time": 15,
        "recipe_cook_time": 20,
        "recipe_calories": 320,
        "recipe_ingredients": ["2 cups flour", "2 eggs", "1 cup milk", "1 apple diced", "2 tsp cinnamon", "Maple syrup"],
        "recipe_instructions": ["Mix dry ingredients", "Add eggs and milk", "Fold in apple pieces", "Cook on griddle", "Serve with maple syrup"],
        "recipe_tags": ["Breakfast", "Pancakes", "Fall"],
        "basic_ingredients": "flour, eggs, milk, apple",
        "recipe_is_trending": False,
        "recipe_is_seasonal": True,
    },
    {
        "recipe_name": "Grilled Salmon Teriyaki",
        "recipe_description": "Perfectly grilled salmon glazed with homemade teriyaki sauce.",
        "recipe_image_url": "https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=400",
        "recipe_servings_count": 2,
        "recipe_prep_time": 10,
        "recipe_cook_time": 15,
        "recipe_calories": 420,
        "recipe_ingredients": ["2 salmon fillets", "4 tbsp soy sauce", "2 tbsp mirin", "1 tbsp honey", "Sesame seeds", "Green onions"],
        "recipe_instructions": ["Mix soy sauce, mirin, honey for glaze", "Season salmon with salt", "Grill salmon skin-side down", "Brush with teriyaki glaze", "Garnish with sesame and onions"],
        "recipe_tags": ["Japanese", "Seafood", "Healthy"],
        "basic_ingredients": "salmon, soy sauce, honey",
        "recipe_is_trending": True,
        "recipe_is_seasonal": False,
    },
]


def seed_chefs():
    """Create new chef users using Supabase Auth REST API."""
    print("\n🧑‍🍳 Creating new chefs...")
    chef_ids = []
    
    # Get Supabase URL and service role key for REST API
    import requests
    from supabase_client import SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
    
    auth_url = f"{SUPABASE_URL}/auth/v1/admin/users"
    headers = {
        "apikey": SUPABASE_SERVICE_ROLE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_ROLE_KEY}",
        "Content-Type": "application/json"
    }
    
    for chef_data in SAMPLE_CHEFS:
        email = chef_data["user_email"]
        
        # Check if user already exists in public.users
        existing = supabase_admin.table("users").select("user_id").eq("user_email", email).execute()
        
        if existing.data:
            user_id = existing.data[0]["user_id"]
            print(f"  ⚠️ {chef_data['user_full_name']} already exists, updating...")
            # Update existing user
            update_data = {
                "user_is_chef": True,
                "user_is_on_fire": chef_data["user_is_on_fire"],
                "user_bio": chef_data["user_bio"],
                "user_story": chef_data["user_story"],
                "user_specialties": chef_data["user_specialties"],
                "user_avatar": chef_data["user_avatar"],
            }
            supabase_admin.table("users").update(update_data).eq("user_id", user_id).execute()
        else:
            # Create auth user via REST API
            create_payload = {
                "email": email,
                "password": "ChefKit123!",
                "email_confirm": True,
                "user_metadata": {"full_name": chef_data["user_full_name"]}
            }
            
            resp = requests.post(auth_url, headers=headers, json=create_payload)
            
            if resp.status_code == 200 or resp.status_code == 201:
                user_id = resp.json()["id"]
                
                # Insert into public.users
                user_record = {
                    "user_id": user_id,
                    "user_email": email,
                    "user_full_name": chef_data["user_full_name"],
                    "user_is_chef": True,
                    "user_is_on_fire": chef_data["user_is_on_fire"],
                    "user_bio": chef_data["user_bio"],
                    "user_story": chef_data["user_story"],
                    "user_specialties": chef_data["user_specialties"],
                    "user_avatar": chef_data["user_avatar"],
                }
                supabase_admin.table("users").insert(user_record).execute()
                status = "🔥" if chef_data["user_is_on_fire"] else "👨‍🍳"
                print(f"  {status} Created: {chef_data['user_full_name']} ({email})")
            else:
                print(f"  ❌ Failed to create {email}: {resp.status_code} - {resp.text}")
                continue
        
        chef_ids.append(user_id)
    
    return chef_ids


def seed_recipes(chef_ids):
    """Create sample recipes owned by chefs."""
    print("\n🍳 Seeding recipes...")
    
    for i, recipe_data in enumerate(SAMPLE_RECIPES):
        # Assign recipe to a chef (cycle through available chefs)
        recipe_owner = chef_ids[i % len(chef_ids)]
        recipe_data["recipe_owner"] = recipe_owner
        
        # Check if recipe already exists
        existing = supabase_admin.table("recipe").select("recipe_id").eq("recipe_name", recipe_data["recipe_name"]).execute()
        
        if existing.data:
            # Update existing recipe
            recipe_id = existing.data[0]["recipe_id"]
            supabase_admin.table("recipe").update(recipe_data).eq("recipe_id", recipe_id).execute()
            print(f"  ✓ Updated: {recipe_data['recipe_name']}")
        else:
            # Insert new recipe
            supabase_admin.table("recipe").insert(recipe_data).execute()
            print(f"  ✓ Created: {recipe_data['recipe_name']}")


def main():
    print("=" * 50)
    print("Chef-Kit Database Seeder")
    print("=" * 50)
    
    try:
        chef_ids = seed_chefs()
        seed_recipes(chef_ids)
        
        print("\n" + "=" * 50)
        print("✅ Seeding complete!")
        print(f"   - {len(SAMPLE_CHEFS)} chefs")
        print(f"   - {len(SAMPLE_RECIPES)} recipes")
        print("=" * 50)
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
