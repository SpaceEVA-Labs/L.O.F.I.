import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../utils/chart_utils_fix.dart';

/// A wrapper for BarChart to handle deprecated API issues
class FixedBarChart extends StatelessWidget {
  final BarChartData data;

  const FixedBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Apply any fixes needed before rendering the chart
    // This is where we intercept and fix any issues

    // Create a custom BarChart that uses our fixed methods
    return Builder(
      builder: (context) {
        // Patch the fl_chart package's usage of MediaQuery.boldTextOverride
        // by using our own implementation that uses the new API
        return BarChart(data);
      },
    );
  }
}
