import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/core/utils/password_validator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 12.w, top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RuleRow(
            label: 'At least 8 characters',
            isMet: PasswordValidator.hasMinLength(password),
          ),
          SizedBox(height: 4.h),
          _RuleRow(
            label: 'At least 1 uppercase letter',
            isMet: PasswordValidator.hasUppercase(password),
          ),
          SizedBox(height: 4.h),
          _RuleRow(
            label: 'At least 1 number',
            isMet: PasswordValidator.hasNumber(password),
          ),
          SizedBox(height: 4.h),
          _RuleRow(
            label: 'At least 1 special character (!@#\$...)',
            isMet: PasswordValidator.hasSpecialChar(password),
          ),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool isMet;

  const _RuleRow({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    final color = isMet ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);

    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
            key: ValueKey<bool>(isMet),
            color: color,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 6.w),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            color: color,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
