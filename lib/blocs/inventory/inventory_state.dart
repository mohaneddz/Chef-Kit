import 'package:equatable/equatable.dart';

class InventoryState extends Equatable {
  final List<Map<String, String>> available;
  final List<Map<String, String>> browse;
  final bool showMore;
  final String searchTerm;

  const InventoryState({
    required this.available,
    required this.browse,
    required this.showMore,
    this.searchTerm = '',
  });

  InventoryState copyWith({
    List<Map<String, String>>? available,
    List<Map<String, String>>? browse,
    bool? showMore,
    String? searchTerm,
  }) {
    return InventoryState(
      available: available ?? this.available,
      browse: browse ?? this.browse,
      showMore: showMore ?? this.showMore,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  @override
  List<Object?> get props => [available, browse, showMore, searchTerm];
}