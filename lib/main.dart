import 'package:flutter/material.dart';
import 'screens/focus_screen.dart';
import 'theme.dart';

void main() {
  runApp(FocusVioletApp());
}

class FocusVioletApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: violetLofiTheme,
      home: FocusScreen(),
    );
  }
}
