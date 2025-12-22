part of 'group_bloc.dart';

sealed class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object> get props => [];
}

final class GetGroupsStarted extends GroupEvent {
  final int userId;

  const GetGroupsStarted({required this.userId});
}
final class CreateGroupEvent extends GroupEvent {
  final int userId;
  final String groupName;
  final String? template;

  const CreateGroupEvent({required this.userId, required this.groupName, this.template});
}
final class DeleteGroupEvent extends GroupEvent {
  final int groupId;

  const DeleteGroupEvent({required this.groupId});
}