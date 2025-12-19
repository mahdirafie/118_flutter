class HomeResponseDTO {
  final String message;
  final List<EmployeeHomeDTO> employees;
  final List<PostHomeDTO> posts;
  final List<SpaceHomeDTO> spaces;

  HomeResponseDTO({
    required this.message,
    required this.employees,
    required this.posts,
    required this.spaces,
  });

  factory HomeResponseDTO.fromJson(Map<String, dynamic> json) {
    return HomeResponseDTO(
      message: json['message'],
      employees: (json['employees'] as List)
          .map((e) => EmployeeHomeDTO.fromJson(e))
          .toList(),
      posts:
          (json['posts'] as List).map((p) => PostHomeDTO.fromJson(p)).toList(),
      spaces:
          (json['spaces'] as List).map((s) => SpaceHomeDTO.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'employees': employees.map((e) => e.toJson()).toList(),
        'posts': posts.map((p) => p.toJson()).toList(),
        'spaces': spaces.map((s) => s.toJson()).toList(),
      };
}

class EmployeeHomeDTO {
  final int cid;
  final String fullName;
  final String? post;
  final bool isFavorite;

  EmployeeHomeDTO({
    required this.cid,
    required this.fullName,
    this.post,
    required this.isFavorite,
  });

  factory EmployeeHomeDTO.fromJson(Map<String, dynamic> json) {
    return EmployeeHomeDTO(
      cid: json['cid'],
      fullName: json['full_name'],
      post: json['post'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'full_name': fullName,
        'post': post,
        'is_favorite': isFavorite,
      };
}

class PostHomeDTO {
  final int cid;
  final String pname;
  final String? employee;
  final bool isFavorite;

  PostHomeDTO({
    required this.cid,
    required this.pname,
    this.employee,
    required this.isFavorite,
  });

  factory PostHomeDTO.fromJson(Map<String, dynamic> json) {
    return PostHomeDTO(
      cid: json['cid'],
      pname: json['pname'],
      employee: json['employee'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'pname': pname,
        'employee': employee,
        'is_favorite': isFavorite,
      };
}

class SpaceHomeDTO {
  final int cid;
  final String sname;
  final String? post;
  final bool isFavorite;

  SpaceHomeDTO({
    required this.cid,
    required this.sname,
    this.post,
    required this.isFavorite,
  });

  factory SpaceHomeDTO.fromJson(Map<String, dynamic> json) {
    return SpaceHomeDTO(
      cid: json['cid'],
      sname: json['sname'],
      post: json['post'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'sname': sname,
        'post': post,
        'is_favorite': isFavorite,
      };
}
