import 'package:flutter/material.dart';

class MedicationModel {
  final String? id;
  final String userId;
  final String name;
  final String? dosage;
  final String? frequency;
  final TimeOfDay? reminderTime;
  final DateTime? createdAt;

  const MedicationModel({
    this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.frequency,
    this.reminderTime,
    this.createdAt,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    TimeOfDay? time;
    if (json['reminder_time'] != null) {
      final parts = (json['reminder_time'] as String).split(':');
      if (parts.length >= 2) {
        time = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    return MedicationModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String?,
      frequency: json['frequency'] as String?,
      reminderTime: time,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'reminder_time': reminderTime != null
          ? '${reminderTime!.hour.toString().padLeft(2, '0')}:'
                '${reminderTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
    };
    return map;
  }

  String get formattedTime {
    if (reminderTime == null) return '--:--';
    final hour = reminderTime!.hourOfPeriod == 0
        ? 12
        : reminderTime!.hourOfPeriod;
    final minute = reminderTime!.minute.toString().padLeft(2, '0');
    final period = reminderTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String get timeCategory {
    if (reminderTime == null) return 'morning';
    if (reminderTime!.hour < 12) return 'morning';
    if (reminderTime!.hour < 18) return 'afternoon';
    return 'evening';
  }

  String get frequencyDisplay {
    if (frequency == null || frequency!.isEmpty) return 'Daily';
    return frequency!;
  }

  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    TimeOfDay? reminderTime,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
