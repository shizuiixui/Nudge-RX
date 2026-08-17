import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/medicine_form_data.dart';

/// Horizontal scrollable list of medicine type icons with selection state.
class MedicineTypeSelector extends StatelessWidget {
  final MedicineType selectedType;
  final ValueChanged<MedicineType> onTypeSelected;
  final Color primaryColor;

  const MedicineTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final types = MedicineType.values;
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (_, i) {
          final type = types[i];
          final isSelected = selectedType == type;
          final cfg = typeConfigs[type]!;
          return GestureDetector(
            onTap: () => onTypeSelected(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 68.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    cfg.asset,
                    width: 40.sp,
                    height: 40.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    cfg.label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? primaryColor : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
