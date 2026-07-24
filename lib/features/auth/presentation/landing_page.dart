import 'package:flutter/material.dart';
import 'sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/clean-landing-page.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Personal',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const Text(
                'Medication Organizer',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38C2EE),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle Text
              const Text(
                'Simplify tracking, scheduling, and reminders for all your prescriptions',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C757D),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),
              // "Get Started" Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38C2EE),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x6638C2EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
