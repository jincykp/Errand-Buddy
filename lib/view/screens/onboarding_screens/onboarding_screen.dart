import 'package:errandbuddy/providers/onboarding_provider.dart';
import 'package:errandbuddy/view/screens/home/home_screen.dart';
import 'package:errandbuddy/view/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Function to set first time flag to false
  Future<void> _setFirstTimeFalse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
    } catch (e) {
      // Handle error silently - app will still work
      debugPrint('Error saving first time preference: $e');
    }
  }

  // Function to navigate to home screen
  Future<void> _navigateToHome(BuildContext context) async {
    await _setFirstTimeFalse();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: PageView.builder(
              controller: provider.pageController,
              onPageChanged: provider.updatePage,
              itemCount: provider.onboardingPages.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  data: provider.onboardingPages[index],
                  onNext: () {
                    if (provider.isLastPage) {
                      _navigateToHome(context);
                    } else {
                      provider.nextPage();
                    }
                  },
                  onSkip: () {
                    _navigateToHome(context);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
