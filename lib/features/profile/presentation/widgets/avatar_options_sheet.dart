import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AvatarOptionsSheet extends StatelessWidget {
  final VoidCallback onViewPicture;
  final VoidCallback onSelectPicture;

  const AvatarOptionsSheet({
    super.key,
    required this.onViewPicture,
    required this.onSelectPicture,
  });

  /// Shows bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onViewPicture,
    required VoidCallback onSelectPicture,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => AvatarOptionsSheet(
        onViewPicture: onViewPicture,
        onSelectPicture: onSelectPicture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'Profile Photo',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20.h),

            // View Picture
            _OptionTile(
              icon: Icons.visibility_outlined,
              label: 'View Picture',
              onTap: () {
                Navigator.of(context).pop();
                onViewPicture();
              },
            ),
            const Divider(color: Color(0xFFEEEEEE), height: 1),

            // Select Picture
            _OptionTile(
              icon: Icons.photo_library_outlined,
              label: 'Select Picture',
              onTap: () {
                Navigator.of(context).pop();
                onSelectPicture();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF6FB),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22.sp, color: const Color(0xFF38C2EE)),
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
