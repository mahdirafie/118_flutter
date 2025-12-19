class FavoriteCategoryFavoritesDTO {
  final String message;
  final List<FavoriteItemFavCatFavs> favorites;

  const FavoriteCategoryFavoritesDTO({
    required this.message,
    required this.favorites,
  });

  factory FavoriteCategoryFavoritesDTO.fromJson(Map<String, dynamic> json) {
    return FavoriteCategoryFavoritesDTO(
      message: json['message'] as String,
      favorites:
          (json['favorites'] as List<dynamic>? ?? [])
              .map(
                (e) =>
                    FavoriteItemFavCatFavs.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

class FavoriteItemFavCatFavs {
  final int cid;
  final String type; // employee | post | space
  final String name;

  const FavoriteItemFavCatFavs({
    required this.cid,
    required this.type,
    required this.name,
  });

  factory FavoriteItemFavCatFavs.fromJson(Map<String, dynamic> json) {
    return FavoriteItemFavCatFavs(
      cid: json['cid'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
    );
  }
}
