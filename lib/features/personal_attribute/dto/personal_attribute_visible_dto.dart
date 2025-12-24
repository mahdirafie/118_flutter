class AttributeValueVisibleDTO {
  final String message;
  final List<AttributeVisibleDTO> attribute;

  AttributeValueVisibleDTO({
    required this.message,
    required this.attribute,
  });

  factory AttributeValueVisibleDTO.fromJson(Map<String, dynamic> json) {
    return AttributeValueVisibleDTO(
      message: json['message'] as String,
      attribute: (json['attribute'] as List)
          .map((e) => AttributeVisibleDTO.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'attribute': attribute.map((e) => e.toJson()).toList(),
    };
  }
}

class AttributeVisibleDTO {
  final int attId;
  final String attName;
  final String? value;
  final int valId;
  final bool isSharable;

  AttributeVisibleDTO({
    required this.attId,
    required this.attName,
    required this.value,
    required this.valId,
    required this.isSharable,
  });

  factory AttributeVisibleDTO.fromJson(Map<String, dynamic> json) {
    return AttributeVisibleDTO(
      attId: json['att_id'] as int,
      attName: json['att_name'] as String,
      value: json['value'] as String?,
      valId: json['val_id'] as int,
      isSharable: json['is_sharable'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'att_id': attId,
      'att_name': attName,
      'value': value,
      'val_id': valId,
      'is_sharable': isSharable ? 1 : 0,
    };
  }
}
