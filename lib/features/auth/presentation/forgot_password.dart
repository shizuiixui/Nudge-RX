import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nudge_rx/core/widgets/primary_button.dart';
import 'package:nudge_rx/core/widgets/text_input_field.dart';
import 'package:nudge_rx/core/widgets/toggle_password.dart';
import '/core/utils/password_validator.dart';
import '/core/widgets/password_strength_indicator.dart';
import '../providers/auth_provider.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  final String email;
  const ForgotPassword({super.key, required this.email});

  @override
  ConsumerState<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  // Form Key
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final PageController _controller = PageController();

  // Password State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // OTP State
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  bool _isLoading = false;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(
      text: widget.email,
    ); // Initialize controller
  }

  // Dispose controllers
  @override
  void dispose() {
    _countdownTimer?.cancel();
    emailController.dispose();
    _controller.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Handle sending reset email
  void _handleSendEmail() async {
    if (_emailFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Future.delayed(const Duration(milliseconds: 1800));
        await ref
            .read(authProvider.notifier)
            .requestPasswordReset(emailController.text.trim());
        if (!mounted) return;
        if (ref.read(authProvider).errorMessage == null) {
          _controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _startResendCountdown();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Handle OTP verification
  Future<void> _handleVerify() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 1800));

      // Trigger OTP verification
      await ref
          .read(authProvider.notifier)
          .verifyResetOtp(email: emailController.text.trim(), otpCode: otp);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Handle password reset
  void _handleResetPassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Future.delayed(const Duration(milliseconds: 1800));
        await ref
            .read(authProvider.notifier)
            .updatePassword(_passwordController.text);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Resend Code Countdown Timer
  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch global state for auth changes
    final authState = ref.watch(authProvider);
    // Listen to auth state changes
    ref.listen<AuthUiState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        // Error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }

      // Handle OTP verification
      if (next.isOTPVerified && previous?.isOTPVerified == false) {
        _controller.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }

      // Handle Password Update Success
      if (next.isSuccess && previous?.isSuccess == false) {
        _controller.animateToPage(
          3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 1st Page: Email Form
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _emailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reset your password",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Please enter your email and we will send an OTP code in the next step to reset your password.",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Noto-Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: textInputField(
                          "Enter your email",
                          prefixIcon: Icons.email_rounded,
                        ),
                      ),
                      SizedBox(height: 60.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: PrimaryButton(
                          isLoading: authState.isLoading,
                          text: authState.isLoading
                              ? "Sending..."
                              : "Send Reset Code",
                          onPressed: authState.isLoading
                              ? null
                              : _handleSendEmail,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // 2nd Page: OTP Verification
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OTP Verification",
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  SizedBox(
                    width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Enter the code sent to \n",
                            style: TextStyle(
                              color: const Color(0xFF000000),
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                            ),
                          ),
                          TextSpan(
                            text: emailController.text,
                            style: TextStyle(
                              color: const Color(0xFF000000),
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: 45.w,
                        height: 50.h,
                        child: TextFormField(
                          controller: _otpControllers[i],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: i == 0,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(1),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.length == 1 && i < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && i > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFFFFFF),
                            contentPadding: EdgeInsets.zero,
                            // Normal state border (gray)
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            // Active typing state border
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF3DBDEC),
                                width: 2,
                              ),
                            ),
                            // Error state border
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : PrimaryButton(
                            text: "Verify",
                            onPressed: _isLoading ? null : _handleVerify,
                            isLoading: _isLoading,
                          ),
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: _resendCountdown == 0
                        ? () async {
                            await ref
                                .read(authProvider.notifier)
                                .requestPasswordReset(
                                  emailController.text.trim(),
                                );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "OTP code resent successfully.",
                                  ),
                                ),
                              );
                            }
                            _startResendCountdown();
                          }
                        : null,
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "Didn't receive a code? ",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: _resendCountdown > 0
                                    ? "Resend in ${_resendCountdown}s"
                                    : "Resend Code",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  color: _resendCountdown > 0
                                      ? const Color(0xFF9E9E9E)
                                      : const Color(0xFF3DBDEC),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3rd Page: Create New Password
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create a new password",
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "Your new password must be different from previous password.",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Noto-Sans',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() {}),
                        decoration:
                            textInputField(
                              'Create Password',
                              prefixIcon: Icons.lock_outline,
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
                              prefixIcon: Icons.lock_outline,
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
                      SizedBox(height: 60.h),
                      SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: PrimaryButton(
                          text: (_isLoading || authState.isLoading)
                              ? "Saving..."
                              : "Continue",
                          isLoading: _isLoading || authState.isLoading,
                          onPressed: (_isLoading || authState.isLoading)
                              ? null
                              : _handleResetPassword,
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // Success Page
            SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  Icon(
                    Icons.check_circle_outline,
                    color: const Color(0xFF3DBDEC),
                    size: 100.sp,
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "Password Updated",
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "Your password has been successfully updated. You can now log in with your new password.",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 60.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: PrimaryButton(
                      isLoading: _isLoading,
                      text: "Continue",
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await Future.delayed(
                                const Duration(milliseconds: 1800),
                              );
                              if (!mounted) return;

                              ref.read(authProvider.notifier).resetState();
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
