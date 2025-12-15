import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  // Keys
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';
  static const uidKey = 'uid';
  static const userTypeKey = 'user_type';

  // Secure storage instance
  static const storage = FlutterSecureStorage();

  /// Save login info securely
  static Future<void> saveLoginInfo({
    required String accessToken,
    required String refreshToken,
    required int uid,
    required String userType,
  }) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    await storage.write(key: refreshTokenKey, value: refreshToken);
    await storage.write(key: uidKey, value: uid.toString());
    await storage.write(key: userTypeKey, value: userType);
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: refreshTokenKey);
  }

  static Future<String?> getUserType() async {
    return await storage.read(key: userTypeKey);
  }

  static Future<int?> getUid() async {
    final uidStr = await storage.read(key: uidKey);
    return uidStr != null ? int.tryParse(uidStr) : null;
  }

  static Future<void> clear() async {
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: refreshTokenKey);
    await storage.delete(key: uidKey);
    await storage.delete(key: userTypeKey);
  }
}
