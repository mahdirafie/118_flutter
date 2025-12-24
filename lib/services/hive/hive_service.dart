// lib/services/hive_service.dart
import 'package:basu_118/services/hive/hive_models/reminder_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  Box<Reminder> get remindersBox => Hive.box<Reminder>('reminders');

  Future<void> saveReminder(Reminder reminder) async {
    await remindersBox.put(reminder.id, reminder);
  }

  List<Reminder> getAllReminders() {
    return remindersBox.values.toList();
  }

  List<Reminder> getRemindersByContact(int cid) {
    return remindersBox.values
        .where((reminder) => reminder.cid == cid)
        .toList();
  }

  Future<void> deleteReminder(String id) async {
    await remindersBox.delete(id);
  }

  Future<void> clearAllReminders() async {
    await remindersBox.clear();
  }

  Reminder? getReminder(String id) {
    return remindersBox.get(id);
  }
}
