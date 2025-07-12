// lib/widgets/custom_fab.dart

import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFAB({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      elevation: 0,
      shape: const CircleBorder(),
      fillColor: Colors.transparent,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      child: Image.asset(
        'assets/images/fab.png',
        fit: BoxFit.contain,
        width: 56,
        height: 56,
      ),
    );
  }
}
