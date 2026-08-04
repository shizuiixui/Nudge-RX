import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/core/widgets/primary_button.dart';
import 'package:nudge_rx/core/widgets/text_input_field.dart';
import 'package:nudge_rx/core/widgets/toggle_password.dart';
import '/core/utils/password_validator.dart';
import '/core/widgets/password_strength_indicator.dart';
import '../providers/auth_provider.dart';
import '/features/auth/presentation/login_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(authProvider.notifier)
        .signUp(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for state changes
    ref.listen<AuthUiState>(authProvider, (previous, next) {
      if (next.isSuccess) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38C2EE),
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
                    'Successful Account Creation',
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
                    'Your account has been created.\nYou can now log in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38C2EE),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                      ),
                      child: Text(
                        'Continue to Login',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (next.errorMessage != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 36.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Email Existing',
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
                    'Check your credentials.\nEmail is already registered.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      color: const Color(0xFF6C757D),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),

                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/Logo.png',
                          height: 70.h,
                        ),
                      ),
                      SizedBox(height: 28.h),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Create an account to never miss a dose.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: textInputField(
                          'Full Name',
                          prefixIcon: Icons.person_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: textInputField(
                          'Enter your email',
                          prefixIcon: Icons.email_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() {}),
                        decoration:
                            textInputField(
                              'Create Password',
                              prefixIcon: Icons.lock_rounded,
                            ).copyWith(
                              suffixIcon: TogglePassword(
                                obscureText: _obscurePassword,
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                        validator: PasswordValidator.validate,
                      ),
                      if (_passwordController.text.isNotEmpty)
                        PasswordStrengthIndicator(
                          password: _passwordController.text,
                        ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration:
                            textInputField(
                              'Re-type Your Password',
                              prefixIcon: Icons.lock_rounded,
                            ).copyWith(
                              suffixIcon: TogglePassword(
                                obscureText: _obscureConfirmPassword,
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 40.h,
                        child: PrimaryButton(
                          isLoading: authState.isLoading,
                          text: authState.isLoading
                              ? 'Creating...'
                              : 'Create Account',
                          onPressed: authState.isLoading ? null : _handleSignUp,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF3DBDEC),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
