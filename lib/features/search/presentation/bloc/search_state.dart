part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();
  
  @override
  List<Object> get props => [];
}

final class SearchInitial extends SearchState {}
final class SearchLoading extends SearchState {}
final class SearchFailure extends SearchState {
  final String message;

  const SearchFailure({required this.message});
}
final class SearchSuccess extends SearchState {
  final SearchResponseDTO response;

  const SearchSuccess({required this.response});
}