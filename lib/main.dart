import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/chart_utils_fix.dart';
import 'screens/focus_screen.dart';
import 'screens/splash_screen.dart';
import 'player_state.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/audio_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Apply fixes for fl_chart package
  _applyFlChartFix();

  // Initialize audio service
  await AudioService().initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
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
  bool _isLoading = true;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _currentThemeOption = themeOptions[0]; // Default to first theme
    _playerState = PlayerState.empty(); // Use the named constructor
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedTheme();
    await _loadPlayerState();
    setState(() {
      _isLoading = false;
    });

    // Shorter delay for splash screen to minimize double splash effect
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
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

      // Save the state immediately to ensure it's properly stored
      loadedState.save();
    } catch (e) {
      print("❌ Error loading player state: $e");
      setState(() {
        _playerState = PlayerState.empty();
      });
      // Save the empty state to initialize storage
      _playerState.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _currentThemeOption.theme,
      home: _showSplash
          ? SplashScreen(
              onComplete: () {
                setState(() {
                  _showSplash = false;
                });
              },
            )
          : FocusScreen(
              state: _playerState,
              themeOption: _currentThemeOption,
              onThemeChanged: _updateTheme,
              onStateChanged: (PlayerState newState) {
                setState(() {
                  _playerState = newState;
                });
              },
            ),
    );
  }
}
