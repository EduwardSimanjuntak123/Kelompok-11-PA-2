import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/models/DashboardData.dart';

class RevenueChart extends StatelessWidget {
  final List<MonthlyRevenue> monthlyRevenue;
  final NumberFormat currencyFormatter;

  const RevenueChart({
    Key? key,
    required this.monthlyRevenue,
    required this.currencyFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find max value for chart scaling
    final double maxRevenue = monthlyRevenue.isEmpty
        ? 1000000
        : monthlyRevenue.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) *
            1.2;

    // Current month index
    final int currentMonthIndex = monthlyRevenue.isEmpty
        ? -1
        : monthlyRevenue.indexWhere((e) =>
            e.month.year == DateTime.now().year &&
            e.month.month == DateTime.now().month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pendapatan Bulanan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: monthlyRevenue.isEmpty
              ? const Center(child: Text("Belum ada data pendapatan"))
              : Column(
                  children: [
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxRevenue,
                          barGroups: List.generate(
                            monthlyRevenue.length,
                            (i) => BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: monthlyRevenue[i].revenue,
                                  color: i == currentMonthIndex
                                      ? const Color(0xFF1A567D)
                                      : const Color(0xFF1A567D)
                                          .withOpacity(0.5),
                                  width: 16,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ],
                              showingTooltipIndicators:
                                  i == currentMonthIndex ? [0] : [],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final int index = value.toInt();
                                  if (index >= 0 &&
                                      index < monthlyRevenue.length) {
                                    final bool isCurrentMonth =
                                        index == currentMonthIndex;

                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 8,
                                      child: Text(
                                        monthlyRevenue[index].monthName,
                                        style: TextStyle(
                                          color: isCurrentMonth
                                              ? const Color(0xFF1A567D)
                                              : Colors.grey[600],
                                          fontSize: isCurrentMonth ? 12 : 10,
                                          fontWeight: isCurrentMonth
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  String text = '';
                                  if (value == 0) {
                                    text = '0';
                                  } else if (value == maxRevenue * 0.25) {
                                    text = currencyFormatter
                                        .format(maxRevenue * 0.25)
                                        .replaceAll('Rp ', '');
                                  } else if (value == maxRevenue * 0.5) {
                                    text = currencyFormatter
                                        .format(maxRevenue * 0.5)
                                        .replaceAll('Rp ', '');
                                  } else if (value == maxRevenue * 0.75) {
                                    text = currencyFormatter
                                        .format(maxRevenue * 0.75)
                                        .replaceAll('Rp ', '');
                                  } else if (value == maxRevenue) {
                                    text = currencyFormatter
                                        .format(maxRevenue)
                                        .replaceAll('Rp ', '');
                                  }

                                  return SideTitleWidget(
                                    meta: meta, // ✅ gunakan ini
                                    space: 8,
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 60,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxRevenue / 4,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (currentMonthIndex >= 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A567D),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Bulan Ini: ${currencyFormatter.format(monthlyRevenue[currentMonthIndex].revenue)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A567D),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
