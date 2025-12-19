import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/home/domain/home_repository.dart';
import 'package:basu_118/features/home/dto/home_response_dto.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService api;

  HomeRepositoryImpl({required this.api});
  @override
  Future<HomeResponseDTO> getHome(int userId) async{
    final response = await api.get('/related/$userId'); 
    return HomeResponseDTO.fromJson(response.data);
  }
}
