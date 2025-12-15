import 'package:basu_118/features/login/data/models/login_response_dto.dart';

abstract class LoginRepository {
  Future<LoginResponse> login(String username, String password);
}