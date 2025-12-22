import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/personal_attribute/domain/personal_attribute_repository.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';

class PersonalAttributeRepositoryImpl implements PersonalAttributeRepository {
  final ApiService api;

  PersonalAttributeRepositoryImpl({required this.api});
  @override
  Future<PersonalAttributeResponseDTO> getAllAttribute() async{
   final response = await api.get('/attribute/get-all');
   return PersonalAttributeResponseDTO.fromJson(response.data);
  }
}