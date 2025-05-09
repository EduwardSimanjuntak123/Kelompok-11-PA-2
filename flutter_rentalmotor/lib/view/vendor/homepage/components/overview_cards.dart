import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const OverviewCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class OverviewCards extends StatelessWidget {
  final int totalBookings;
  final int activeBookings;
  final int pendingBookings;
  final int currentMonthRevenue;
  final NumberFormat currencyFormatter;
  final Map<String, dynamic>? motor;

  const OverviewCards({
    Key? key,
    required this.totalBookings,
    required this.activeBookings,
    required this.pendingBookings,
    required this.currentMonthRevenue,
    required this.currencyFormatter,
    this.motor,
  }) : super(key: key);

  String _formatCurrency(int value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(value);
  }

  Widget _buildInfoBox(
    dynamic icon,
    String value,
    String title,
    Color color,
  ) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: icon is IconData
                ? Icon(icon, color: color, size: 20)
                : FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ringkasan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoBox(
                FontAwesomeIcons.moneyBillWave,
                "Rp ${_formatCurrency(motor != null ? (motor!["price"] ?? 0) : 0)}",
                "Pendapatan Bulan Ini",
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewCard(
                title: "Total Pesanan",
                value: totalBookings.toString(),
                icon: Icons.shopping_bag,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OverviewCard(
                title: "Pesanan Aktif",
                value: activeBookings.toString(),
                icon: Icons.motorcycle,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OverviewCard(
                title: "Menunggu Persetujuan",
                value: pendingBookings.toString(),
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
