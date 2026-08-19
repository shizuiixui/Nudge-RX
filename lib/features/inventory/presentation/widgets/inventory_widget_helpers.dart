import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../inventory.dart';
import '../../providers/medication_provider.dart';
import '../../models/medicine_form_data.dart';
import '../add_edit_medicine_page.dart';

class InventorySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const InventorySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: const Color(0xFFADB5BD),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 10.w),
            child: Icon(
              Icons.search_rounded,
              color: Colors.black45,
              size: 22.sp,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 44.w),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class InventorySegmentToggle extends StatelessWidget {
  final bool showActive;
  final ValueChanged<bool> onToggle;

  const InventorySegmentToggle({
    super.key,
    required this.showActive,
    required this.onToggle,
  });

  static const _primaryBlue = Color(0xFF38C2EE);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onToggle(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              decoration: BoxDecoration(
                color: showActive ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: showActive ? _primaryBlue : const Color(0xFFCED4DA),
                  width: 1,
                ),
                boxShadow: showActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: showActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: GestureDetector(
            onTap: () => onToggle(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48.h,
              decoration: BoxDecoration(
                color: !showActive ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: !showActive ? _primaryBlue : const Color(0xFFCED4DA),
                  width: 1,
                ),
                boxShadow: !showActive
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  'Completed',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: !showActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InventoryCard extends ConsumerWidget {
  final InventoryItem item;

  const InventoryCard({
    super.key,
    required this.item,
  });

  static const _primaryBlue = Color(0xFF38C2EE);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double progressRatio = item.totalCount > 0
        ? (item.takenCount / item.totalCount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: item.imagePath != null
                ? Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Image.asset(
                      item.imagePath!,
                      fit: BoxFit.contain,
                    ),
                  )
                : Icon(item.iconData, color: item.iconColor, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.dosageInfo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF6C757D),
                  ),
                ),
                if (item.isLowStock) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Low Stock',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          SizedBox(
            width: 44.w,
            height: 44.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 42.w,
                  height: 42.w,
                  child: CircularProgressIndicator(
                    value: progressRatio,
                    strokeWidth: 3.5.w,
                    backgroundColor: const Color(0xFFE0E0E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      _primaryBlue,
                    ),
                  ),
                ),
                Text(
                  '${item.takenCount}/${item.totalCount}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.black45,
              size: 20.sp,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onSelected: (value) async {
              final med = item.medication;
              if (med == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample items cannot be edited or deleted.'),
                  ),
                );
                return;
              }

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
                      Icons.edit,
                      size: 20,
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
                      Icons.delete,
                      size: 20,
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
    );
  }
}

class InventoryEmptyState extends StatelessWidget {
  final bool showActive;

  const InventoryEmptyState({
    super.key,
    required this.showActive,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 56.sp,
            color: const Color(0xFFB0DCF0),
          ),
          SizedBox(height: 12.h),
          Text(
            showActive ? 'No active medications' : 'No completed medications',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              color: const Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
