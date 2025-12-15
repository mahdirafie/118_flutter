import 'package:basu_118/core/auth_service/user_info.dart';
import 'package:basu_118/core/storage/local_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? accessToken;
  String? refreshToken;
  UserInfo? userInfo;

  /// Load tokens from secure storage on app start
  Future<void> loadTokens() async {
    accessToken = await LocalStorage.getAccessToken();
    refreshToken = await LocalStorage.getRefreshToken();
  }

  bool get isLoggedIn => refreshToken != null && refreshToken!.isNotEmpty;

  /// Save new tokens after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await LocalStorage.storage.write(
      key: LocalStorage.accessTokenKey,
      value: accessToken,
    );

    await LocalStorage.storage.write(
      key: LocalStorage.refreshTokenKey,
      value: refreshToken,
    );

    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await LocalStorage.storage.delete(key: LocalStorage.accessTokenKey);
    await LocalStorage.storage.delete(key: LocalStorage.refreshTokenKey);

    accessToken = null;
    refreshToken = null;
  }

  /// Load user info from secure storage
  Future<void> loadUserInfo() async {
    final uid = await LocalStorage.getUid();
    final userType = await LocalStorage.getUserType();

    if (uid == null || userType == null) {
      userInfo = null;
      return;
    }

    userInfo = UserInfo(
      uid: uid,
      userType: userType,
    );
  }

  /// Clear stored user info
  Future<void> clearUserInfo() async {
    await LocalStorage.storage.delete(key: LocalStorage.uidKey);
    await LocalStorage.storage.delete(key: LocalStorage.userTypeKey);

    userInfo = null;
  }

  /// Logout completely
  Future<void> logout() async {
    await clearTokens();
    await clearUserInfo();
  }
}
