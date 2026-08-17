import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/medicine_form_data.dart';

/// Row containing the left (milligrams/concentration/weight) and right
/// (dose/amount/quantity) input fields, with labels and suffixes driven
/// by the current [MedicineTypeConfig].
class MedicineInputFields extends StatelessWidget {
  final TextEditingController leftController;
  final TextEditingController rightController;
  final MedicineTypeConfig config;
  final Color primaryColor;

  const MedicineInputFields({
    super.key,
    required this.leftController,
    required this.rightController,
    required this.config,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left field (milligrams / concentration / weight)
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(config.leftTitle),
              SizedBox(height: 8.h),
              _inputField(
                controller: leftController,
                hint: '500',
                suffixText: config.leftSuffix,
              ),
            ],
          ),
        ),
        SizedBox(width: 14.w),
        // Right field (dose / amount / quantity)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel(config.rightTitle),
              SizedBox(height: 8.h),
              _inputField(
                controller: rightController,
                hint: '1',
                suffixText: config.rightSuffix,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
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

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String suffixText,
    TextAlign textAlign = TextAlign.start,
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
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: textAlign,
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
          suffixText: suffixText,
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
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
