import '../../domain/models/chef.dart';

class ChefsState {
  final bool loading;
  final List<Chef> allChefs;
  final List<Chef> superHotChefs;
  final int currentPage;
  final int chefsPerPage;
  final String? error;

  ChefsState({
    this.loading = false,
    this.allChefs = const [],
    this.superHotChefs = const [],
    this.currentPage = 1,
    this.chefsPerPage = 9,
    this.error,
  });

  ChefsState copyWith({
    bool? loading,
    List<Chef>? allChefs,
    List<Chef>? superHotChefs,
    int? currentPage,
    int? chefsPerPage,
    String? error,
  }) => ChefsState(
    loading: loading ?? this.loading,
    allChefs: allChefs ?? this.allChefs,
    superHotChefs: superHotChefs ?? this.superHotChefs,
    currentPage: currentPage ?? this.currentPage,
    chefsPerPage: chefsPerPage ?? this.chefsPerPage,
    error: error,
  );

  int get totalPages => (allChefs.where((c) => !c.isOnFire).length / chefsPerPage).ceil();
  List<Chef> get displayedChefs {
    final regular = allChefs.where((c) => !c.isOnFire).toList();
    final startIndex = (currentPage - 1) * chefsPerPage;
    final endIndex = (startIndex + chefsPerPage).clamp(0, regular.length);
    return regular.sublist(startIndex, endIndex);
  }
}
