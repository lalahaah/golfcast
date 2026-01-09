import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: GolfCastApp()));
}

class GolfCastApp extends StatelessWidget {
  const GolfCastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GolfCast',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
