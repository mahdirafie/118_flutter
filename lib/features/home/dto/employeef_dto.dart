
import 'package:basu_118/features/home/dto/post_dto.dart';
import 'package:basu_118/features/home/dto/space_dto.dart';

class EmployeeFDTO {
  final bool success;
  final String role;
  final List<Section> data;

  EmployeeFDTO({
    required this.success,
    required this.role,
    required this.data,
  });

  factory EmployeeFDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeFDTO(
      success: json['success'] as bool,
      role: json['role'] as String,
      data: (json['data'] as List)
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'role': role,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class Section {
  final String title;
  final Map<String, Department>? departments;
  final List<PostItem>? posts;
  final List<SpaceItem>? spaces;

  Section({
    required this.title,
    this.departments,
    this.posts,
    this.spaces,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    final deptMap = json['departments'] != null
        ? (json['departments'] as Map<String, dynamic>).map(
            (k, v) =>
                MapEntry(k, Department.fromJson(v as Map<String, dynamic>)),
          )
        : null;

    return Section(
      title: json['title'] as String,
      departments: deptMap,
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
        if (departments != null)
          'departments': departments!
              .map((key, value) => MapEntry(key, value.toJson())),
        if (posts != null) 'posts': posts!.map((e) => e.toJson()).toList(),
        if (spaces != null) 'spaces': spaces!.map((e) => e.toJson()).toList(),
      };
}

class Department {
  final String title;
  final List<Employee> employees;

  Department({
    required this.title,
    required this.employees,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      title: json['title'] as String,
      employees: (json['employees'] as List)
          .map((e) => Employee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'employees': employees.map((e) => e.toJson()).toList(),
      };
}

class Employee {
  final int empId;
  final String name;
  final int cid;

  Employee({
    required this.empId,
    required this.name,
    required this.cid,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
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