import 'package:hive_flutter/hive_flutter.dart';

class Reminder {
  final String id;
  final int cid;
  final String title;
  final String? description;
  final DateTime reminderDateTime;
  final bool isActive;
  final String? contactName;

  Reminder({
    required this.id,
    required this.cid,
    required this.title,
    this.description,
    required this.reminderDateTime,
    required this.isActive,
    this.contactName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cid': cid,
      'title': title,
      'description': description,
      'reminder_datetime': reminderDateTime.toIso8601String(),
      'is_active': isActive,
      'contact_name': contactName,
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      cid: json['cid'],
      title: json['title'],
      description: json['description'],
      reminderDateTime: DateTime.parse(json['reminder_datetime']),
      isActive: json['is_active'],
      contactName: json['contact_name'],
    );
  }

  // Convert to Map for Hive storage (simpler format)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cid': cid,
      'title': title,
      'description': description,
      'reminderDateTime': reminderDateTime.millisecondsSinceEpoch,
      'isActive': isActive,
      'contactName': contactName,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      cid: map['cid'],
      title: map['title'],
      description: map['description'],
      reminderDateTime: DateTime.fromMillisecondsSinceEpoch(
        map['reminderDateTime'],
      ),
      isActive: map['isActive'],
      contactName: map['contactName'],
    );
  }
}

// Manual TypeAdapter implementation
class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0; // Must be unique (0-223)

  @override
  Reminder read(BinaryReader reader) {
    // Read the map from binary
    final map = reader.readMap();

    // Convert map keys to String and values to dynamic
    final convertedMap = <String, dynamic>{};
    map.forEach((key, value) {
      convertedMap[key.toString()] = value;
    });

    return Reminder.fromMap(convertedMap);
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    // Write the map to binary
    writer.writeMap(obj.toMap());
  }
}
