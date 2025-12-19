import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/contact_detail/domain/contact_repository.dart';
import 'package:basu_118/features/contact_detail/dto/contact_detail_dto.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ApiService api;

  ContactRepositoryImpl({required this.api});
  @override
  Future<ContactDetailDTO> getContactDetail(int cid, int uid) async{
    final response = await api.get('/contactable/info/$cid/$uid');
    return ContactDetailDTO.fromJson(response.data);
  }

}