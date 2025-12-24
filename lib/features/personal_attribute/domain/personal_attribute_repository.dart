import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';
import 'package:basu_118/features/personal_attribute/dto/personal_attribute_visible_dto.dart';

abstract class PersonalAttributeRepository {
  Future<PersonalAttributeResponseDTO> getAllAttribute();
  Future<void> setAttributeValues(List<Map<String, dynamic>> attVals);
  Future<void> setVisibleAtts(int id, String type, List<Map<String, dynamic>> attVals);
  Future<AttributeValueVisibleDTO> getAttributeValuesWithVisibility(int receiverId, String type);
}