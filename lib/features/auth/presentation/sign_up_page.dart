import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core Widgets
import 'package:nudge_rx/core/widgets/primary_button.dart';
import 'package:nudge_rx/core/widgets/text_input_field.dart';
import 'package:nudge_rx/core/widgets/toggle_password.dart';
import '/core/utils/password_validator.dart';
import '/core/widgets/password_strength_indicator.dart';

// ViewModel
import '../providers/auth_provider.dart';

// Feature Widgets
import 'widgets/signup_success_dialog.dart';
import 'widgets/signup_error_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Supabase.instance.client.auth.signOut();
    });
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

    // Observe ViewModel State
    ref.listen<AuthUiState>(authProvider, (previous, next) {
      if (next.isSuccess) {
        ref.read(authProvider.notifier).resetState();

        // Navigate to email verification page
        Navigator.pushNamed(
          context,
          '/email-verification',
          arguments: _emailController.text
              .trim(), // Passes the email to the router
        );
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => SignupErrorDialog(message: next.errorMessage!),
        );
      }
    });

    // UI View
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
                      // Already have an account? Log In
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
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
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
