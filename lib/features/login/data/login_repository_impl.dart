import 'package:basu_118/core/config/api_service.dart';
import 'package:basu_118/features/login/data/models/login_response_dto.dart';
import 'package:basu_118/features/login/domain/login_repository.dart';

class LoginRepositoryImpl implements LoginRepository {
  final ApiService api;

  LoginRepositoryImpl(this.api);

  @override
  Future<LoginResponse> login(String username, String password) async {
    final response = await api.post('/auth/login', {
      'username': username,
      'password': password,
    });

    final dto = LoginResponse.fromJson(response.data);
    return dto;
  }
}