import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'sign_up_page.dart';
import '/core/widgets/primary_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/images/clean-landing-page.png',
                    height: 400.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 27.h),
              Text(
                'Your Personal',
                style: TextStyle(
                  fontSize: 27.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              Text(
                'Medication Organizer',
                style: TextStyle(
                  fontSize: 27.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF38C2EE),
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              // Subtitle Text
              Text(
                'Simplify tracking, scheduling, and reminders for all your prescriptions',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF6C757D),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 36.h),
              // "Get Started" Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: PrimaryButton(
                  text: "Get Started",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
