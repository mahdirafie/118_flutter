class GroupMembersResponseDTO {
  final String message;
  final GroupGroupMember group;

  GroupMembersResponseDTO({required this.message, required this.group});

  factory GroupMembersResponseDTO.fromJson(Map<String, dynamic> json) {
    return GroupMembersResponseDTO(
      message: json['message'],
      group: GroupGroupMember.fromJson(json['group']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'message': message, 'group': group.toJson()};
  }
}

class GroupGroupMember {
  final int groupId;
  final String groupName;
  final List<MemberGroupMember> members;

  GroupGroupMember({
    required this.groupId,
    required this.groupName,
    required this.members,
  });

  factory GroupGroupMember.fromJson(Map<String, dynamic> json) {
    return GroupGroupMember(
      groupId: json['group_id'],
      groupName: json['group_name'],
      members:
          (json['members'] as List)
              .map((e) => MemberGroupMember.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'group_name': groupName,
      'members': members.map((e) => e.toJson()).toList(),
    };
  }
}

class MemberGroupMember {
  final int empId;
  final int cId;
  final UserGroupMember user;

  MemberGroupMember({required this.empId, required this.user, required this.cId});

  factory MemberGroupMember.fromJson(Map<String, dynamic> json) {
    return MemberGroupMember(
      empId: json['emp_id'],
      cId: json['cid'],
      user: UserGroupMember.fromJson(json['User']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'emp_id': empId, 'User': user.toJson()};
  }
}

class UserGroupMember {
  final String fullName;

  UserGroupMember({required this.fullName});

  factory UserGroupMember.fromJson(Map<String, dynamic> json) {
    return UserGroupMember(fullName: json['full_name']);
  }

  Map<String, dynamic> toJson() {
    return {'full_name': fullName};
  }
}
