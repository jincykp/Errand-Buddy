import 'package:errandbuddy/model/onboarding_data.dart';
import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  int get currentPage => _currentPage;
  PageController get pageController => _pageController;

  // Onboarding data
  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Simplify shared errands together',
      icon: Icons.task_alt_rounded,
      animationType: AnimationType.scale,
      animationDuration: Duration(seconds: 2),
      buttonText: 'Next',
    ),
    OnboardingData(
      title: 'Assign tasks to team members',
      icon: Icons.people_rounded,
      animationType: AnimationType.rotate,
      animationDuration: Duration(seconds: 3),
      buttonText: 'Next',
    ),
    OnboardingData(
      title: 'Never miss important tasks',
      icon: Icons.notifications_active_rounded,
      animationType: AnimationType.bounce,
      animationDuration: Duration(milliseconds: 1500),
      buttonText: 'Get Started',
    ),
  ];

  List<OnboardingData> get onboardingPages => _onboardingPages;

  bool get isLastPage => _currentPage == _onboardingPages.length - 1;

  void nextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void skipOnboarding() {
    _currentPage = _onboardingPages.length - 1;
    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void updatePage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
