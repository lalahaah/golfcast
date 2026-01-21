import 'package:flutter/material.dart';

class GolfLogo extends StatelessWidget {
  final double size;

  const GolfLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
