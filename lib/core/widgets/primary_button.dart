import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/core/widgets/loading_indicator.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Screen Size
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 600;
    final buttonWidth = isTablet ? 280.w : 328.w;
    final buttonHeight = isTablet ? 40.h : 50.h;
    final borderRadius = isTablet ? 24.r : 30.r;
    final fontSize = isTablet ? 15.sp : 16.5.sp;
    final isDisabled = onPressed == null;

    return Opacity(
      opacity: isDisabled ? 0.65 : 1,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: buttonWidth,
          height: buttonHeight,
          decoration: ShapeDecoration(
            color: const Color(0xFF3DBDEC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),

          // Button Text
          child: Center(
            child: isLoading
                ? SizedBox(height: 24.h, width: 24.w, child: LoadingIndicator())
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
