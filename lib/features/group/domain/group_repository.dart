import 'package:basu_118/features/group/dto/group_members_response_dto.dart';
import 'package:basu_118/features/group/dto/group_response_dto.dart';

abstract class GroupRepository {
  Future<GroupResponseDTO> getGroups();
  Future<void> createGroup(String groupName, String? template);
  Future<void> deleteGroup(int groupId);
  Future<GroupMembersResponseDTO> getGroupMembers(int groupId);
  Future<void> removeGroupMember(int groupId, int empId);
  Future<void> addEmployeeToGroup(int groupId, int empId);
}