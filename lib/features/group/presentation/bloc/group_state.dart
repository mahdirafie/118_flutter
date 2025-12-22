part of 'group_bloc.dart';

sealed class GroupState extends Equatable {
  const GroupState();
  
  @override
  List<Object> get props => [];
}

final class GetGroupInitial extends GroupState {}
final class GetGroupLoading extends GroupState {}
final class GetGroupFailure extends GroupState {
  final String message;

  const GetGroupFailure({required this.message});
}
final class GetGroupSuccess extends GroupState {
  final GroupResponseDTO response;

  const GetGroupSuccess({required this.response});
}

final class CreateGroupLoading extends GroupState {}
final class CreateGroupFailure extends GroupState {
  final String message;

  const CreateGroupFailure({required this.message});
}
final class CreateGroupSuccess extends GroupState {
  final String message;

  const CreateGroupSuccess({required this.message});
}

final class DeleteGroupLoading extends GroupState {}
final class DeleteGroupFailure extends GroupState {
  final String message;

  const DeleteGroupFailure({required this.message});
}
final class DeleteGroupSuccess extends GroupState {
  final String message;

  const DeleteGroupSuccess({required this.message});
}