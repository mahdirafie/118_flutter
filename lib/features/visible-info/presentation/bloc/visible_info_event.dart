part of 'visible_info_bloc.dart';

sealed class VisibleInfoEvent extends Equatable {
  const VisibleInfoEvent();

  @override
  List<Object> get props => [];
}

final class GetVisibleInfoEvent extends VisibleInfoEvent {
  final int empId;

  const GetVisibleInfoEvent({required this.empId});
}