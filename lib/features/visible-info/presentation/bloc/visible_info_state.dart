part of 'visible_info_bloc.dart';

sealed class VisibleInfoState extends Equatable {
  const VisibleInfoState();
  
  @override
  List<Object> get props => [];
}

final class VisibleInfoInitial extends VisibleInfoState {}
final class VisibleInfoLoading extends VisibleInfoState {}
final class VisibleInfoFailure extends VisibleInfoState {
  final String message;

  const VisibleInfoFailure({required this.message});
}
final class VisibleInfoSuccess extends VisibleInfoState {
  final EmployeeVisibleInfoDTO response;

  const VisibleInfoSuccess({required this.response});
}