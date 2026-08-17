import 'package:flutter/material.dart';

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
  MedicineType type;
  String name;
  String milligrams;
  String dose;
  Set<int> selectedDays;
  TimeOfDay time;
  String mealInstruction;
  bool notificationEnabled;

  MedicineFormData({
    this.type = MedicineType.pills,
    this.name = '',
    this.milligrams = '',
    this.dose = '1',
    Set<int>? selectedDays,
    TimeOfDay? time,
    this.mealInstruction = 'After Meal',
    this.notificationEnabled = true,
  }) : selectedDays = selectedDays ?? <int>{},
       time = time ?? const TimeOfDay(hour: 9, minute: 0);
}
