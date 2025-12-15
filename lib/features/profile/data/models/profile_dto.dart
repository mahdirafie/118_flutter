class ProfileDTO {
  final String phone;
  final String fullName;
  final EmployeeDTO? employee;

  ProfileDTO({required this.phone, required this.fullName, this.employee});

  factory ProfileDTO.fromJson(Map<String, dynamic> json) {
    return ProfileDTO(
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      employee:
          json['Employee'] != null
              ? EmployeeDTO.fromJson(json['Employee'] as Map<String, dynamic>)
              : null,
    );
  }
}

class EmployeeDTO {
  final String personnelNo;
  final String nationalCode;
  final FacultyMemberDTO? facultyMember;
  final NonFacultyMemberDTO? nonFacultyMember;

  EmployeeDTO({
    required this.personnelNo,
    required this.nationalCode,
    this.facultyMember,
    this.nonFacultyMember,
  });

  factory EmployeeDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeDTO(
      personnelNo: json['personnel_no'] as String,
      nationalCode: json['national_code'] as String,
      facultyMember:
          json['EmployeeFacultyMemeber'] != null
              ? FacultyMemberDTO.fromJson(
                json['EmployeeFacultyMemeber'] as Map<String, dynamic>,
              )
              : null,
      nonFacultyMember:
          json['EmployeeNonFacultyMember'] != null
              ? NonFacultyMemberDTO.fromJson(
                json['EmployeeNonFacultyMember'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class FacultyMemberDTO {
  final int? did;
  final DepartmentDTO? department;

  FacultyMemberDTO({this.did, this.department});

  factory FacultyMemberDTO.fromJson(Map<String, dynamic> json) {
    return FacultyMemberDTO(
      did: json['did'] as int?,
      department:
          json['Department'] != null
              ? DepartmentDTO.fromJson(
                json['Department'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

class NonFacultyMemberDTO {
  final String workarea;

  NonFacultyMemberDTO({required this.workarea});

  factory NonFacultyMemberDTO.fromJson(Map<String, dynamic> json) {
    return NonFacultyMemberDTO(
      workarea: json['workarea'] as String,
    );
  }
}


class DepartmentDTO {
  final String dname;
  final FacultyDTO? faculty;

  DepartmentDTO({required this.dname, this.faculty});

  factory DepartmentDTO.fromJson(Map<String, dynamic> json) {
    return DepartmentDTO(
      dname: json['dname'] as String,
      faculty:
          json['Faculty'] != null
              ? FacultyDTO.fromJson(json['Faculty'] as Map<String, dynamic>)
              : null,
    );
  }
}

class FacultyDTO {
  final String fname;

  FacultyDTO({required this.fname});

  factory FacultyDTO.fromJson(Map<String, dynamic> json) {
    return FacultyDTO(fname: json['fname'] as String);
  }
}

class ProfileResponseDTO {
  final String message;
  final ProfileDTO user;

  ProfileResponseDTO({required this.message, required this.user});

  factory ProfileResponseDTO.fromJson(Map<String, dynamic> json) {
    return ProfileResponseDTO(
      message: json['message'] as String,
      user: ProfileDTO.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
