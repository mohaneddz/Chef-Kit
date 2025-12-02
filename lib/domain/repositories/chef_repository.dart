import 'dart:async';
import '../models/chef.dart';
import '../models/recipe.dart';
import 'recipe_repository.dart';

class ChefRepository {
  final List<Chef> _chefs = [
    Chef(id: 'c1', name: 'G. Ramsay', imageUrl: 'assets/images/chefs/chef_1.png', isOnFire: true),
    Chef(id: 'c2', name: 'Jamie Oliver', imageUrl: 'assets/images/chefs/chef_2.png'),
    Chef(id: 'c3', name: 'M. Bottura', imageUrl: 'assets/images/chefs/chef_3.png'),
    Chef(id: 'c4', name: 'A. Ducasse', imageUrl: 'assets/images/chefs/chef_3.png'),
    Chef(id: 'c5', name: 'J. Robuchon', imageUrl: 'assets/images/chefs/chef_1.png'),
    Chef(id: 'c6', name: 'T. Keller', imageUrl: 'assets/images/chefs/chef_2.png'),
  ];

  Future<List<Chef>> fetchAllChefs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.of(_chefs);
  }

  Future<Chef?> getChefById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _chefs.firstWhere((c) => c.id == id, orElse: () => Chef(id: 'na', name: 'Unknown', imageUrl: 'assets/images/chef.png'));
  }

  Future<Chef> toggleFollow(String id) async {
    final index = _chefs.indexWhere((c) => c.id == id);
    if (index == -1) throw Exception('Chef not found');
    final updated = _chefs[index].copyWith(isFollowed: !_chefs[index].isFollowed);
    _chefs[index] = updated;
    return updated;
  }

  Future<List<Chef>> fetchChefsOnFire() async {
    final all = await fetchAllChefs();
    return all.where((c) => c.isOnFire).toList();
  }
}
