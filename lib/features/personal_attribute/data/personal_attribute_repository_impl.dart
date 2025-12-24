import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/personal_attribute/domain/personal_attribute_repository.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_visible_dto.dart';

class PersonalAttributeRepositoryImpl implements PersonalAttributeRepository {
  final ApiService api;

  PersonalAttributeRepositoryImpl({required this.api});
  @override
  Future<PersonalAttributeResponseDTO> getAllAttribute() async {
    final response = await api.get('/attribute/get-all');
    return PersonalAttributeResponseDTO.fromJson(response.data);
  }

  @override
  Future<void> setAttributeValues(List<Map<String, dynamic>> attVals) async {
    await api.post('/attribute/set-atts-values', {'attributes': attVals});
  }

  @override
  Future<void> setVisibleAtts(
    int id,
    String type,
    List<Map<String, dynamic>> attVals,
  ) async {
    await api.post(
      type == "employee"
          ? '/attribute/set-visible-att-vals-emp'
          : '/attribute/set-visible-att-vals-group',
      {'attribute_values': attVals,
        type == "employee" ? 'receiver_emp_id': 'gid': id
      },
    );
  }

  @override
  Future<AttributeValueVisibleDTO> getAttributeValuesWithVisibility(int receiverId, String type) async{
    final response = await api.get('/attribute/get-visible-att-vals/$receiverId/$type');
    return AttributeValueVisibleDTO.fromJson(response.data);
  }
}
