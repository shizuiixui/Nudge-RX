import 'package:flutter/material.dart';

class MedicationModel {
  final String? id;
  final String userId;
  final String name;
  final String? dosage;
  final String? frequency;
  final TimeOfDay? reminderTime;
  final String? mealInstruction;
  final DateTime? createdAt;

  const MedicationModel({
    this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.frequency,
    this.reminderTime,
    this.mealInstruction,
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
      mealInstruction: json['meal_instruction'] as String?,
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
      'meal_instruction': mealInstruction,
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

  String get categoryAssetPath {
    final doseStr = dosage?.toLowerCase() ?? '';
    if (doseStr.contains('mg/ml') || doseStr.endsWith('ml')) {
      return 'assets/images/AddMedicine/Liquid.png';
    }
    if (doseStr.contains('drop') || doseStr.endsWith('%')) {
      return 'assets/images/AddMedicine/Eyedrops.png';
    }
    if (doseStr.contains('sachet')) {
      return 'assets/images/AddMedicine/Sachet.png';
    }
    if (doseStr.endsWith('g') &&
        !doseStr.endsWith('mg') &&
        !doseStr.endsWith('mcg')) {
      return 'assets/images/AddMedicine/Sachet.png';
    }
    if (doseStr.contains('capsule')) {
      return 'assets/images/AddMedicine/Capsules.png';
    }
    return 'assets/images/AddMedicine/Pills.png';
  }

  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    TimeOfDay? reminderTime,
    String? mealInstruction,
    DateTime? createdAt,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      mealInstruction: mealInstruction ?? this.mealInstruction,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
