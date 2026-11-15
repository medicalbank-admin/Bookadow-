import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

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

      localizationsDelegates:
          FlutterQuillLocalizations.localizationsDelegates,

      supportedLocales:
          FlutterQuillLocalizations.supportedLocales,

      home: const HomeScreen(),
    );
  }
}
