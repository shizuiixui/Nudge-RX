import 'package:flutter/material.dart';
import '../models/medication_model.dart';

enum MedicineType { pills, capsules, liquid, eyedrops, sachet }

/// Per-type UI configuration for image assets, labels, and suffixes.
typedef MedicineTypeConfig = ({
  String asset,
  String label,
  String leftTitle,
  String leftSuffix,
  String rightTitle,
  String rightSuffix,
});

/// Configuration map for each medicine type's UI presentation.
const typeConfigs = <MedicineType, MedicineTypeConfig>{
  MedicineType.pills: (
    asset: 'assets/images/AddMedicine/Pills.png',
    label: 'Pills',
    leftTitle: 'Milligrams',
    leftSuffix: 'mg',
    rightTitle: 'Dose',
    rightSuffix: 'pill(s)',
  ),
  MedicineType.capsules: (
    asset: 'assets/images/AddMedicine/Capsules.png',
    label: 'Capsules',
    leftTitle: 'Milligrams',
    leftSuffix: 'mg',
    rightTitle: 'Dose',
    rightSuffix: 'capsule(s)',
  ),
  MedicineType.liquid: (
    asset: 'assets/images/AddMedicine/Liquid.png',
    label: 'Liquid',
    leftTitle: 'Concentration',
    leftSuffix: 'mg/ml',
    rightTitle: 'Amount',
    rightSuffix: 'ml',
  ),
  MedicineType.eyedrops: (
    asset: 'assets/images/AddMedicine/Eyedrops.png',
    label: 'Eyedrops',
    leftTitle: 'Concentration',
    leftSuffix: '%',
    rightTitle: 'Dose',
    rightSuffix: 'drop(s)',
  ),
  MedicineType.sachet: (
    asset: 'assets/images/AddMedicine/Sachet.png',
    label: 'Sachets',
    leftTitle: 'Weight',
    leftSuffix: 'g',
    rightTitle: 'Quantity',
    rightSuffix: 'sachet(s)',
  ),
};

/// Data class holding all fields on the Edit / Add screen.
class MedicineFormData {
  final String? id;
  MedicineType type;
  String name;
  String milligrams;
  String dose;
  Set<int> selectedDays;
  TimeOfDay time;
  String mealInstruction;
  bool notificationEnabled;

  MedicineFormData({
    this.id,
    this.type = MedicineType.pills,
    this.name = '',
    this.milligrams = '',
    this.dose = '1',
    Set<int>? selectedDays,
    TimeOfDay? time,
    this.mealInstruction = 'After Meal',
    this.notificationEnabled = true,
  })  : selectedDays = selectedDays ?? const <int>{},
        time = time ?? const TimeOfDay(hour: 9, minute: 0);

  factory MedicineFormData.fromModel(MedicationModel model) {
    // Determine type from dosage string
    MedicineType type = MedicineType.pills;
    final doseStr = model.dosage?.toLowerCase() ?? '';
    if (doseStr.contains('mg/ml') || doseStr.endsWith('ml')) {
      type = MedicineType.liquid;
    } else if (doseStr.contains('drop') || doseStr.endsWith('%')) {
      type = MedicineType.eyedrops;
    } else if (doseStr.contains('sachet')) {
      type = MedicineType.sachet;
    } else if (doseStr.endsWith('g') &&
        !doseStr.endsWith('mg') &&
        !doseStr.endsWith('mcg')) {
      type = MedicineType.sachet;
    } else if (doseStr.contains('capsule')) {
      type = MedicineType.capsules;
    }

    // Parse milligrams and dose
    String milligrams = '';
    String dose = '1';
    final cfg = typeConfigs[type]!;

    if (model.dosage != null && model.dosage!.isNotEmpty) {
      final parts = model.dosage!.split(' x ');
      
      // Left part contains milligrams + suffix
      final leftPart = parts[0].trim();
      if (leftPart.endsWith(cfg.leftSuffix)) {
        milligrams = leftPart
            .substring(0, leftPart.length - cfg.leftSuffix.length)
            .trim();
      } else {
        milligrams = leftPart;
      }

      // Right part contains dose count + suffix
      if (parts.length > 1) {
        final rightPart = parts[1].trim();
        final suffixIndex = rightPart.indexOf(cfg.rightSuffix);
        if (suffixIndex != -1) {
          dose = rightPart.substring(0, suffixIndex).trim();
        } else {
          // Fallback
          dose = rightPart.replaceAll(RegExp(r'[^0-9]'), '');
        }
      }
    }

    // Parse frequency to days
    Set<int> selectedDays = {};
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    if (model.frequency == 'Daily') {
      selectedDays = {0, 1, 2, 3, 4};
    } else if (model.frequency != null && model.frequency!.isNotEmpty) {
      final days = model.frequency!.split(',');
      for (final d in days) {
        final idx = dayLabels.indexOf(d.trim());
        if (idx != -1) {
          selectedDays.add(idx);
        }
      }
    }

    return MedicineFormData(
      id: model.id,
      type: type,
      name: model.name,
      milligrams: milligrams,
      dose: dose,
      selectedDays: selectedDays,
      time: model.reminderTime,
    );
  }
}
