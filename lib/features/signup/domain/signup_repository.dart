abstract class SignupRepository {
  Future<void> requestOtp(String phone);
  Future<void> verifyOtp(String phone, String otpCode);
  Future<void> createUser(String name, String lastName, String password, String phone);
}