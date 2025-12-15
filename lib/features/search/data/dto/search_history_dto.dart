class SearchHistoriesDTO {
  final String message;
  final List<HistoryDTO> histories;

  SearchHistoriesDTO({required this.message, required this.histories});

  factory SearchHistoriesDTO.fromJson(Map<String, dynamic> json) {
    return SearchHistoriesDTO(
      message: json['message'] as String,
      histories:
          (json['histories'] as List)
              .map((e) => HistoryDTO.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'histories': histories.map((e) => e.toJson()).toList(),
    };
  }
}

class HistoryDTO {
  final int shid;
  final String query;

  HistoryDTO({required this.shid, required this.query});

  factory HistoryDTO.fromJson(Map<String, dynamic> json) {
    return HistoryDTO(
      shid: json['shid'] as int,
      query: json['query'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'shid': shid, 'query': query};
  }
}
