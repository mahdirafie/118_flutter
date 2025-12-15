// search_event.dart
part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class SearchStarted extends SearchEvent {
  final String query;
  final int? facultyId;
  final int? departmentId;
  final String? workArea;

  const SearchStarted({
    required this.query,
    this.facultyId,
    this.departmentId,
    this.workArea,
  });

  @override
  List<Object> get props => [
        query,
        facultyId ?? 0,
        departmentId ?? 0,
        workArea ?? '',
      ];
}

final class SearchReset extends SearchEvent {}