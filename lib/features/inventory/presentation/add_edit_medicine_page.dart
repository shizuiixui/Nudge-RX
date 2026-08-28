import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication_model.dart';
import '../models/medicine_form_data.dart';
import '../providers/medication_provider.dart';
import 'widgets/medicine_type_selector.dart';
import 'widgets/medicine_input_fields.dart';
import 'widgets/day_selector.dart';
import 'widgets/time_picker_field.dart';
import 'widgets/meal_chips.dart';

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

  bool get _isEdit => widget.existing?.id != null;

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
                    MedicineTypeSelector(
                      selectedType: _form.type,
                      onTypeSelected: (type) => setState(() {
                        _form.type = type;
                        _mgCtrl.clear();
                        _doseCtrl.clear();
                      }),
                      primaryColor: _primaryBlue,
                    ),
                    SizedBox(height: 22.h),
                    _buildSectionLabel('Medicine name'),
                    SizedBox(height: 8.h),
                    _buildTextField(_nameCtrl, 'Enter medicine name'),
                    SizedBox(height: 22.h),
                    MedicineInputFields(
                      leftController: _mgCtrl,
                      rightController: _doseCtrl,
                      config: typeConfigs[_form.type]!,
                      primaryColor: _primaryBlue,
                    ),
                    SizedBox(height: 22.h),
                    DaySelector(
                      selectedDays: _form.selectedDays,
                      onDayToggled: (i) {
                        setState(() {
                          final updatedDays = _form.selectedDays.toSet();
                          if (updatedDays.contains(i)) {
                            updatedDays.remove(i);
                          } else {
                            updatedDays.add(i);
                          }
                          _form.selectedDays = updatedDays;
                        });
                      },
                      primaryColor: _primaryBlue,
                    ),
                    SizedBox(height: 22.h),
                    _buildSectionLabel('Time'),
                    SizedBox(height: 8.h),
                    TimePickerField(
                      time: _form.time,
                      onTimeChanged: (t) => setState(() => _form.time = t),
                      primaryColor: _primaryBlue,
                    ),
                    SizedBox(height: 16.h),
                    MealChips(
                      selectedInstruction: _form.mealInstruction,
                      onInstructionSelected: (label) =>
                          setState(() => _form.mealInstruction = label),
                      primaryColor: _primaryBlue,
                    ),
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

  // ── Small inline helpers ──────────────────────────────────────────

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
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
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

  // ── Save logic ────────────────────────────────────────────────────

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
      final cfg = typeConfigs[_form.type]!;

      // Build dosage string from left + right fields using type-specific suffixes
      final mg = _mgCtrl.text.trim();
      final dose = _doseCtrl.text.trim();
      String? dosage;
      if (mg.isNotEmpty && dose.isNotEmpty) {
        dosage = '$mg${cfg.leftSuffix} - $dose ${cfg.rightSuffix}';
      } else if (mg.isNotEmpty) {
        dosage = '$mg${cfg.leftSuffix}';
      } else if (dose.isNotEmpty) {
        dosage = '$dose ${cfg.rightSuffix}';
      }
      // Build frequency string from selected days
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final selectedDayNames = _form.selectedDays.toList()..sort();
      final frequency = selectedDayNames.length == 5
          ? 'Daily'
          : selectedDayNames.map((i) => dayLabels[i]).join(',');

      final med = MedicationModel(
        id: _form.id,
        userId: userId,
        name: name,
        dosage: dosage,
        frequency: frequency,
        reminderTime: _form.time,
        mealInstruction: _form.mealInstruction,
      );

      if (_isEdit) {
        await ref.read(medicationsProvider.notifier).updateMedication(med);
      } else {
        await ref.read(medicationsProvider.notifier).addMedication(med);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit
                  ? '$name updated successfully!'
                  : '$name added successfully!',
            ),
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
