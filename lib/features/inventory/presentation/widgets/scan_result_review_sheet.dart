import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────
// Scan Result Review Sheet
//
// Displayed after AI scans a prescription. Shows the extracted data
// and lets the user verify, edit, and add missing info (e.g. meal
// instruction) before proceeding to AddEditMedicinePage.
// ─────────────────────────────────────────────────────────────────────

class ScanResultReviewSheet extends StatefulWidget {
  final Map<String, dynamic> scannedData;

  const ScanResultReviewSheet({super.key, required this.scannedData});

  @override
  State<ScanResultReviewSheet> createState() => _ScanResultReviewSheetState();
}

class _ScanResultReviewSheetState extends State<ScanResultReviewSheet> {
  static const _primaryBlue = Color(0xFF38C2EE);

  late TextEditingController _nameCtrl;
  late TextEditingController _mgCtrl;
  late TextEditingController _doseCtrl;
  late String _selectedType;
  late String _selectedTime;
  String _mealInstruction = 'After Meal';

  static const _mealOptions = ['Before Meal', 'After Meal', 'While Eating'];

  @override
  void initState() {
    super.initState();
    final d = widget.scannedData;
    _nameCtrl = TextEditingController(text: d['name']?.toString() ?? '');
    _mgCtrl = TextEditingController(text: d['milligrams']?.toString() ?? '');
    _doseCtrl = TextEditingController(text: d['dose']?.toString() ?? '1');
    _selectedType = d['type']?.toString().toLowerCase() ?? 'pills';
    _selectedTime = d['time']?.toString() ?? '08:00';

    // Use AI-detected meal instruction if available, otherwise default
    final aiMeal = d['meal_instruction']?.toString() ?? '';
    if (_mealOptions.contains(aiMeal)) {
      _mealInstruction = aiMeal;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mgCtrl.dispose();
    _doseCtrl.dispose();
    super.dispose();
  }

  /// Returns the reviewed & edited data as a Map.
  Map<String, dynamic> _collectData() {
    return {
      'name': _nameCtrl.text.trim(),
      'milligrams': _mgCtrl.text.trim(),
      'dose': _doseCtrl.text.trim(),
      'type': _selectedType,
      'time': _selectedTime,
      'meal_instruction': _mealInstruction,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 12.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // ── Header ──
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: _primaryBlue, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Review Scanned Result',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                'Verify the details below and fill in any missing information.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: const Color(0xFF6C757D),
                ),
              ),
              SizedBox(height: 20.h),

              // ── Medicine Name ──
              _buildLabel('Medicine Name'),
              SizedBox(height: 6.h),
              _buildTextField(_nameCtrl, 'e.g. Amoxicillin'),
              SizedBox(height: 16.h),

              // ── Type + Milligrams + Dose row ──
              Row(
                children: [
                  // Type dropdown
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Type'),
                        SizedBox(height: 6.h),
                        _buildTypeDropdown(),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Milligrams
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('mg'),
                        SizedBox(height: 6.h),
                        _buildTextField(_mgCtrl, '500',
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Dose
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Dose'),
                        SizedBox(height: 6.h),
                        _buildTextField(_doseCtrl, '1',
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // ── Time ──
              _buildLabel('Time'),
              SizedBox(height: 6.h),
              _buildTimePicker(),
              SizedBox(height: 20.h),

              // ── Meal Instruction ──
              _buildLabel('Meal Instruction'),
              SizedBox(height: 8.h),
              _buildMealChips(),
              SizedBox(height: 24.h),

              // ── Confirm Button ──
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_collectData()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: Text(
                    'Confirm & Continue',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────

  /// Section label text.
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  /// Styled text field matching the app's design.
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
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
        keyboardType: keyboardType,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            color: const Color(0xFFADB5BD),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
          border: OutlineInputBorder(
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

  /// Dropdown for medicine type selection.
  Widget _buildTypeDropdown() {
    const types = ['pills', 'capsules', 'liquid', 'eyedrops', 'sachet'];
    const labels = {
      'pills': 'Pills',
      'capsules': 'Capsules',
      'liquid': 'Liquid',
      'eyedrops': 'Eyedrops',
      'sachet': 'Sachet',
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: types.contains(_selectedType) ? _selectedType : 'pills',
          isExpanded: true,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: Colors.black87,
          ),
          items: types
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(labels[t]!),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _selectedType = v);
          },
        ),
      ),
    );
  }

  /// Tappable time display that opens a time picker.
  Widget _buildTimePicker() {
    // Parse the time string
    final parts = _selectedTime.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '8') ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    final tod = TimeOfDay(hour: hour, minute: minute);

    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: tod,
        );
        if (picked != null) {
          setState(() {
            _selectedTime =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
            Icon(Icons.access_time_rounded,
                color: _primaryBlue, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              tod.format(context),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Selectable meal instruction chips.
  Widget _buildMealChips() {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _mealOptions.map((label) {
        final isSelected = _mealInstruction == label;
        return GestureDetector(
          onTap: () => setState(() => _mealInstruction = label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? _primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? _primaryBlue : const Color(0xFFCED4DA),
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
}
