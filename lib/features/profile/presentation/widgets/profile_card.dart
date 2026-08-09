import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCard extends StatelessWidget {
  final String fullName;
  final String email;
  final VoidCallback onLogout;
  final VoidCallback onAvatarTap;

  const ProfileCard({
    super.key,
    required this.fullName,
    required this.email,
    required this.onLogout,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar with Plus
        GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 36.sp,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38C2EE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        
        // Name and Email
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                email,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
        
        // Logout Button
        IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: Colors.black,
            size: 24.sp,
          ),
          onPressed: onLogout,
        ),
      ],
    );
  }
}
