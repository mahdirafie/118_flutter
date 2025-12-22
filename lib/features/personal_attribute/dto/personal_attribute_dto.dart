class PersonalAttributeResponseDTO {
  final String message;
  final List<PersonalAttributeDTO> attributes;

  PersonalAttributeResponseDTO({
    required this.message,
    required this.attributes,
  });

  factory PersonalAttributeResponseDTO.fromJson(Map<String, dynamic> json) {
    return PersonalAttributeResponseDTO(
      message: json['message'] as String,
      attributes:
          (json['attributes'] as List)
              .map((e) => PersonalAttributeDTO.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }
}

class PersonalAttributeDTO {
  final int attId;
  final String type;
  final String attName;
  final String? value;

  PersonalAttributeDTO({
    required this.attId,
    required this.type,
    required this.attName,
    required this.value
  });

  factory PersonalAttributeDTO.fromJson(Map<String, dynamic> json) {
    return PersonalAttributeDTO(
      attId: json['att_id'] as int,
      type: json['type'] as String,
      attName: json['att_name'] as String,
      value: (json['value'] as String?)
    );
  }

  Map<String, dynamic> toJson() {
    return {'att_id': attId, 'type': type, 'att_name': attName, 'value': value};
  }
}
