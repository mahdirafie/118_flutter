import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/home/domain/home_repository.dart';
import 'package:basu_118/features/home/dto/employeef_dto.dart';
import 'package:basu_118/features/home/dto/employeen_dto.dart';
import 'package:basu_118/features/home/dto/user_home_dto.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiService api;

  HomeRepositoryImpl(this.api);

  @override
  Future<EmployeeFDTO> getEmployeeF() async {
    final response = await api.get('/multi-model/related-contacts');

    final empfDTO = EmployeeFDTO.fromJson(response.data);
    return empfDTO;
  }

  @override
  Future<EmployeeNDTO> getEmployeeN() async{
    final response = await api.get('/multi-model/related-contacts');

    final empnDTO = EmployeeNDTO.fromJson(response.data);
    return empnDTO;
  }

  @override
  Future<UserHomeDTO> getUserHome() async{
    final response = await api.get('/multi-model/related-contacts');

    final usrhomeDTO = UserHomeDTO.fromJson(response.data);
    return usrhomeDTO;
  }

}