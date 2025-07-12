import 'package:errandbuddy/view/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class EscalationsScreen extends StatelessWidget {
  const EscalationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const CustomAppBar(title: 'Escalation Log'));
  }
}
