import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/visible-info/domain/visible_info_repository.dart';
import 'package:basu_118/features/visible-info/dto/visible_info_response_dto.dart';

class VisibleInfoRepositoryImpl implements VisibleInfoRepository {
  final ApiService api;

  VisibleInfoRepositoryImpl({required this.api});
  @override
  Future<EmployeeVisibleInfoDTO> getVisibleInfo(int empId) async{
    final response = await api.get('/attribute/get-employee-personal-info/$empId');
    return EmployeeVisibleInfoDTO.fromJson(response.data);
  }
}