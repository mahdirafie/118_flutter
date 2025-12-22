part of 'group_member_bloc.dart';

sealed class GroupMemberEvent extends Equatable {
  const GroupMemberEvent();

  @override
  List<Object> get props => [];
}

final class GetGroupMembersEvent extends GroupMemberEvent {
  final int groupId;

  const GetGroupMembersEvent({required this.groupId});
}
final class DeleteGroupMemberEvent extends GroupMemberEvent {
  final int groupId;
  final int empId;

  const DeleteGroupMemberEvent({required this.groupId, required this.empId});
}
final class AddToGroupEvent extends GroupMemberEvent {
  final int groupId;
  final int empId;

  const AddToGroupEvent({required this.groupId, required this.empId});
}