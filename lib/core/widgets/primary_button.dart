import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: ShapeDecoration(
          color: Color(0xFF3DBDEC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          shadows: [
            BoxShadow(
              color: Color(0xFF000000),
              blurRadius: 6.r,
              offset: Offset(0, 4.h),
              spreadRadius: 0,
            ),
          ],
        ),

        // Button Text
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
