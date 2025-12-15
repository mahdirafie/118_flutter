class GetFavoriteCategoriesDTO {
  String message;
  List<FavoriteCategories> favoriteCategories;

  GetFavoriteCategoriesDTO({required this.message, required this.favoriteCategories});

  GetFavoriteCategoriesDTO.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        favoriteCategories = (json['favorite_categories'] as List)
            .map((v) => FavoriteCategories.fromJson(v))
            .toList();

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'favorite_categories': favoriteCategories.map((v) => v.toJson()).toList(),
    };
  }
}

class FavoriteCategories {
  int favcatId;
  String title;
  String createdAt;

  FavoriteCategories({
    required this.favcatId,
    required this.title,
    required this.createdAt,
  });

  FavoriteCategories.fromJson(Map<String, dynamic> json)
      : favcatId = json['favcat_id'],
        title = json['title'],
        createdAt = json['createdAt'];

  Map<String, dynamic> toJson() {
    return {
      'favcat_id': favcatId,
      'title': title,
      'createdAt': createdAt,
    };
  }
}
