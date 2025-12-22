import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/group/domain/group_repository.dart';
import 'package:basu_118/features/group/dto/group_members_response_dto.dart';
import 'package:basu_118/features/group/dto/group_response_dto.dart';

class GroupRepositoryImpl implements GroupRepository {
  final ApiService api;

  GroupRepositoryImpl({required this.api});
  @override
  Future<GroupResponseDTO> getGroups(int userId) async{
    final response = await api.get('/group/get-emp-groups/$userId');
    return GroupResponseDTO.fromJson(response.data);
  }
  
  @override
  Future<void> createGroup(int userId, String groupName, String? template) async {
    await api.post('/group/create', {
      'uid': userId,
      'gname': groupName,
      'template': template
    });
  }
  
  @override
  Future<void> deleteGroup(int groupId) async{
    await api.delete('/group/delete/$groupId');
  }

  @override
  Future<GroupMembersResponseDTO> getGroupMembers(int groupId) async{
    final response = await api.get('/group/get-group-members/$groupId');
    return GroupMembersResponseDTO.fromJson(response.data);
  }
  
  @override
  Future<void> removeGroupMember(int groupId, int empId) async{
    await api.delete('/group/remove-member/$groupId/$empId');
  }
  
  @override
  Future<void> addEmployeeToGroup(int groupId, int empId) async{
    await api.post('/group/add-member', {
      'gid': groupId,
      'emp_id': empId
    });
  }
}