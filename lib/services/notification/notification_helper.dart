import 'package:flutter/foundation.dart';

class NotificationHelper {
  // Request notification permission
  static Future<bool> requestPermission() async {
    if (kIsWeb) {
      // For now, just return true for web
      // Web notifications require actual JavaScript interop
      // which we haven't implemented yet
      print('ℹ️ Web notifications need JS interop implementation');
      return true;
    }
    
    // Android - permissions are typically granted automatically
    // for local notifications (no runtime permission needed)
    return true;
  }
  
  // Check if notifications are supported on current platform
  static bool areNotificationsSupported() {
    // Local notifications work on Android and iOS
    // Web notifications need browser support
    if (kIsWeb) {
      // Web notifications require:
      // 1. HTTPS connection
      // 2. Browser support
      // 3. User permission
      return true; // Most modern browsers support it
    }
    
    // Android and iOS support local notifications
    return true;
  }
  
  // Show instructions for enabling notifications
  static String getNotificationInstructions() {
    if (kIsWeb) {
      return '''
برای دریافت اعلان‌ها در مرورگر:
1. روی قفل در نوار آدرس کلیک کنید
2. گزینه "اعلان‌ها" را پیدا کنید
3. آن را به "اجازه" تغییر دهید
''';
    }
    
    // Android instructions
    return '''
برای دریافت اعلان‌ها در اندروید:
1. به تنظیمات برنامه بروید
2. به بخش "اعلان‌ها" مراجعه کنید
3. اعلان‌های برنامه را فعال کنید
''';
  }
}