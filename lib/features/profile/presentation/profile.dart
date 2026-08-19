import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/providers/auth_provider.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/notification_tile.dart';
import 'widgets/profile_card.dart';
import 'widgets/settings_tile.dart';
import 'user_profile.dart';
import 'change_password.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _pushNotificationsEnabled = true;

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutDialog(
        onConfirm: () async {
          await ref.read(authProvider.notifier).signOut();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24.h),
              
              // Profile Card Component
              ProfileCard(
                fullName: fullName,
                email: email,
                onLogout: () => _showLogoutConfirmation(context),
                onAvatarTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfilePage(),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
              
              SizedBox(height: 24.h),
              const Divider(color: Color(0xFFD0E6F0), thickness: 1),
              SizedBox(height: 16.h),
              
              // Settings Items 
              SettingsTile(
                icon: Icons.person,
                title: 'User Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserProfilePage(),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              ),
              SizedBox(height: 16.h),
              SettingsTile(
                icon: Icons.lock,
                title: 'Change Password',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),
              NotificationTile(
                value: _pushNotificationsEnabled,
                onChanged: (val) {
                  setState(() {
                    _pushNotificationsEnabled = val;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
