part of 'filter_bloc.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();
}

class FilterLoadEvent extends FilterEvent {
  @override
  List<Object> get props => [];
}

class FilterFacultyChangedEvent extends FilterEvent {
  final Faculty? faculty;

  const FilterFacultyChangedEvent({required this.faculty});

  @override
  List<Object?> get props => [faculty];
}

class FilterDepartmentChangedEvent extends FilterEvent {
  final Department? department;

  const FilterDepartmentChangedEvent({required this.department});

  @override
  List<Object?> get props => [department];
}

class FilterWorkAreaChangedEvent extends FilterEvent {
  final String workArea;

  const FilterWorkAreaChangedEvent({required this.workArea});

  @override
  List<Object> get props => [workArea];
}

class FilterClearEvent extends FilterEvent {
  @override
  List<Object> get props => [];
}

class FilterClearFacultyEvent extends FilterEvent {
  @override
  List<Object> get props => [];
}

class FilterClearDepartmentEvent extends FilterEvent {
  @override
  List<Object> get props => [];
}

class FilterClearWorkAreaEvent extends FilterEvent {
  @override
  List<Object> get props => [];
}