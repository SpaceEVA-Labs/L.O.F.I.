import 'package:flutter/material.dart';

/// A utility class to fix compatibility issues with fl_chart package
class ChartUtilsFix {
  /// Replacement for MediaQuery.boldTextOverride which was deprecated
  static bool boldTextOverride(BuildContext context) {
    // Use the new API
    return MediaQuery.boldTextOf(context);
  }

  /// Apply all fixes to make fl_chart work with newer Flutter versions
  static void applyFixes() {
    // This method will be called at app startup to apply any necessary patches
    // Currently empty as we're handling fixes at usage points
  }
}
