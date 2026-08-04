import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

enum MedicineType { pills, capsules, liquid, eyedrops, sachet }

/// Data class holding all fields on the Edit / Add screen.
class MedicineFormData {
  MedicineType type;
  String name;
  String milligrams;
  String dose;
  Set<int> selectedDays; // 0 = Mon … 4 = Fri (weekdays shown in the design)
  TimeOfDay time;
  String mealInstruction; // "After Meal", "Before Meal", "While Eating"
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
  }) : selectedDays = selectedDays ?? {0, 1},
       time = time ?? const TimeOfDay(hour: 9, minute: 0);
}

class AddEditMedicinePage extends ConsumerStatefulWidget {
  final MedicineFormData? existing;

  const AddEditMedicinePage({super.key, this.existing});

  @override
  ConsumerState<AddEditMedicinePage> createState() =>
      _AddEditMedicinePageState();
}

class _AddEditMedicinePageState extends ConsumerState<AddEditMedicinePage> {
  static const _primaryBlue = Color(0xFF38C2EE);
  static const _bgColor = Color(0xFFEAF6FB);

  late MedicineFormData _form;
  late TextEditingController _nameCtrl;
  late TextEditingController _mgCtrl;
  late TextEditingController _doseCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _form = widget.existing ?? MedicineFormData();
    _nameCtrl = TextEditingController(text: _form.name);
    _mgCtrl = TextEditingController(text: _form.milligrams);
    _doseCtrl = TextEditingController(text: _form.dose);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mgCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  bool get _isEdit => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _buildSectionLabel('Choose the type of medicine'),
                    SizedBox(height: 12.h),
                    _buildTypeSelector(),
                    SizedBox(height: 22.h),
                    _buildSectionLabel('Medicine name'),
                    SizedBox(height: 8.h),
                    _buildTextField(_nameCtrl, 'e.g. Bewell-C'),
                    SizedBox(height: 22.h),
                    _buildMilligramsAndDose(),
                    SizedBox(height: 22.h),
                    _buildDaySelector(),
                    SizedBox(height: 22.h),
                    _buildSectionLabel('Time'),
                    SizedBox(height: 8.h),
                    _buildTimePicker(),
                    SizedBox(height: 16.h),
                    _buildMealChips(),
                    SizedBox(height: 22.h),
                    _buildNotificationToggle(),
                    SizedBox(height: 28.h),
                    _buildSaveButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = MedicineType.values;
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final type = types[i];
          final isSelected = _form.type == type;
          return GestureDetector(
            onTap: () => setState(() => _form.type = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? _primaryBlue : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? _primaryBlue.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _typeIcon(type, isSelected),
                  SizedBox(height: 6.h),
                  Text(
                    _typeLabel(type),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? _primaryBlue : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _typeIcon(MedicineType type, bool selected) {
    final IconData icon;
    switch (type) {
      case MedicineType.pills:
        icon = Icons.medication_rounded;
        break;
      case MedicineType.capsules:
        icon = Icons.vaccines_rounded;
        break;
      case MedicineType.liquid:
        icon = Icons.local_drink_rounded;
        break;
      case MedicineType.eyedrops:
        icon = Icons.opacity_rounded;
        break;
      case MedicineType.sachet:
        icon = Icons.inventory_2_rounded;
        break;
    }
    return Icon(
      icon,
      size: 28.sp,
      color: selected ? _primaryBlue : const Color(0xFF6C757D),
    );
  }

  String _typeLabel(MedicineType type) {
    switch (type) {
      case MedicineType.pills:
        return 'Pills';
      case MedicineType.capsules:
        return 'Capsules';
      case MedicineType.liquid:
        return 'Liquid';
      case MedicineType.eyedrops:
        return 'Eyedrops';
      case MedicineType.sachet:
        return 'Sachet';
    }
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: const Color(0xFFADB5BD),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildMilligramsAndDose() {
    return Row(
      children: [
        // Milligrams
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Milligrams'),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _mgCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '500',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xFFADB5BD),
                    ),
                    suffixText: 'mg',
                    suffixStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF6C757D),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: _primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        // Dose
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Dose'),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _doseCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: '1',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xFFADB5BD),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: _primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final isSelected = _form.selectedDays.contains(i);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _form.selectedDays.remove(i);
              } else {
                _form.selectedDays.add(i);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: isSelected ? _primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? _primaryBlue.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  days[i],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6C757D),
                  ),
                ),
                SizedBox(height: 2.h),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 18.sp,
                  color: isSelected ? Colors.white : const Color(0xFFCED4DA),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _form.time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: _primaryBlue,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) setState(() => _form.time = picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_rounded, size: 20.sp, color: _primaryBlue),
            SizedBox(width: 10.w),
            Text(
              _formatTime(_form.time),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: const Color(0xFF6C757D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealChips() {
    const instructions = ['After Meal', 'Before Meal', 'While Eating'];
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: instructions.map((label) {
        final isSelected = _form.mealInstruction == label;
        return GestureDetector(
          onTap: () => setState(() => _form.mealInstruction = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? _primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? _primaryBlue : const Color(0xFFCED4DA),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6C757D),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        CupertinoSwitch(
          value: _form.notificationEnabled,
          activeTrackColor: _primaryBlue,
          onChanged: (v) => setState(() => _form.notificationEnabled = v),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryBlue.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
          shadowColor: _primaryBlue.withValues(alpha: 0.4),
        ),
        child: _isSaving
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                _isEdit ? 'Save Changes' : 'Add Medicine',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _onSave() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Build dosage string from milligrams + dose count
      final mg = _mgCtrl.text.trim();
      final dose = _doseCtrl.text.trim();
      String? dosage;
      if (mg.isNotEmpty) {
        dosage = '${mg}mg';
        if (dose.isNotEmpty && dose != '1') dosage = '$dosage x $dose';
      }

      // Build frequency string from selected days
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
      final selectedDayNames = _form.selectedDays.toList()
        ..sort();
      final frequency = selectedDayNames.length == 5
          ? 'Daily'
          : selectedDayNames.map((i) => dayLabels[i]).join(',');

      final med = MedicationModel(
        userId: userId,
        name: name,
        dosage: dosage,
        frequency: frequency,
        reminderTime: _form.time,
      );

      await ref.read(medicationsProvider.notifier).addMedication(med);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added successfully!'),
            backgroundColor: _primaryBlue,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
