part of 'group_member_bloc.dart';

sealed class GroupMemberState extends Equatable {
  const GroupMemberState();
  
  @override
  List<Object> get props => [];
}

final class GetGroupMembersInitial extends GroupMemberState {}
final class GetGroupMembersLoading extends GroupMemberState {}
final class GetGroupMembersFailure extends GroupMemberState {
  final String message;

  const GetGroupMembersFailure({required this.message});
}
final class GetGroupMembersSuccess extends GroupMemberState {
  final GroupMembersResponseDTO response;

  const GetGroupMembersSuccess({required this.response});
}

final class DeleteGroupMemberLoading extends GroupMemberState {}
final class DeleteGroupmemberFailure extends GroupMemberState {
  final String message;

  const DeleteGroupmemberFailure({required this.message});
}
final class DeleteGroupMemberSuccess extends GroupMemberState {
  final String message;

  const DeleteGroupMemberSuccess({required this.message});
}

final class AddToGroupLoading extends GroupMemberState {}
final class AddToGroupFailure extends GroupMemberState {
  final String message;

  const AddToGroupFailure({required this.message});
}
final class AddToGroupSuccess extends GroupMemberState {
  final String message;

  const AddToGroupSuccess({required this.message});
}