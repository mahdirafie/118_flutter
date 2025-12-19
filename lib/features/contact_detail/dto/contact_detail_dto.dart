class ContactDetailDTO {
  final String message;
  final ContactContact contact;

  ContactDetailDTO({required this.message, required this.contact});

  factory ContactDetailDTO.fromJson(Map<String, dynamic> json) {
    return ContactDetailDTO(
      message: json['message'],
      contact: ContactContact.fromJson(json['contact']),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'contact': contact.toJson(),
  };
}

class ContactContact {
  final int cid;
  final String contactType;
  final bool isFavorite;
  final List<ContactInfoContact> contactInfos;
  final RelativeInfoContact? relativeInfo;

  ContactContact({
    required this.cid,
    required this.contactType,
    required this.isFavorite,
    required this.contactInfos,
    this.relativeInfo,
  });

  factory ContactContact.fromJson(Map<String, dynamic> json) {
    return ContactContact(
      cid: json['cid'],
      contactType: json['contact_type'],
      isFavorite: json['is_favorite'],
      contactInfos:
          (json['contact_infos'] as List)
              .map((e) => ContactInfoContact.fromJson(e))
              .toList(),
      relativeInfo:
          json['relative_info'] != null
              ? RelativeInfoContact.fromJson(json['relative_info'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'cid': cid,
    'contact_type': contactType,
    'is_favorite': isFavorite,
    'contact_infos': contactInfos.map((e) => e.toJson()).toList(),
    'relative_info': relativeInfo?.toJson(),
  };
}

class ContactInfoContact {
  final String contactNumber;
  final String? range;
  final String? subrange;
  final String? forward;
  final String? extension;
  final int cid;

  ContactInfoContact({
    required this.contactNumber,
    this.range,
    this.subrange,
    this.forward,
    this.extension,
    required this.cid,
  });

  factory ContactInfoContact.fromJson(Map<String, dynamic> json) {
    return ContactInfoContact(
      contactNumber: json['contact_number'],
      range: json['range'],
      subrange: json['subrange'],
      forward: json['forward'],
      extension: json['extension'],
      cid: json['cid'],
    );
  }

  Map<String, dynamic> toJson() => {
    'contact_number': contactNumber,
    'range': range,
    'subrange': subrange,
    'forward': forward,
    'extension': extension,
    'cid': cid,
  };
}

class RelativeInfoContact {
  final int espId;
  final int empId;
  final int sid;
  final int pid;
  final EmployeeContact? employee;
  final PostContact? post;
  final SpaceContact? space;

  RelativeInfoContact({
    required this.espId,
    required this.empId,
    required this.sid,
    required this.pid,
    this.employee,
    this.post,
    this.space,
  });

  factory RelativeInfoContact.fromJson(Map<String, dynamic> json) {
    return RelativeInfoContact(
      espId: json['esp_id'],
      empId: json['emp_id'],
      sid: json['sid'],
      pid: json['pid'],
      employee:
          json['Employee'] != null
              ? EmployeeContact.fromJson(json['Employee'])
              : null,
      post: json['Post'] != null ? PostContact.fromJson(json['Post']) : null,
      space:
          json['Space'] != null ? SpaceContact.fromJson(json['Space']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'esp_id': espId,
    'emp_id': empId,
    'sid': sid,
    'pid': pid,
    'Employee': employee?.toJson(),
    'Post': post?.toJson(),
    'Space': space?.toJson(),
  };
}

class EmployeeContact {
  final int empId;
  final int cid;
  final UserContact? user;

  EmployeeContact({required this.empId, required this.cid, this.user});

  factory EmployeeContact.fromJson(Map<String, dynamic> json) {
    return EmployeeContact(
      empId: json['emp_id'],
      cid: json['cid'],
      user: json['User'] != null ? UserContact.fromJson(json['User']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'emp_id': empId,
    'cid': cid,
    'User': user?.toJson(),
  };
}

class UserContact {
  final String fullName;

  UserContact({required this.fullName});

  factory UserContact.fromJson(Map<String, dynamic> json) {
    return UserContact(fullName: json['full_name']);
  }

  Map<String, dynamic> toJson() => {'full_name': fullName};
}

class PostContact {
  final int cid;
  final String pname;

  PostContact({required this.cid, required this.pname});

  factory PostContact.fromJson(Map<String, dynamic> json) {
    return PostContact(cid: json['cid'], pname: json['pname']);
  }

  Map<String, dynamic> toJson() => {'cid': cid, 'pname': pname};
}

class SpaceContact {
  final int cid;
  final String sname;

  SpaceContact({required this.cid, required this.sname});

  factory SpaceContact.fromJson(Map<String, dynamic> json) {
    return SpaceContact(cid: json['cid'], sname: json['sname']);
  }

  Map<String, dynamic> toJson() => {'cid': cid, 'sname': sname};
}
