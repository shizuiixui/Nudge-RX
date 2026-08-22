import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Core Widgets
import 'package:nudge_rx/core/widgets/toggle_password.dart';
import 'package:nudge_rx/core/widgets/text_input_field.dart';
import 'package:nudge_rx/core/widgets/primary_button.dart';

// Providers
import '../providers/auth_provider.dart';

// Feature Widgets
import 'widgets/login_success_dialog.dart';

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
            password: passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ViewModel State
    ref.listen<AuthUiState>(authProvider, (previous, next) {
      // Ignore state updates while this route is not the active page.
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
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
          builder: (ctx) => LoginSuccessDialog(parentContext: context),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final currentEmail = emailController.text.trim();
    final isEmailLocked = authState.isLockedForEmail(currentEmail);

    // UI View
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
                        Center(
                          child: Image.asset(
                            'assets/images/Logo.png',
                            height: 70.h,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          'Welcome!',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 6.h),
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
                                suffixIcon: TogglePassword(
                                  obscureText: obscurePassword,
                                  color: Colors.grey,
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
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: (16.sp).clamp(15.0, 16.5).toDouble(),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3DBDEC),
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),
                        SizedBox(height: 20.h),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 52.h,
                          child: PrimaryButton(
                            text: authState.isLoading
                                ? "Logging in..."
                                : "Login",
                            onPressed: (authState.isLoading || isEmailLocked)
                                ? null
                                : _submitLogin,
                            isLoading: authState.isLoading,
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
                                Navigator.pushNamed(context, '/signup');
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
