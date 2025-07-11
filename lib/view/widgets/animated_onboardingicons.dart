import 'package:errandbuddy/model/onboarding_data.dart';
import 'package:flutter/material.dart';

class AnimatedOnboardingIcon extends StatefulWidget {
  final IconData icon;
  final AnimationType animationType;
  final Duration duration;

  const AnimatedOnboardingIcon({
    Key? key,
    required this.icon,
    required this.animationType,
    required this.duration,
  }) : super(key: key);

  @override
  _AnimatedOnboardingIconState createState() => _AnimatedOnboardingIconState();
}

class _AnimatedOnboardingIconState extends State<AnimatedOnboardingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    switch (widget.animationType) {
      case AnimationType.scale:
        _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat(reverse: true);
        break;
      case AnimationType.rotate:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        _controller.repeat();
        break;
      case AnimationType.bounce:
        _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
        );
        _controller.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        switch (widget.animationType) {
          case AnimationType.scale:
            return Transform.scale(
              scale: _animation.value,
              child: Icon(widget.icon, size: 120, color: Colors.white),
            );
          case AnimationType.rotate:
            return Transform.rotate(
              angle: _animation.value * 2 * 3.14159,
              child: Icon(widget.icon, size: 120, color: Colors.white),
            );
          case AnimationType.bounce:
            return Transform.translate(
              offset: Offset(0, _animation.value * -20),
              child: Icon(widget.icon, size: 120, color: Colors.white),
            );
        }
      },
    );
  }
}
