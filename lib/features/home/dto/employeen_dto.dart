class EmployeeNDTO {
  final bool success;
  final String role;
  final List<ColleagueSection> data;

  EmployeeNDTO({
    required this.success,
    required this.role,
    required this.data,
  });

  factory EmployeeNDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeNDTO(
      success: json['success'] as bool,
      role: json['role'] as String,
      data: (json['data'] as List)
          .map((e) => ColleagueSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'role': role,
        'data': data.map((e) => e.toJson()).toList(),
      };
}

class ColleagueSection {
  final String title;
  final List<Colleague> colleagues;

  ColleagueSection({
    required this.title,
    required this.colleagues,
  });

  factory ColleagueSection.fromJson(Map<String, dynamic> json) {
    return ColleagueSection(
      title: json['title'] as String,
      colleagues: (json['colleagues'] as List)
          .map((e) => Colleague.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'colleagues': colleagues.map((e) => e.toJson()).toList(),
      };
}

class Colleague {
  final int empId;
  final String name;
  final int cid;

  Colleague({
    required this.empId,
    required this.name,
    required this.cid,
  });

  factory Colleague.fromJson(Map<String, dynamic> json) => Colleague(
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
