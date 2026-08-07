import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../inventory/models/medication_model.dart';
import '../../../inventory/providers/medication_provider.dart';

class MedicationCard extends ConsumerWidget {
  final MedicationModel med;

  const MedicationCard({super.key, required this.med});

  static const _primaryBlue = Color(0xFF38C2EE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medId = med.id ?? med.name;
    final statusMap = ref.watch(medicationStatusProvider);
    final status = statusMap[medId] ?? MedicationStatus.pending;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: status == MedicationStatus.taken
                      ? Colors.green.withValues(alpha: 0.15)
                      : status == MedicationStatus.skipped
                          ? Colors.redAccent.withValues(alpha: 0.15)
                          : _primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  status == MedicationStatus.taken
                      ? Icons.check_circle_rounded
                      : status == MedicationStatus.skipped
                          ? Icons.cancel_rounded
                          : Icons.medication_rounded,
                  color: status == MedicationStatus.taken
                      ? Colors.green
                      : status == MedicationStatus.skipped
                          ? Colors.redAccent
                          : _primaryBlue,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      med.dosage ?? '',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, size: 18.sp, color: Colors.black45),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            med.formattedTime,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              color: Colors.black54,
            ),
          ),
          Text(
            med.frequencyDisplay,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade200),
          SizedBox(height: 10.h),
          if (status == MedicationStatus.taken) ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Taken',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(medicationStatusProvider.notifier)
                        .resetStatus(medId);
                  },
                  child: Text(
                    'Undo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF6C757D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (status == MedicationStatus.skipped) ...[
            Row(
              children: [
                Icon(
                  Icons.cancel_rounded,
                  color: Colors.redAccent,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Skipped',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ref
                        .read(medicationStatusProvider.notifier)
                        .resetStatus(medId);
                  },
                  child: Text(
                    'Undo',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF6C757D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    label: 'Skip',
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: () {
                      ref
                          .read(medicationStatusProvider.notifier)
                          .markAsSkipped(medId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Skipped ${med.name}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ActionButton(
                    label: 'Done',
                    icon: Icons.check_rounded,
                    color: _primaryBlue,
                    onTap: () {
                      ref
                          .read(medicationStatusProvider.notifier)
                          .markAsTaken(medId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Marked ${med.name} as Taken!'),
                          backgroundColor: _primaryBlue,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Action Button 
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}