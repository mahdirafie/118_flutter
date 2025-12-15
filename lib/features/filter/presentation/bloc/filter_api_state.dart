part of 'filter_api_bloc.dart';

sealed class FilterApiState extends Equatable {
  const FilterApiState();
  
  @override
  List<Object> get props => [];
}

final class GetAllFacultiesInitial extends FilterApiState {}
final class GetAllFacultiesLoading extends FilterApiState {}
final class GetAllFacultiesFailure extends FilterApiState {
  final String message;

  const GetAllFacultiesFailure({required this.message});
}
final class GetAllFacultiesSuccess extends FilterApiState {
  final FacultiesResponse response;

  const GetAllFacultiesSuccess({required this.response});
}

final class GetAllFacultyDepartmentsLoading extends FilterApiState {}
final class GetAllFacultyDepartmentsFailure extends FilterApiState {
  final String message;

  const GetAllFacultyDepartmentsFailure({required this.message});
}
final class GetAllFacultyDepartmentsSuccess extends FilterApiState {
  final DepartmentsResponse response;

  const GetAllFacultyDepartmentsSuccess({required this.response});
}

final class GetAllWorkareasLoading extends FilterApiState {}
final class GetAllWorkareasFailure extends FilterApiState {
  final String message;

  const GetAllWorkareasFailure({required this.message});
}
final class GetAllWorkareasSuccess extends FilterApiState {
  final WorkAreasResponse response;

  const GetAllWorkareasSuccess({required this.response});
}