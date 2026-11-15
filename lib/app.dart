
import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';

class BookadowApp extends StatelessWidget {
  const BookadowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOOKADOW',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
