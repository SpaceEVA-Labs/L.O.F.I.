import 'package:flutter/material.dart';

/// This class contains patched methods from fl_chart's Utils class
/// to fix compatibility issues with newer Flutter versions
class FlChartPatch {
  /// Replacement for the boldTextOverride method in fl_chart's Utils class
  static bool boldTextOverride(BuildContext context) {
    return MediaQuery.boldTextOf(context);
  }
}
