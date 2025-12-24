class EmployeeVisibleInfoDTO {
  final String message;
  final List<EmployeeAttributeVisibleInfoDTO> employeeInfo;

  EmployeeVisibleInfoDTO({required this.message, required this.employeeInfo});

  factory EmployeeVisibleInfoDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeVisibleInfoDTO(
      message: json['message'] as String,
      employeeInfo:
          (json['employee_info'] as List)
              .map((e) => EmployeeAttributeVisibleInfoDTO.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'employee_info': employeeInfo.map((e) => e.toJson()).toList(),
    };
  }
}

class EmployeeAttributeVisibleInfoDTO {
  final int attId;
  final String attName;
  final String? value;
  final int? valId;

  EmployeeAttributeVisibleInfoDTO({
    required this.attId,
    required this.attName,
    required this.value,
    required this.valId,
  });

  factory EmployeeAttributeVisibleInfoDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeAttributeVisibleInfoDTO(
      attId: json['att_id'] as int,
      attName: json['att_name'] as String,
      value: json['value'] as String?,
      valId: json['val_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'att_id': attId,
      'att_name': attName,
      'value': value,
      'val_id': valId,
    };
  }
}