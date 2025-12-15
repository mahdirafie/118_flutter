class FacultiesResponse {
  final String message;
  final List<FacultyModel> faculties;

  FacultiesResponse({
    required this.message,
    required this.faculties,
  });

  factory FacultiesResponse.fromJson(Map<String, dynamic> json) {
    return FacultiesResponse(
      message: json['message'],
      faculties: (json['faculties'] as List)
          .map((item) => FacultyModel.fromJson(item))
          .toList(),
    );
  }
}

class FacultyModel {
  final int fid;
  final String fname;

  FacultyModel({
    required this.fid,
    required this.fname,
  });

  factory FacultyModel.fromJson(Map<String, dynamic> json) {
    return FacultyModel(
      fid: json['fid'],
      fname: json['fname'],
    );
  }
}
