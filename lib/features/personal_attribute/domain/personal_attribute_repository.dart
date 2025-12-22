import 'package:basu_118/features/personal_attribute/dto/personal_attribute_dto.dart';

abstract class PersonalAttributeRepository {
  Future<PersonalAttributeResponseDTO> getAllAttribute();
}