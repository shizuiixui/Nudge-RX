import 'package:flutter/material.dart';
import 'package:nudge_rx/features/auth/presentation/email_verification.dart';
import 'package:nudge_rx/features/auth/presentation/forgot_password.dart';
import 'package:nudge_rx/features/auth/presentation/login_page.dart';
import 'package:nudge_rx/features/auth/presentation/sign_up_page.dart';
import 'package:nudge_rx/features/homepage/presentation/homepage.dart';
import 'package:nudge_rx/features/inventory/presentation/inventory.dart';

class AppRouter {
  static final ValueNotifier<int> navTabIndex = ValueNotifier<int>(0);

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/login': (context) => const LoginPage(),
      '/signup': (context) => const SignUpPage(),
      '/forgot-password': (context) => const ForgotPassword(email: ''),
      '/email-verification': (context) {
        final emailToVerify =
            ModalRoute.of(context)!.settings.arguments as String? ?? '';
        return EmailVerification(email: emailToVerify);
      },

      '/home': (context) => const HomePage(),
      '/inventory': (context) => const InventoryPage(),
      /* Removed for now, will be added back later
      '/profile': (context) => const ProfilePage(), 
      '/status': (context) => const StatusPage(),
      */
    };
  }
}
