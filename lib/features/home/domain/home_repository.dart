

import 'package:basu_118/features/home/dto/home_response_dto.dart';

abstract class HomeRepository {
  Future<HomeResponseDTO> getHome(int userId);
}