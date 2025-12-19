part of 'favorite_bloc.dart';

sealed class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

final class GetFavoriteCategories extends FavoriteEvent {}
final class CreateFavoriteCategory extends FavoriteEvent {
  final String categoryTitle;

  const CreateFavoriteCategory({required this.categoryTitle});
}
final class DeleteFavoriteCategory extends FavoriteEvent {
  final int favCatId;

  const DeleteFavoriteCategory({required this.favCatId});
}
final class UpdateFavoriteCategory extends FavoriteEvent {
  final int favCatId;
  final String newTitle;

  const UpdateFavoriteCategory({required this.favCatId, required this.newTitle});
}

final class AddToFavorites extends FavoriteEvent {
  final int cid;
  final List<int> favcatIds;
  const AddToFavorites(this.cid, this.favcatIds);
}

final class DeleteFromFavorites extends FavoriteEvent {
  final int cid;
  final int uid;

  const DeleteFromFavorites({required this.cid, required this.uid});
}

final class GetFavoriteCategoryFavorites extends FavoriteEvent {
  final int favcatId;
  final int userId;

  const GetFavoriteCategoryFavorites({required this.favcatId, required this.userId});
}