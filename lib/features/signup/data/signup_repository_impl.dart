import 'package:basu_118/features/signup/domain/signup_repository.dart';

import '../../../core/config/api_service.dart';


class SignupRepositoryImpl implements SignupRepository {
  final ApiService api;

  SignupRepositoryImpl(this.api);

  @override
  Future<void> requestOtp(String phone) async {
    await api.post('/auth/send-otp', {'phone': phone});
  }
  
  @override
  Future<void> verifyOtp(String phone, String otpCode) async{
    await api.post('/auth/verify-otp', {'phone': phone, 'code': otpCode});
  }
  
  @override
  Future<void> createUser(String name, String lastName, String password, String phone) async{
    await api.post('/auth/signup', {
      'phone': phone,
      'full_name': '$name $lastName',
      'password': password,
    });
  }
}
