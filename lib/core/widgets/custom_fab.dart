import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/features/inventory/presentation/add_edit_medicine_page.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key});

  static const _primaryBlue = Color(0xFf38C2EE);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 37.w,
      height: 37.w,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditMedicinePage()),
          );
        },
        backgroundColor: _primaryBlue,
        elevation: 4,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white, width: 2.w),
        ),
        child: Image.asset(
          'assets/images/navbar/FAB.png',
          width: 24.w,
          height: 24.w,
        ),
      ),
    );
  }
}
