import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../player_state.dart';
import '../utils/chart_utils_fix.dart';

class StatisticsScreen extends StatefulWidget {
  final PlayerState state;

  const StatisticsScreen({Key? key, required this.state}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  // Time period selection
  String _selectedPeriod = 'Weekly';
  final List<String> _periods = ['Weekly', 'Monthly', 'Yearly'];

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate average focus time for the selected period
  double get _averageFocusTime {
    final data = _getDataForPeriod();
    if (data.isEmpty) return 0;

    final total = data.fold(0, (sum, item) => sum + item.minutes);
    return total / data.length;
  }

  // Calculate total focus time
  String get _totalFocusTime {
    final totalPoints = widget.state.totalPoints;
    // Convert points to minutes (assuming 10 points per minute)
    final totalMinutes = (totalPoints / 10).round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  // Calculate streak (consecutive days with focus time)
  int get _currentStreak {
    // Sort daily points by date
    final sortedDates = widget.state.dailyPoints.keys.toList()..sort();
    if (sortedDates.isEmpty) return 0;

    int streak = 1;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check if there's activity today
    if (sortedDates.isEmpty || sortedDates.last != today) return 0;

    // Count consecutive days
    for (int i = sortedDates.length - 2; i >= 0; i--) {
      final currentDate = DateTime.parse(sortedDates[i + 1]);
      final prevDate = DateTime.parse(sortedDates[i]);

      final difference = currentDate.difference(prevDate).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get data for the selected period
  List<FocusData> _getDataForPeriod() {
    switch (_selectedPeriod) {
      case 'Weekly':
        return _generateWeeklyData();
      case 'Monthly':
        return _generateMonthlyData();
      case 'Yearly':
        return _generateYearlyData();
      default:
        return _generateWeeklyData();
    }
  }

  // Generate weekly data from player state
  List<FocusData> _generateWeeklyData() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final result = <FocusData>[];

    // Get the start of the week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dateKey = day.toIso8601String().split('T')[0];
      final points = widget.state.dailyPoints[dateKey] ?? 0;

      // Convert points to minutes (assuming 10 points per minute)
      final focusMinutes = (points / 10).round();

      result.add(FocusData(days[i], focusMinutes));
    }

    return result;
  }

  // Generate monthly data from player state
  List<FocusData> _generateMonthlyData() {
    final now = DateTime.now();
    final result = <FocusData>[];

    // Get the start of the month
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    // Group by week
    for (int week = 0; week < 5; week++) {
      int totalMinutes = 0;
      int daysInThisWeek = 0;

      for (
        int day = 1 + (week * 7);
        day <= daysInMonth && day < (week + 1) * 7 + 1;
        day++
      ) {
        final date = DateTime(now.year, now.month, day);
        final dateKey = date.toIso8601String().split('T')[0];
        final points = widget.state.dailyPoints[dateKey] ?? 0;

        // Convert points to minutes
        totalMinutes += (points / 10).round();
        daysInThisWeek++;
      }

      if (daysInThisWeek > 0) {
        result.add(FocusData('Week ${week + 1}', totalMinutes));
      }
    }

    return result;
  }

  // Generate yearly data from player state
  List<FocusData> _generateYearlyData() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final result = <FocusData>[];

    for (int month = 0; month < 12; month++) {
      int totalMinutes = 0;

      // Get days in this month
      final daysInMonth = DateTime(now.year, month + 2, 0).day;

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(now.year, month + 1, day);
        final dateKey = date.toIso8601String().split('T')[0];
        final points = widget.state.dailyPoints[dateKey] ?? 0;

        // Convert points to minutes
        totalMinutes += (points / 10).round();
      }

      result.add(FocusData(months[month], totalMinutes));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _getDataForPeriod();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Statistics'),
        backgroundColor: Colors.black, // Black top bar as requested
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time Period:', style: theme.textTheme.titleMedium),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    icon: const Icon(Icons.arrow_drop_down),
                    elevation: 16,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    underline: Container(height: 0),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedPeriod = value;
                        });
                      }
                    },
                    items: _periods.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Focus Time Chart
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedPeriod Focus Time',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: $_totalFocusTime',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Chart based on selected period
                    SizedBox(
                      height: 250,
                      child: FadeTransition(
                        opacity: _animation,
                        child: _buildChart(theme, data),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    Icons.timer,
                    _totalFocusTime,
                    'Total Focus Time',
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    Icons.trending_up,
                    '${_averageFocusTime.toStringAsFixed(0)}m',
                    'Daily Average',
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    Icons.local_fire_department,
                    '$_currentStreak days',
                    'Current Streak',
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    Icons.emoji_events,
                    '${widget.state.totalPoints}',
                    'Total Points',
                    Colors.amber,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Daily Breakdown
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_selectedPeriod Breakdown',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Data breakdown list
                    ...data.map(
                      (item) => _buildStatItem(
                        context: context,
                        label: item.day,
                        minutes: item.minutes,
                        theme: theme,
                      ),
                    ),

                    if (data.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No data for this period')),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Points History
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Points History',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Points history list
                    ...widget.state.dailyPoints.entries
                        .toList()
                        .reversed
                        .take(7)
                        .map((entry) {
                          final date = DateTime.parse(entry.key);
                          final formatter = DateFormat('MMM d, yyyy');
                          return ListTile(
                            leading: Icon(
                              Icons.calendar_today,
                              color: theme.colorScheme.primary,
                            ),
                            title: Text(formatter.format(date)),
                            trailing: Text(
                              '${entry.value} pts',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        })
                        .toList(),

                    if (widget.state.dailyPoints.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No points history yet')),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String label,
    required int minutes,
    required ThemeData theme,
  }) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeString = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Focus Time', style: theme.textTheme.bodyMedium),
                Text(
                  timeString,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: minutes / 300, // Assuming 300 minutes is max
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme, List<FocusData> data) {
    // If no data, show a message
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available for this period',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    // Determine max value for chart scaling
    final maxValue = data
        .fold(0, (max, item) => item.minutes > max ? item.minutes : max)
        .toDouble();
    final roundedMax = ((maxValue / 100).ceil() * 100).toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: roundedMax > 0 ? roundedMax : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData group) => Colors.blueGrey,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= data.length) return null;
              final minutes = rod.toY.round();
              final hours = minutes ~/ 60;
              final mins = minutes % 60;
              final timeString = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
              return BarTooltipItem(
                '${data[groupIndex].day}: $timeString',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    data[index].day,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.minutes.toDouble(),
                color: theme.colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Data class for focus data
class FocusData {
  final String day;
  final int minutes;

  FocusData(this.day, this.minutes);
}
