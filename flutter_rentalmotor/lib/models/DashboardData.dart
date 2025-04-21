class DashboardData {
  final Map<String, int> statusCounts;
  final int totalRevenue;
  final int currentMonthRevenue;
  final List<MonthlyRevenue> monthlyRevenue;
  final List<dynamic> bookings;
  final List<dynamic> transactions;

  DashboardData({
    required this.statusCounts,
    required this.totalRevenue,
    required this.currentMonthRevenue,
    required this.monthlyRevenue,
    required this.bookings,
    required this.transactions,
  });

  factory DashboardData.empty() {
    return DashboardData(
      statusCounts: {
        'pending': 0,
        'confirmed': 0,
        'canceled': 0,
        'rejected': 0,
        'intransit': 0,
        'in_use': 0,
        'awaiting_return': 0,
        'completed': 0,
      },
      totalRevenue: 0,
      currentMonthRevenue: 0,
      monthlyRevenue: [],
      bookings: [],
      transactions: [],
    );
  }
}

class MonthlyRevenue {
  final DateTime month;
  final double revenue;
  final String monthName;

  MonthlyRevenue({
    required this.month,
    required this.revenue,
    required this.monthName,
  });
}
