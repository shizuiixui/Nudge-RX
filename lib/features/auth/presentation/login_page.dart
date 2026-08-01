import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/features/auth/presentation/forgot_password.dart';
import '/core/widgets/text_input_field.dart';
import '../providers/auth_provider.dart';

import '/core/widgets/primary_button.dart';
import '/features/auth/presentation/sign_up_page.dart';
import '/features/homepage/presentation/homepage.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  Timer? _emailSyncDebounce;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_handleEmailChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).syncLoginLockState(emailController.text);
    });
  }

  void _handleEmailChanged() {
    _emailSyncDebounce?.cancel();
    _emailSyncDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      ref.read(authProvider.notifier).syncLoginLockState(emailController.text);
    });
  }

  @override
  void dispose() {
    _emailSyncDebounce?.cancel();
    emailController.removeListener(_handleEmailChanged);
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_loginFormKey.currentState!.validate()) {
      ref
          .read(authProvider.notifier)
          .signIn(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes
    ref.listen<AuthUiState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (next.isSuccess && (previous == null || !previous.isSuccess)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _LoginSuccessDialog(parentContext: context),
        );
      }
    });
    final authState = ref.watch(authProvider);
    final currentEmail = emailController.text.trim();
    final isEmailLocked = authState.isLockedForEmail(currentEmail);
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.h,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/Logo.png',
                            height: 70.h,
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // Title
                        Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Subtitle
                        Text(
                          'Login to check your medication schedule.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            color: const Color(0xFF6C757D),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        // Email Input Field
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: textInputField(
                            "name@example.com",
                            prefixIcon: Icons.email_rounded,
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // Password Input Field
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration:
                              textInputField(
                                "Enter your password",
                                prefixIcon: Icons.lock_rounded,
                              ).copyWith(
                                errorMaxLines: 3,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: Colors.grey,
                                    size: 24.sp,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                        ),

                        SizedBox(height: 14.h),

                        if (isEmailLocked) ...[
                          Text(
                            'Too many failed attempts. Try again after 30 minutes.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                          SizedBox(height: 14.h),
                        ],

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(
                                    email: emailController.text.trim(),
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3DBDEC),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        SizedBox(height: 20.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: PrimaryButton(
                            text: authState.isLoading
                                ? "Logging in..."
                                : "Login",
                            onPressed: (authState.isLoading || isEmailLocked)
                                ? null
                                : _submitLogin,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Don't have an account? Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
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
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign Up",
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

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginSuccessDialog extends StatefulWidget {
  final BuildContext parentContext;

  const _LoginSuccessDialog({required this.parentContext});

  @override
  State<_LoginSuccessDialog> createState() => _LoginSuccessDialogState();
}

class _LoginSuccessDialogState extends State<_LoginSuccessDialog> {
  @override
  void initState() {
    super.initState();
    // Capture navigators synchronously before the async gap.
    final dialogNav = Navigator.of(context);
    final pageNav = Navigator.of(widget.parentContext);
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      dialogNav.pop(); // close dialog
      pageNav.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
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
            // Success icon
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
              'Success',
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
                color: const Color(0xFF6C757D),
              ),
            ),
            SizedBox(height: 24.h),
            // Loader
            SizedBox(
              width: 36.w,
              height: 36.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF38C2EE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
