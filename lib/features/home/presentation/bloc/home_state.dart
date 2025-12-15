part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

final class RelativeInfoInitial extends HomeState {}
final class RelativeInfoLoading extends HomeState {}
final class RelativeInfoSuccess extends HomeState {
  final UserHomeDTO? userhome;
  final EmployeeFDTO? empf;
  final EmployeeNDTO? empn;

  const RelativeInfoSuccess({this.empf, this.empn, this.userhome});
}
final class RelativeInfoFailure extends HomeState {
  final String message;

  const RelativeInfoFailure({required this.message});
}