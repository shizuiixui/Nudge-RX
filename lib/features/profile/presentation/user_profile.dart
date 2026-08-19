import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/user_profile_widget_helpers.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late String _initialEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = user?.userMetadata?['full_name'] as String? ?? '';
    final email = user?.email ?? '';

    _nameController = TextEditingController(text: fullName);
    _emailController = TextEditingController(text: email);
    _passwordController = TextEditingController();
    _initialEmail = email;

    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newEmail = _emailController.text.trim();
    final emailChanged = newEmail != _initialEmail;

    try {
      if (emailChanged) {
        final currentEmail = Supabase.instance.client.auth.currentUser?.email;
        if (currentEmail != null) {
          // Re-authenticate user to confirm current password
          await Supabase.instance.client.auth.signInWithPassword(
            email: currentEmail,
            password: _passwordController.text,
          );
        }
      }

      final updates = UserAttributes(
        email: emailChanged ? newEmail : null,
        data: {'full_name': _nameController.text.trim()},
      );

      await Supabase.instance.client.auth.updateUser(updates);

      if (mounted) {
        if (emailChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated! Check your new inbox for a verification link to complete the email change.',
              ),
              backgroundColor: Color(0xFF38C2EE),
              duration: Duration(
                seconds: 5,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Color(0xFF38C2EE),
            ),
          );
        }

        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (errMsg.contains('Invalid login credentials') ||
            errMsg.contains('invalid_credentials')) {
          errMsg = 'Incorrect current password. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $errMsg'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPasswordVerification =
        _emailController.text.trim() != _initialEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserProfileInputField(
                  label: 'Full Name',
                  hintText: 'Enter your name',
                  controller: _nameController,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                UserProfileInputField(
                  label: 'Email Address',
                  hintText: 'Enter your email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                if (showPasswordVerification) ...[
                  SizedBox(height: 20.h),
                  UserProfileInputField(
                    label: 'Confirm Current Password',
                    hintText: 'Enter your password to change email',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required to change email';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 40.h),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38C2EE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: const Color(
                      0xFF38C2EE,
                    ).withValues(alpha: 0.6),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
