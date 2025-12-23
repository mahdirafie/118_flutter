import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/search/data/dto/search_dto.dart';
import 'package:basu_118/features/search/data/dto/search_history_dto.dart';
import 'package:basu_118/features/search/domain/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final ApiService api;

  SearchRepositoryImpl({required this.api});

  @override
  Future<SearchResponseDTO> search({
    required String query,
    int? facultyId,
    int? departmentId,
    String? workArea,
  }) async {
    // Build query parameters
    final Map<String, dynamic> queryParams = {'query': query};

    if (facultyId != null && facultyId > 0) {
      queryParams['faculty_id'] = facultyId;
    }

    if (departmentId != null && departmentId > 0) {
      queryParams['department_id'] = departmentId;
    }

    if (workArea != null && workArea.isNotEmpty) {
      queryParams['workarea'] = workArea;
    }

    final response = await api.get('search', query: queryParams);

    return SearchResponseDTO.fromJson(response.data);
  }

  @override
  Future<SearchHistoriesDTO> searchHistories() async {
    final response = await api.get('/search/user-histories');
    return SearchHistoriesDTO.fromJson(response.data);
  }

  @override
  Future<void> deleteSearchHistory(int shId) async {
    await api.delete('/search/history/delete/$shId');
  }

  @override
  Future<void> createSearchHistory(String query) async {
    await api.post('/search/history/create', {'query': query});
  }
}
