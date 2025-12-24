import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
// REPLACED: flutter_native_timezone with flutter_timezone
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:basu_118/services/hive/hive_models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;
  
  NotificationService._internal() {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
  }
  
  // Initialize notifications for Android and PWA
  Future<void> initialize() async {
    try {
      print('🔧 Initializing notification service...');
      
      // Initialize timezone database
      tz.initializeTimeZones();
      
      // Get local timezone using flutter_timezone
      String timeZoneName;
      try {
        // UPDATED: Using flutter_timezone package
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        timeZoneName = timezoneInfo.identifier;
        print('🌍 Detected timezone: $timeZoneName');
      } catch (e) {
        print('⚠️ Could not fetch device timezone: $e. Using default (Asia/Tehran).');
        timeZoneName = 'Asia/Tehran'; // Default timezone
      }
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      // Android notification setup
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // For PWA/Web, we need different initialization
      final InitializationSettings initializationSettings = 
          InitializationSettings(
        android: androidInitializationSettings,
        // For web/PWA
        macOS: null,
        iOS: null,
      );
      
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );
      
      // Create notification channel for Android 8.0+
      await _createNotificationChannel();
      
      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      _isInitialized = false;
    }
  }
  
  Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'reminder_channel_id',
        'یادآورها',
        description: 'اعلان‌های یادآوری برنامه',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print('📢 Notification channel created successfully');
    } catch (e) {
      print('⚠️ Could not create notification channel (may be web): $e');
    }
  }
  
  // Schedule a notification for exact reminder time
  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!reminder.isActive) {
      return; // Don't schedule for inactive reminders
    }
    
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, trying to initialize...');
      await initialize();
      
      if (!_isInitialized) {
        print('❌ Cannot schedule notification - service failed to initialize');
        return;
      }
    }
    
    try {
      final scheduledDate = tz.TZDateTime.from(
        reminder.reminderDateTime, 
        tz.local,
      );
      
      // Check if the reminder is in the past
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('⏰ Cannot schedule past reminder: ${reminder.title}');
        return;
      }
      
      const androidDetails = AndroidNotificationDetails(
        'reminder_channel_id',
        'یادآورها',
        channelDescription: 'اعلان‌های یادآوری برنامه',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        fullScreenIntent: true,
        autoCancel: true,
        showWhen: true,
        styleInformation: BigTextStyleInformation(''),
        colorized: true,
        color: Color(0xFF007AFF), // AppColors.primary
      );
      
      final notificationDetails = const NotificationDetails(
        android: androidDetails,
      );
      
      await _notificationsPlugin.zonedSchedule(
        _getNotificationId(reminder.id), // Unique ID
        reminder.title,
        reminder.description ?? 'یادآور فعال شد',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        payload: reminder.id, // Pass reminder ID as payload
      );
      
      print('✅ Notification scheduled for: ${reminder.title} at $scheduledDate');
    } catch (e) {
      print('❌ Error scheduling notification for ${reminder.title}: $e');
    }
  }
  
  // Cancel a scheduled notification
  Future<void> cancelReminderNotification(Reminder reminder) async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, skipping cancel');
      return;
    }
    
    try {
      await _notificationsPlugin.cancel(_getNotificationId(reminder.id));
      print('🗑️ Notification canceled for: ${reminder.title}');
    } catch (e) {
      print('⚠️ Error canceling notification (may be OK): $e');
    }
  }
  
  // Cancel all notifications (for cleanup)
  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, skipping cancel all');
      return;
    }
    
    try {
      await _notificationsPlugin.cancelAll();
      print('🗑️ All notifications canceled');
    } catch (e) {
      print('⚠️ Error canceling all notifications: $e');
    }
  }
  
  // Show immediate notification (for testing)
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, initializing...');
      await initialize();
      
      if (!_isInitialized) {
        print('❌ Cannot show test - service failed to initialize');
        return;
      }
    }
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'reminder_channel_id',
        'یادآورها',
        channelDescription: 'اعلان‌های یادآوری برنامه',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      await _notificationsPlugin.show(
        999999, // Test ID
        'یادآور تستی',
        'این یک اعلان تستی است',
        const NotificationDetails(android: androidDetails),
      );
      
      print('🔔 Test notification shown');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }
  
  // Get all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, returning empty list');
      return [];
    }
    
    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }
  
  // Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    final reminderId = response.payload;
    if (reminderId != null) {
      print('📱 Notification tapped for reminder: $reminderId');
      // You can navigate to reminder details here
      // or mark the reminder as completed
    }
  }
  
  // Generate unique notification ID from reminder ID
  int _getNotificationId(String reminderId) {
    return reminderId.hashCode & 0x7FFFFFFF; // Positive integer
  }
  
  // Reschedule all active reminders (call on app startup)
  Future<void> rescheduleAllReminders(List<Reminder> reminders) async {
    print('🔄 Starting to reschedule reminders...');
    
    if (!_isInitialized) {
      print('⚠️ Notification service not initialized, initializing...');
      await initialize();
      
      if (!_isInitialized) {
        print('❌ Cannot reschedule - service failed to initialize');
        return;
      }
    }
    
    try {
      // Don't cancel all notifications - just schedule new ones
      // This avoids the package initialization issue
      int scheduledCount = 0;
      int skippedCount = 0;
      
      for (final reminder in reminders) {
        if (reminder.isActive) {
          try {
            await scheduleReminderNotification(reminder);
            scheduledCount++;
          } catch (e) {
            print('⚠️ Failed to schedule ${reminder.title}: $e');
            skippedCount++;
          }
        }
      }
      
      print('✅ Rescheduled $scheduledCount reminders, skipped $skippedCount');
    } catch (e) {
      print('❌ Error in rescheduleAllReminders: $e');
    }
  }
  
  // Check if service is initialized
  bool get isInitialized => _isInitialized;
}