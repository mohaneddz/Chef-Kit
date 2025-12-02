class Chef {
  final String id;
  final String name;
  final String imageUrl;
  final bool isOnFire;
  final bool isFollowed;

  Chef({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isOnFire = false,
    this.isFollowed = false,
  });

  Chef copyWith({
    String? id,
    String? name,
    String? imageUrl,
    bool? isOnFire,
    bool? isFollowed,
  }) {
    return Chef(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isOnFire: isOnFire ?? this.isOnFire,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
