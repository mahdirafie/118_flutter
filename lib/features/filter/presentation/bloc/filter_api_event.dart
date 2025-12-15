part of 'filter_api_bloc.dart';

sealed class FilterApiEvent extends Equatable {
  const FilterApiEvent();

  @override
  List<Object> get props => [];
}

final class GetAllFaculties extends FilterApiEvent {}
final class GetAllFacultyDepartments extends FilterApiEvent {
  final int facultyId;

  const GetAllFacultyDepartments({required this.facultyId});
}
final class GetAllWorkareas extends FilterApiEvent {}