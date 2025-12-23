part of 'search_history_bloc.dart';

sealed class SearchHistoryEvent extends Equatable {
  const SearchHistoryEvent();

  @override
  List<Object> get props => [];
}

final class GetSearchHistoryStarted extends SearchHistoryEvent {}

final class DeleteSearchHistory extends SearchHistoryEvent {
  final int shId;

  const DeleteSearchHistory({required this.shId});
}

final class CreateSearchHistory extends SearchHistoryEvent {
  final String query;

  const CreateSearchHistory({required this.query});
}
