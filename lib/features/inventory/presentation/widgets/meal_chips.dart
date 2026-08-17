import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Wrap of selectable meal instruction chips (After Meal, Before Meal, While Eating).
class MealChips extends StatelessWidget {
  final String selectedInstruction;
  final ValueChanged<String> onInstructionSelected;
  final Color primaryColor;

  const MealChips({
    super.key,
    required this.selectedInstruction,
    required this.onInstructionSelected,
    required this.primaryColor,
  });

  static const _instructions = ['After Meal', 'Before Meal', 'While Eating'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _instructions.map((label) {
        final isSelected = selectedInstruction == label;
        return GestureDetector(
          onTap: () => onInstructionSelected(label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? primaryColor : const Color(0xFFCED4DA),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
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
