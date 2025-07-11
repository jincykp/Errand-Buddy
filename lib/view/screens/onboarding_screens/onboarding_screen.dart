import 'package:errandbuddy/providers/onboarding_provider.dart';
import 'package:errandbuddy/view/screens/home/home_screen.dart';
import 'package:errandbuddy/view/widgets/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, child) {
          return PageView.builder(
            controller: provider.pageController,
            onPageChanged: provider.updatePage,
            itemCount: provider.onboardingPages.length,
            itemBuilder: (context, index) {
              return OnboardingPage(
                data: provider.onboardingPages[index],
                onNext: () {
                  if (provider.isLastPage) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } else {
                    provider.nextPage();
                  }
                },
                onSkip: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
