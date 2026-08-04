import 'package:flutter/material.dart';

/// Model representing a medication row in the Supabase `medications` table.
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

  /// Parse a Supabase row into a [MedicationModel].
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

  /// Serialize to a map for Supabase insert/update.
  /// Excludes `id` and `created_at` (handled by the database).
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

  /// Formatted time string for display (e.g. "9:00 AM").
  String get formattedTime {
    if (reminderTime == null) return '--:--';
    final hour =
        reminderTime!.hourOfPeriod == 0 ? 12 : reminderTime!.hourOfPeriod;
    final minute = reminderTime!.minute.toString().padLeft(2, '0');
    final period = reminderTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Time-of-day category used by the homepage tabs.
  /// Morning: before 12 PM · Afternoon: 12 PM – 5:59 PM · Evening: 6 PM+
  String get timeCategory {
    if (reminderTime == null) return 'morning';
    if (reminderTime!.hour < 12) return 'morning';
    if (reminderTime!.hour < 18) return 'afternoon';
    return 'evening';
  }

  /// Parse a frequency string like "Mon,Tue,Wed" into display text.
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
