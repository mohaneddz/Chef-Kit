import 'package:chefkit/common/supabase_client.dart';
import 'package:supabase/supabase.dart';

import 'ingredient_repo.dart';

class IngredientsSupabaseRepo extends IngredientsRepo {
  final SupabaseClient _client = SupabaseManager.client;

  @override
  Future<List<Map<String, dynamic>>> getAllIngredients() async {
    dynamic data;
    try {
      data = await _client
          .from('ingredients')
          .select()
          .order('ingredient_name_en', ascending: true);
    } on PostgrestException catch (e) {
      throw Exception('Supabase ingredients error: ${e.message}');
    }

    if (data is! List) return [];

    return data.map<Map<String, dynamic>>((row) {
      if (row is! Map) return <String, dynamic>{};

      String pick(dynamic value) => value?.toString() ?? '';

      final imageUrl = row['ingredient_image_url'] ?? row['image_path'];
      final typeEn = row['ingredient_type_en'] ?? row['type_en'] ?? row['ingredient_category'];
      return {
        'id': row['ingredient_id'] ?? row['id'],
        'name_en': pick(row['ingredient_name_en'] ?? row['name_en'] ?? row['ingredient_name']),
        'name_fr': pick(row['ingredient_name_fr'] ?? row['name_fr']),
        'name_ar': pick(row['ingredient_name_ar'] ?? row['name_ar']),
        'type_en': pick(typeEn),
        'type_fr': pick(row['ingredient_type_fr'] ?? row['type_fr']),
        'type_ar': pick(row['ingredient_type_ar'] ?? row['type_ar']),
        'image_path': pick(imageUrl),
      };
    }).toList();
  }

  @override
  Future<void> insertIngredient(Map<String, dynamic> data) {
    // Not used in Supabase flow; keep interface for compatibility.
    throw UnimplementedError('insertIngredient is not supported for Supabase repo.');
  }
}

