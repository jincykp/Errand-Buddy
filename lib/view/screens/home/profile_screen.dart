import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const CustomAppBar(title: 'Profile'));
  }
}
