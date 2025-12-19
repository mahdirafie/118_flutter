import 'package:basu_118/features/contact_detail/dto/contact_detail_dto.dart';

abstract class ContactRepository {
  Future<ContactDetailDTO> getContactDetail(int cid, int uid);
}