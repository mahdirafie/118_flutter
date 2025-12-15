part of 'favorite_bloc.dart';

sealed class FavoriteState extends Equatable {
  const FavoriteState();

  @override
  List<Object> get props => [];
}

// states for getting favorite categories for the user
final class FavoriteCategoryInitial extends FavoriteState {}
final class FavoriteCategoryLoading extends FavoriteState {}
final class FavoriteCategorySuccess extends FavoriteState {
  final GetFavoriteCategoriesDTO response;

  const FavoriteCategorySuccess({required this.response});
}
final class FavoriteCategoryFailure extends FavoriteState {
  final String message;

  const FavoriteCategoryFailure({required this.message});
}

// states for creating new favorite category
final class CreateFavoriteCategoryLoading extends FavoriteState {}
final class CreateFavoriteCategoryFailure extends FavoriteState {
  final String message;

  const CreateFavoriteCategoryFailure({required this.message});
}
final class CreateFavoriteCategorySuccess extends FavoriteState {
  final String message;

  const CreateFavoriteCategorySuccess({required this.message});
}

// states for deleting favorite category
final class DeleteFavoriteCategoryLoading extends FavoriteState {}
final class DeleteFavoriteCategoryFailure extends FavoriteState {
  final String message;

  const DeleteFavoriteCategoryFailure({required this.message});
}
final class DeleteFavoriteCategorySuccess extends FavoriteState {
  final String message;

  const DeleteFavoriteCategorySuccess({required this.message});
}

//states for updating favorite category
final class UpdateFavoriteCategoryLoading extends FavoriteState {}
final class UpdateFavoriteCategoryFailure extends FavoriteState {
  final String message;

  const UpdateFavoriteCategoryFailure({required this.message});
}
final class UpdateFavoriteCategorySuccess extends FavoriteState {
  final String message;

  const UpdateFavoriteCategorySuccess({required this.message});
}

// states for add to favorite
final class AddToFavoritesLoading extends FavoriteState {}
final class AddToFavoritesSuccess extends FavoriteState {}
final class AddToFavoritesFailure extends FavoriteState {
  final String message;

  const AddToFavoritesFailure({required this.message});
}

