import 'dart:async';
import 'package:errandbuddy/view/screens/onboarding_screens/onboarding_screen.dart';
import 'package:errandbuddy/view/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    try {
      // Wait for 3 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 3));

      // Check if it's the first time opening the app
      final isFirstTime = await _checkFirstTime();

      if (mounted) {
        if (isFirstTime) {
          // First time - navigate to onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        } else {
          // Not first time - navigate directly to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      // If there's any error, treat as first time and show onboarding
      debugPrint('Splash screen error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    }
  }

  Future<bool> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isFirstTime') ?? true;
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
      return true; // Default to first time if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A5555),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/splash_img.png'),
            const SizedBox(height: 20),
            const Text(
              'ERRAND BUDDY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
