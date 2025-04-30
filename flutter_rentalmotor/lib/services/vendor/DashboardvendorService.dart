import 'package:flutter_rentalmotor/models/DashboardData.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_api_service.dart';
import 'package:intl/intl.dart';

class DashboardService {
  final VendorApiService _apiService = VendorApiService();

  Future<DashboardData> getDashboardData() async {
    try {
      final bookings = await _apiService.getBookings();
      final transactions = await _apiService.getTransactions();

      // Calculate status counts
      final statusCounts = _calculateStatusCounts(bookings);

      // Calculate revenue data
      final revenueData = _calculateRevenueData(transactions);

      return DashboardData(
        statusCounts: statusCounts,
        totalRevenue: revenueData['totalRevenue'],
        currentMonthRevenue: revenueData['currentMonthRevenue'],
        monthlyRevenue: revenueData['monthlyRevenue'],
        bookings: bookings,
        transactions: transactions,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, int> _calculateStatusCounts(List<dynamic> bookings) {
    final counts = {
      'pending': 0,
      'confirmed': 0,
      'canceled': 0,
      'rejected': 0,
      'in transit': 0,
      'in use': 0,
      'awaiting return': 0,
      'completed': 0,
    };

    for (var booking in bookings) {
      final status = booking['status'].toString().toLowerCase();
      if (counts.containsKey(status)) {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    return counts;
  }

  Map<String, dynamic> _calculateRevenueData(List<dynamic> transactions) {
    int totalRevenue = 0;
    int currentMonthRevenue = 0;
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // Map to store monthly revenue
    final Map<String, double> monthlyRevenueMap = {};

    // Process transactions
    for (var transaction in transactions) {
      final price = transaction['total_price'] as int? ?? 0;
      totalRevenue += price;

      // Parse transaction date
      final createdAt =
          DateTime.parse(transaction['created_at'] ?? now.toIso8601String());
      final transactionMonth = DateTime(createdAt.year, createdAt.month);

      // Check if transaction is from current month
      if (transactionMonth.year == currentMonth.year &&
          transactionMonth.month == currentMonth.month) {
        currentMonthRevenue += price;
      }

      // Add to monthly revenue map
      final monthKey = DateFormat('yyyy-MM').format(transactionMonth);
      monthlyRevenueMap[monthKey] = (monthlyRevenueMap[monthKey] ?? 0) + price;
    }

    // Convert map to list and sort by date (newest first)
    final List<MapEntry<String, double>> sortedEntries =
        monthlyRevenueMap.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key));

    // Take only the last 5 months
    final last5Months = sortedEntries.take(5).toList();

    // Convert to MonthlyRevenue objects
    final List<MonthlyRevenue> monthlyRevenue = [];
    for (var entry in last5Months.reversed) {
      final dateParts = entry.key.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final date = DateTime(year, month);

      monthlyRevenue.add(MonthlyRevenue(
        month: date,
        revenue: entry.value,
        monthName: DateFormat('MMM').format(date),
      ));
    }

    return {
      'totalRevenue': totalRevenue,
      'currentMonthRevenue': currentMonthRevenue,
      'monthlyRevenue': monthlyRevenue,
    };
  }
}
