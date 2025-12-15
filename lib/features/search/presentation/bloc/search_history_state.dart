part of 'search_history_bloc.dart';

sealed class SearchHistoryState extends Equatable {
  const SearchHistoryState();
  
  @override
  List<Object> get props => [];
}

final class GetSearchHistoryInitial extends SearchHistoryState {}
final class GetSearchHistoryLoading extends SearchHistoryState {}
final class GetSearchHistoryFailure extends SearchHistoryState {
  final String message;

  const GetSearchHistoryFailure({required this.message});
}
final class GetSearchHistorySuccess extends SearchHistoryState {
  final SearchHistoriesDTO response;

  const GetSearchHistorySuccess({required this.response});
}

final class DeleteSearchHistoryLoading extends SearchHistoryState {}
final class DeleteSearchHistoryFailure extends SearchHistoryState {
  final String message;

  const DeleteSearchHistoryFailure({required this.message});
}
final class DeleteSearchHistorySuccess extends SearchHistoryState {
  final String message;

  const DeleteSearchHistorySuccess({required this.message});
}

final class CreateSearchHistoryLoading extends SearchHistoryState {}
final class CreateSearchHistoryFailure extends SearchHistoryState {
  final String message;

  const CreateSearchHistoryFailure({required this.message});
}
final class CreateSearchHistorySuccess extends SearchHistoryState {
  final String message;

  const CreateSearchHistorySuccess({required this.message});
}