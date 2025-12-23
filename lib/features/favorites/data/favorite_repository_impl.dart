import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/favorites/domain/favorite_repository.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_dto.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_favorites_dto.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final ApiService api;

  FavoriteRepositoryImpl({required this.api});
  @override
  Future<GetFavoriteCategoriesDTO> getFavoriteCategories() async{
    final response = await api.get('/favorite/user/get-fav-cats');

    return GetFavoriteCategoriesDTO.fromJson(response.data);
  }
  
  @override
  Future<void> addToFavoritesToCats(int cid, List<int> favcatIds) async{
    for(var favcatId in favcatIds){
      await api.post('/favorite/add-fav', {
        'cid': cid,
        'favcat_id': favcatId,
      });
    }
  }
  
  @override
  Future<void> createFavoriteCategory(String categoryTitle) async{
    await api.post('/favorite/add-fav-cat', {
      'category_title': categoryTitle
    });
  }
  
  @override
  Future<void> deleteFavoriteCategory(int categoryId) async{
    await api.delete('/favorite/delete-cat/$categoryId');
  }
  
    @override
  Future<void> updateFavoriteCategory(int categoryId, String newCategoryTitle) async{
    await api.put('/favorite/update-cat', {
      'favcat_id': categoryId,
      'new_title': newCategoryTitle
    });
  }
  
  @override
  Future<void> deleteFromFavorites(int cid) async{
    await api.delete('/favorite/del-fav/$cid');
  }

  @override
  Future<FavoriteCategoryFavoritesDTO> getFavCatFavorites(int favCatId)async {
    final response = await api.get('/favorite/get-favcat-favs/$favCatId');
    return FavoriteCategoryFavoritesDTO.fromJson(response.data);
  }
}