import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/core/routes/app_router.dart';
import 'package:nudge_rx/core/widgets/loading_indicator.dart';

class LoginSuccessDialog extends StatefulWidget {
  final BuildContext parentContext;

  const LoginSuccessDialog({super.key, required this.parentContext});

  @override
  State<LoginSuccessDialog> createState() => _LoginSuccessDialogState();
}

class _LoginSuccessDialogState extends State<LoginSuccessDialog> {
  @override
  void initState() {
    super.initState();
    // Capture navigators synchronously
    final dialogNav = Navigator.of(context);
    final pageNav = Navigator.of(widget.parentContext);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      dialogNav.pop(); // Close dialog

      pageNav.pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Success!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You are now logged in.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                color: const Color(0XFF6C757D),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 36.w,
              height: 36.h,
              child: const LoadingIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
