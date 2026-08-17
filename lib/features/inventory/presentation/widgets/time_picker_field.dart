import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Tappable time display that opens a system time picker dialog.
class TimePickerField extends StatelessWidget {
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final Color primaryColor;

  const TimePickerField({
    super.key,
    required this.time,
    required this.onTimeChanged,
    required this.primaryColor,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: primaryColor,
                  onSurface: Colors.black87,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onTimeChanged(picked);
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
            Icon(Icons.access_time_rounded,
                size: 20.sp, color: primaryColor),
            SizedBox(width: 10.w),
            Text(
              _formatTime(time),
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
}
