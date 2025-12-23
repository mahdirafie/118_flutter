import 'package:basu_118/features/favorites/domain/favorite_repository.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_dto.dart';
import 'package:basu_118/features/favorites/dto/favorite_category_favorites_dto.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorite_event.dart';
part 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository repo;
  FavoriteBloc(this.repo) : super(FavoriteCategoryInitial()) {
    on<GetFavoriteCategories>((event, emit) async {
      try {
        emit(FavoriteCategoryLoading());
        final response = await repo.getFavoriteCategories();
        emit(FavoriteCategorySuccess(response: response));
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(FavoriteCategoryFailure(message: userMessage));
      } catch (e) {
        emit(FavoriteCategoryFailure(message: e.toString()));
      }
    });

    on<CreateFavoriteCategory>((event, emit) async {
      try {
        emit(CreateFavoriteCategoryLoading());
        await repo.createFavoriteCategory(event.categoryTitle);
        emit(
          CreateFavoriteCategorySuccess(
            message: 'دسته بندی با موفقیت اضافه شد!',
          ),
        );
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(CreateFavoriteCategoryFailure(message: userMessage));
      } catch (e) {
        emit(CreateFavoriteCategoryFailure(message: e.toString()));
      }
    });

    on<DeleteFavoriteCategory>((event, emit) async {
      try {
        emit(DeleteFavoriteCategoryLoading());
        await repo.deleteFavoriteCategory(event.favCatId);
        emit(
          DeleteFavoriteCategorySuccess(
            message: 'حذف دسته بندی با موفقیت انجام شد!',
          ),
        );
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(DeleteFavoriteCategoryFailure(message: userMessage));
      } catch (e) {
        emit(DeleteFavoriteCategoryFailure(message: e.toString()));
      }
    });

    on<UpdateFavoriteCategory>((event, emit) async {
      try {
        emit(UpdateFavoriteCategoryLoading());
        await repo.updateFavoriteCategory(event.favCatId, event.newTitle);
        emit(UpdateFavoriteCategorySuccess(message: 'دسته بندی با موفقیت ویرایش شد!'));
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }

        emit(UpdateFavoriteCategoryFailure(message: userMessage));
      } catch (e) {
        emit(UpdateFavoriteCategoryFailure(message: e.toString()));
      }
    });

    on<AddToFavorites>((event, emit) async {
      try {
        emit(AddToFavoritesLoading());
        print(event.cid);
        print(event.favcatIds.toString());
        await repo.addToFavoritesToCats(event.cid, event.favcatIds);
        emit(AddToFavoritesSuccess());
      } on DioException catch (e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(AddToFavoritesFailure(message: userMessage));
      } catch (e) {
        emit(AddToFavoritesFailure(message: e.toString()));
      }
    });

    on<DeleteFromFavorites>((event, emit) async{
      try {
        emit(DeleteFromFavoritesLoading());
        await repo.deleteFromFavorites(event.cid);
        emit(DeleteFromFavoritesSuccess());
      } on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(DeleteFromFavoritesFailure(message: userMessage));
      }catch(e) {
        emit(DeleteFromFavoritesFailure(message: e.toString()));
      }
    });

    on<GetFavoriteCategoryFavorites>((event, emit)async {
      try {
        emit(GetFavoriteCategoryFavoritesLoading());
        final response = await repo.getFavCatFavorites(event.favcatId);
        emit(GetFavoriteCategoryFavoritesSuccess(response: response));
      }on DioException catch(e) {
        String userMessage = 'خطایی رخ داد';

        if (e.response?.data is Map &&
            (e.response!.data as Map).containsKey('message')) {
          userMessage = e.response!.data['message'];
        }
        emit(GetFavoriteCategoryFavoritesFailure(message: userMessage));
      } catch(e) {
        emit(GetFavoriteCategoryFavoritesFailure(message: e.toString()));
      }
    });
  }
}
