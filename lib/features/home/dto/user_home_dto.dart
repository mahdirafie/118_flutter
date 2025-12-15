import 'package:basu_118/features/home/dto/post_dto.dart';
import 'package:basu_118/features/home/dto/space_dto.dart';

class UserHomeDTO {
  final bool success;
  final String role;
  final List<UserHomeSection> data;

  UserHomeDTO({
    required this.success,
    required this.role,
    required this.data,
  });

  factory UserHomeDTO.fromJson(Map<String, dynamic> json) => UserHomeDTO(
        success: json['success'] as bool,
        role: json['role'] as String,
        data: (json['data'] as List)
            .map((e) => UserHomeSection.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'role': role,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class UserHomeSection {
  final String title;
  final List<EmployeeItem>? employees;
  final List<PostItem>? posts;
  final List<SpaceItem>? spaces;

  UserHomeSection({
    required this.title,
    this.employees,
    this.posts,
    this.spaces,
  });

  factory UserHomeSection.fromJson(Map<String, dynamic> json) {
    return UserHomeSection(
      title: json['title'] as String,
      employees: json['employees'] != null
          ? (json['employees'] as List)
              .map((e) => EmployeeItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      posts: json['posts'] != null
          ? (json['posts'] as List)
              .map((e) => PostItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      spaces: json['spaces'] != null
          ? (json['spaces'] as List)
              .map((e) => SpaceItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        if (employees != null)
          'employees': employees!.map((e) => e.toJson()).toList(),
        if (posts != null) 'posts': posts!.map((e) => e.toJson()).toList(),
        if (spaces != null) 'spaces': spaces!.map((e) => e.toJson()).toList(),
      };
}

class EmployeeItem {
  final int empId;
  final String name;
  final int cid;

  EmployeeItem({
    required this.empId,
    required this.name,
    required this.cid,
  });

  factory EmployeeItem.fromJson(Map<String, dynamic> json) => EmployeeItem(
        empId: json['emp_id'] as int,
        name: json['name'] as String,
        cid: json['cid'] as int,
      );

  Map<String, dynamic> toJson() => {
        'emp_id': empId,
        'name': name,
        'cid': cid,
      };
}