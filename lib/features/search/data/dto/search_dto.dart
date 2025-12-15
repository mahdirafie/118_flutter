class SearchResponseDTO {
  final EmployeesSearch employees;
  final List<PostSearch> posts;
  final List<SpaceSearch> spaces;

  SearchResponseDTO({
    required this.employees,
    required this.posts,
    required this.spaces,
  });

  factory SearchResponseDTO.fromJson(Map<String, dynamic> json) {
    return SearchResponseDTO(
      employees: EmployeesSearch.fromJson(json['employees']),
      posts:
          (json['posts'] as List).map((e) => PostSearch.fromJson(e)).toList(),
      spaces:
          (json['spaces'] as List).map((e) => SpaceSearch.fromJson(e)).toList(),
    );
  }
}

/* ===================== Employees ===================== */

class EmployeesSearch {
  final List<EmployeeSearch> employeeF;
  final List<EmployeeSearch> employeeNF;

  EmployeesSearch({required this.employeeF, required this.employeeNF});

  factory EmployeesSearch.fromJson(Map<String, dynamic> json) {
    return EmployeesSearch(
      employeeF:
          (json['employeeF'] as List)
              .map((e) => EmployeeSearch.fromJson(e))
              .toList(),
      employeeNF:
          (json['employeeNF'] as List)
              .map((e) => EmployeeSearch.fromJson(e))
              .toList(),
    );
  }
}

class EmployeeSearch {
  final int empId;
  final int uid;
  final int cid;
  final UserSearch user;

  EmployeeSearch({
    required this.empId,
    required this.uid,
    required this.cid,
    required this.user,
  });

  factory EmployeeSearch.fromJson(Map<String, dynamic> json) {
    return EmployeeSearch(
      empId: json['emp_id'],
      uid: json['uid'],
      cid: json['cid'],
      user: UserSearch.fromJson(json['User']),
    );
  }
}

class UserSearch {
  final String fullName;
  final String phone;

  UserSearch({required this.fullName, required this.phone});

  factory UserSearch.fromJson(Map<String, dynamic> json) {
    return UserSearch(fullName: json['full_name'], phone: json['phone']);
  }
}

/* ===================== Posts ===================== */

class PostSearch {
  final String pname;
  final String description;
  final int cid;

  PostSearch({
    required this.pname,
    required this.description,
    required this.cid,
  });

  factory PostSearch.fromJson(Map<String, dynamic> json) {
    return PostSearch(
      pname: json['pname'],
      description: json['description'],
      cid: json['cid'],
    );
  }
}

/* ===================== Spaces ===================== */

class SpaceSearch {
  final String sname;
  final String room;
  final int cid;

  SpaceSearch({required this.sname, required this.room, required this.cid});

  factory SpaceSearch.fromJson(Map<String, dynamic> json) {
    return SpaceSearch(
      sname: json['sname'],
      room: json['room'],
      cid: json['cid'],
    );
  }
}
