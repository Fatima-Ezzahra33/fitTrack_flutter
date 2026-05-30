/// FitTrack : Weight History Screen 
///
/// Features a detailed weight progress dashboard:
/// - Weight statistics (current, start, target)
/// - fl_chart LineChart curve for 30d/3m/6m ranges
/// - Swipe-to-delete chronological list of entries
/// - FAB opening dialog for adding a new weight entry
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/weight_history_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/weight_entry_model.dart';

class WeightHistoryScreen extends StatefulWidget {
  const WeightHistoryScreen({super.key});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null && user.id != null) {
        context.read<WeightHistoryController>().loadWeightHistory(user.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthController>().currentUser;
    final weightCtrl = context.watch<WeightHistoryController>();

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in', style: GoogleFonts.poppins())),
      );
    }

    // Weight metrics calculations
    final double targetWeight = user.goalWeight ?? 70.0;
    final double currentWeight = weightCtrl.latestWeight?.weight ?? user.weight ?? 75.0;

    // Get start weight (oldest entry or user weight)
    double startWeight = user.weight ?? 75.0;
    if (weightCtrl.weightEntries.isNotEmpty) {
      final sortedOldest = List<WeightEntry>.from(weightCtrl.weightEntries)
        ..sort((a, b) => a.date.compareTo(b.date));
      startWeight = sortedOldest.first.weight;
    }

    final double totalDiff = currentWeight - startWeight;
    final String diffSign = totalDiff > 0 ? '+' : '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Weight History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddWeightDialog(context, user.id!, isDark),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: weightCtrl.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await weightCtrl.loadWeightHistory(user.id!);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Cards Row
                    _buildMetricsSection(isDark, startWeight, currentWeight, targetWeight, diffSign, totalDiff),
                    const SizedBox(height: AppSizes.xl),

                    // Range Selector Tabs
                    _buildRangeSelector(weightCtrl, isDark),
                    const SizedBox(height: AppSizes.md),

                    // High-Fi weight chart
                    _buildWeightChart(isDark, weightCtrl),
                    const SizedBox(height: AppSizes.xl),

                    // Log entries list title
                    Text(
                      'Weight Measurements',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // List view of weights
                    _buildWeightsList(weightCtrl, user.id!, isDark),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMetricsSection(
    bool isDark,
    double start,
    double current,
    double target,
    String diffSign,
    double diff,
  ) {
    return Row(
      children: [
        _buildMetricCard('Start', '${start.toStringAsFixed(1)} kg', isDark),
        const SizedBox(width: 10),
        _buildMetricCard('Current', '${current.toStringAsFixed(1)} kg', isDark, highlighted: true),
        const SizedBox(width: 10),
        _buildMetricCard(
          'Target',
          '${target.toStringAsFixed(1)} kg',
          isDark,
          subLabel: '$diffSign${diff.toStringAsFixed(1)} kg',
          subLabelColor: diff <= 0 ? AppColors.success : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    bool isDark, {
    bool highlighted = false,
    String? subLabel,
    Color? subLabelColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: highlighted ? AppColors.primaryGradient : null,
          color: highlighted ? null : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: highlighted ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: highlighted ? Colors.white : (isDark ? AppColors.textDarkPrimary : AppColors.textPrimary),
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: subLabelColor ?? AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRangeSelector(WeightHistoryController weightCtrl, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.borderLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildRangeTab('30d', '30 days', weightCtrl),
          _buildRangeTab('3m', '3 months', weightCtrl),
          _buildRangeTab('6m', '6 months', weightCtrl),
        ],
      ),
    );
  }

  Widget _buildRangeTab(String range, String label, WeightHistoryController weightCtrl) {
    final isSelected = weightCtrl.selectedRange == range;
    return Expanded(
      child: InkWell(
        onTap: () => weightCtrl.changeRange(range),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart(bool isDark, WeightHistoryController weightCtrl) {
    if (weightCtrl.weightEntries.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            'No weight data recorded.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Sort ascending by date
    final sorted = List<WeightEntry>.from(weightCtrl.weightEntries)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Filter and aggregate based on range
    int daysRange = 30;
    if (weightCtrl.selectedRange == '3m') daysRange = 90;
    else if (weightCtrl.selectedRange == '6m') daysRange = 180;

    final DateTime now = DateTime.now();
    final DateTime cutoff = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysRange));

    final Map<DateTime, List<double>> dailyWeights = {};
    for (var e in sorted) {
      if (e.date.isAfter(cutoff) || e.date.isAtSameMomentAs(cutoff)) {
        final day = DateTime(e.date.year, e.date.month, e.date.day);
        dailyWeights.putIfAbsent(day, () => []).add(e.weight);
      }
    }

    if (dailyWeights.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            'No data for this period',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var entry in dailyWeights.entries) {
      final avgWeight = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final double x = entry.key.difference(cutoff).inHours / 24.0;
      spots.add(FlSpot(x, avgWeight));
    }
    spots.sort((a, b) => a.x.compareTo(b.x));

    final double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    double xInterval = 6;
    if (daysRange == 90) xInterval = 15;
    else if (daysRange == 180) xInterval = 30;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      padding: const EdgeInsets.only(top: 24, bottom: 12, right: 20, left: 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.6),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '${value.toStringAsFixed(0)} kg',
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                reservedSize: 45,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: xInterval,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value > daysRange) return const SizedBox.shrink();
                  final date = cutoff.add(Duration(hours: (value * 24).round()));
                  final String format = daysRange == 30 ? 'dd/MM' : 'MMM dd';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat(format).format(date),
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                reservedSize: 22,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: daysRange.toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: spots.length > 1,
              color: AppColors.primary,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: spots.length > 1,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightsList(WeightHistoryController weightCtrl, int userId, bool isDark) {
    if (weightCtrl.weightEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            'No records available',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    // Sort descending by date for history
    final history = List<WeightEntry>.from(weightCtrl.weightEntries)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final entry = history[index];
        final String formattedDate = DateFormat('dd MMMM yyyy').format(entry.date);

        return Dismissible(
          key: Key('weight_${entry.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) async {
            if (entry.id != null) {
              await weightCtrl.removeWeightEntry(entry.id!, userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Measurement deleted!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.scale_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.weight.toStringAsFixed(1)} kg',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                        ),
                      ),
                      if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Note: ${entry.note}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_left_rounded, size: 18, color: isDark ? AppColors.textDarkSecondary : AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddWeightDialog(BuildContext context, int userId, bool isDark) {
    final TextEditingController weightCont = TextEditingController();
    final TextEditingController noteCont = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Record a Weight',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Weight input
                    TextField(
                      controller: weightCont,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        hintText: 'Ex: 73.5',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Date selector
                    InkWell(
                      onTap: () async {
                        final picker = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: AppColors.primary,
                                  primary: AppColors.primary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picker != null) {
                          setState(() {
                            selectedDate = picker;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),

                    // Note input
                    TextField(
                      controller: noteCont,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Note (optional)',
                        hintText: 'Ex: Morning fasting measurement',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final double? weight = double.tryParse(weightCont.text.replaceAll(',', '.'));
                    if (weight == null || weight <= 0) return;

                    final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

                    await context.read<WeightHistoryController>().recordWeight(
                          userId: userId,
                          weight: weight,
                          date: dateStr,
                          note: noteCont.text.trim().isNotEmpty ? noteCont.text.trim() : null,
                        );

                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Weight of $weight kg recorded!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Save', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
