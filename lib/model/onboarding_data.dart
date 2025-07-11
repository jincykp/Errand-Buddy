import 'package:flutter/material.dart';

class OnboardingData {
  final String title;
  final IconData icon;
  final AnimationType animationType;
  final Duration animationDuration;
  final String buttonText;

  OnboardingData({
    required this.title,
    required this.icon,
    required this.animationType,
    required this.animationDuration,
    required this.buttonText,
  });
}

enum AnimationType { scale, rotate, bounce }
