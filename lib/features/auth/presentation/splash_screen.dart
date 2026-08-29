import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // Check if user is authenticated
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      if (session.isExpired) {
        try {
          final res = await Supabase.instance.client.auth.refreshSession();
          if (res.session != null && mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
            return;
          }
        } catch (_) {
          // Token refresh failed or revoked
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
        return;
      }

      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/Logo.png', width: 600),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0XFF38C2EE)),
            ),
          ],
        ),
      ),
    );
  }
}
