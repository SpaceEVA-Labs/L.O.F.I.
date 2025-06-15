import 'package:flutter/material.dart';
import 'screens/focus_screen.dart';
import 'player_state.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final playerState = await PlayerState.load();

  runApp(FocusVioletApp(initialState: playerState));
}

class FocusVioletApp extends StatelessWidget {
  final PlayerState initialState;

  const FocusVioletApp({super.key, required this.initialState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: violetLofiTheme,
      home: FocusScreen(state: initialState),
    );
  }
}
