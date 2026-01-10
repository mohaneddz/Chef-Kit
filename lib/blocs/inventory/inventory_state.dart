import 'package:equatable/equatable.dart';

class InventoryState extends Equatable {
  final List<Map<String, String>> available;
  final List<Map<String, String>> browse;
  final bool showMore;
  final String searchTerm;
  final String currentLang;

  const InventoryState({
    required this.available,
    required this.browse,
    required this.showMore,
    this.searchTerm = '',
    this.currentLang = 'en',
  });

  InventoryState copyWith({
    List<Map<String, String>>? available,
    List<Map<String, String>>? browse,
    bool? showMore,
    String? searchTerm,
    String? currentLang,
  }) {
    return InventoryState(
      available: available ?? this.available,
      browse: browse ?? this.browse,
      showMore: showMore ?? this.showMore,
      searchTerm: searchTerm ?? this.searchTerm,
      currentLang: currentLang ?? this.currentLang,
    );
  }

  @override
  List<Object?> get props => [
    available,
    browse,
    showMore,
    searchTerm,
    currentLang,
  ];
}
