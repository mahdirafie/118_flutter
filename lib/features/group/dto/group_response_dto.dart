class GroupResponseDTO {
  final String message;
  final String userType;
  final List<GroupDTO> groups;

  GroupResponseDTO({
    required this.message,
    required this.userType,
    required this.groups,
  });

  factory GroupResponseDTO.fromJson(Map<String, dynamic> json) {
    return GroupResponseDTO(
      message: json['message'],
      userType: json['user_type'],
      groups:
          (json['groups'] as List).map((e) => GroupDTO.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user_type': userType,
      'groups': groups.map((e) => e.toJson()).toList(),
    };
  }
}

class GroupDTO {
  final int gid;
  final String gname;
  final DateTime createdAt;

  GroupDTO({required this.gid, required this.gname, required this.createdAt});

  factory GroupDTO.fromJson(Map<String, dynamic> json) {
    return GroupDTO(
      gid: json['gid'],
      gname: json['gname'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gid': gid,
      'gname': gname,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
