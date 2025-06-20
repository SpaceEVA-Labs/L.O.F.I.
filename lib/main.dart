import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/chart_utils_fix.dart';
import 'screens/focus_screen.dart';
import 'player_state.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Apply fixes for fl_chart package
  _applyFlChartFix();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

/// Apply fixes for the fl_chart package
void _applyFlChartFix() {
  // This is where we would monkey patch the fl_chart package if needed
  // For now, we're handling it through our wrapper classes
  ChartUtilsFix.applyFixes();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeOption _currentThemeOption;
  late PlayerState _playerState;

  @override
  void initState() {
    super.initState();
    _currentThemeOption = themeOptions[0]; // Default to first theme
    _playerState = PlayerState.empty(); // Use the named constructor
    _loadSavedTheme();
    _loadPlayerState();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('selected_theme_index') ?? 0;
    if (themeIndex < themeOptions.length) {
      setState(() {
        _currentThemeOption = themeOptions[themeIndex];
      });
    }
  }

  void _updateTheme(ThemeOption newTheme) async {
    setState(() {
      _currentThemeOption = newTheme;
    });

    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = themeOptions.indexWhere((t) => t.name == newTheme.name);
    await prefs.setInt('selected_theme_index', themeIndex);
  }

  Future<void> _loadPlayerState() async {
    try {
      final loadedState = await PlayerState.load();
      setState(() {
        _playerState = loadedState;
      });
      print(
        "✅ Loaded player state: ${loadedState.totalPoints} points, ${loadedState.dailyPoints.length} days",
      );
    } catch (e) {
      print("❌ Error loading player state: $e");
      setState(() {
        _playerState = PlayerState.empty();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _currentThemeOption.theme,
      home: FocusScreen(
        state: _playerState,
        themeOption: _currentThemeOption,
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
