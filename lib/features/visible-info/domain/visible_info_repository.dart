import 'package:basu_118/features/visible-info/dto/visible_info_response_dto.dart';

abstract class VisibleInfoRepository {
  Future<EmployeeVisibleInfoDTO> getVisibleInfo(int empId);
}