import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../inventory/models/medication_model.dart';
import '../../../inventory/providers/medication_provider.dart';
import '../../../inventory/models/medicine_form_data.dart';
import '../../../inventory/presentation/add_edit_medicine_page.dart';

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
      padding: EdgeInsets.all(16.w),
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
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: status == MedicationStatus.taken
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 36.sp,
                      )
                    : status == MedicationStatus.skipped
                    ? Icon(
                        Icons.cancel_rounded,
                        color: Colors.redAccent,
                        size: 36.sp,
                      )
                    : Image.asset(med.categoryAssetPath, fit: BoxFit.contain),
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
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      med.dosage ?? '',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Text(
                      med.formattedTime,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      med.mealInstruction ?? 'After Meal',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // 3-dot menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 22.sp, color: Colors.black87),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddEditMedicinePage(
                          existing: MedicineFormData.fromModel(med),
                        ),
                      ),
                    );
                  } else if (value == 'delete') {
                    if (med.id == null) return;
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Medication'),
                        content: Text(
                          'Are you sure you want to delete ${med.name}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      try {
                        await ref
                            .read(medicationsProvider.notifier)
                            .deleteMedication(med.id!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${med.name} deleted successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: Colors.grey.shade300),
          SizedBox(height: 12.h),

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
                      fontSize: 13.sp,
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
                      fontSize: 13.sp,
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
          Icon(icon, size: 18.sp, color: color), // Slightly bumped up icon size
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp, // Bumped up font size for buttons
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
