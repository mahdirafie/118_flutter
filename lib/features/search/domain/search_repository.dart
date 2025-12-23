import 'package:basu_118/features/search/data/dto/search_dto.dart';
import 'package:basu_118/features/search/data/dto/search_history_dto.dart';

abstract class SearchRepository {
  Future<SearchResponseDTO> search({
    required String query,
    int? facultyId,
    int? departmentId,
    String? workArea,
  });
  Future<SearchHistoriesDTO> searchHistories();
  Future<void> deleteSearchHistory(int shId);
  Future<void> createSearchHistory(String query);
}
