import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<int> onDayToggled;
  final Color primaryColor;

  const DaySelector({
    super.key,
    required this.selectedDays,
    required this.onDayToggled,
    required this.primaryColor,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 2.w),
        child: Row(
          children: List.generate(_days.length, (i) {
            final isSelected = selectedDays.contains(i);
            return Padding(
              padding: EdgeInsets.only(right: i == _days.length - 1 ? 0 : 8.w),
              child: GestureDetector(
                onTap: () => onDayToggled(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.3)
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
                        _days[i],
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6C757D),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 18.sp,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFCED4DA),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
