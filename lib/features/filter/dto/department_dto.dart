class DepartmentsResponse {
  final String message;
  final List<DepartmentModel> departments;

  DepartmentsResponse({
    required this.message,
    required this.departments,
  });

  factory DepartmentsResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentsResponse(
      message: json['message'],
      departments: (json['departments'] as List)
          .map((item) => DepartmentModel.fromJson(item))
          .toList(),
    );
  }
}

class DepartmentModel {
  final int did;
  final String dname;

  DepartmentModel({
    required this.did,
    required this.dname,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      did: json['did'],
      dname: json['dname'],
    );
  }
}
