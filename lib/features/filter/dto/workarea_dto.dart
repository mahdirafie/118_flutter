class WorkAreasResponse {
  final String message;
  final List<String> workareas;

  WorkAreasResponse({required this.message, required this.workareas});

  factory WorkAreasResponse.fromJson(Map<String, dynamic> json) {
    return WorkAreasResponse(
      message: json['message'],
      workareas: List<String>.from(json['workareas']),
    );
  }
}
