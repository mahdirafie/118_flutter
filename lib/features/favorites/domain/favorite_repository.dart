import 'package:basu_118/features/favorites/dto/favorite_category_dto.dart';

abstract class FavoriteRepository {
  Future<GetFavoriteCategoriesDTO> getFavoriteCategories();
  Future<void> createFavoriteCategory(String categoryTitle);
  Future<void> deleteFavoriteCategory(int categoryId);
  Future<void> updateFavoriteCategory(int categoryId, String newCategoryTitle);
  Future<void> addToFavorites(int cid, List<int> favcatIds);
}