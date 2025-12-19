import 'package:basu_118/core/auth_service/auth_service.dart';
import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/favorites/domain/favorite_repository.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_dto.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_favorites_dto.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final ApiService api;

  FavoriteRepositoryImpl({required this.api});
  @override
  Future<GetFavoriteCategoriesDTO> getFavoriteCategories() async{
    final response = await api.post('/favorite/user/get-fav-cats', {
      "uid": AuthService().userInfo?.uid
    });

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
      'user_id': AuthService().userInfo?.uid,
      'category_title': categoryTitle
    });
  }
  
  @override
  Future<void> deleteFavoriteCategory(int categoryId) async{
    await api.delete('/favorite/delete-cat',data:  {
      'favcat_id': categoryId
    });
  }
  
    @override
  Future<void> updateFavoriteCategory(int categoryId, String newCategoryTitle) async{
    await api.put('/favorite/update-cat', {
      'favcat_id': categoryId,
      'new_title': newCategoryTitle
    });
  }
  
  @override
  Future<void> deleteFromFavorites(int cid, int uid) async{
    await api.delete('/favorite/del-fav', data: {
      'cid': cid,
      'uid': uid
    });
  }

  @override
  Future<FavoriteCategoryFavoritesDTO> getFavCatFavorites(int favCatId, int userId)async {
    final response = await api.get('/favorite/get-favcat-favs/$userId/$favCatId');
    return FavoriteCategoryFavoritesDTO.fromJson(response.data);
  }
}