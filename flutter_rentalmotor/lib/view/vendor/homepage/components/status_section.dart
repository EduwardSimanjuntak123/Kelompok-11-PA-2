import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const StatusCard({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusSection extends StatelessWidget {
  final Map<String, int> statusCounts;

  const StatusSection({
    Key? key,
    required this.statusCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Status Pesanan",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatusCard(
              title: "Menunggu",
              count: statusCounts['pending'] ?? 0,
              icon: Icons.hourglass_empty,
              color: Colors.amber,
            ),
            StatusCard(
              title: "Dikonfirmasi",
              count: statusCounts['confirmed'] ?? 0,
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            StatusCard(
              title: "Dibatalkan",
              count: statusCounts['canceled'] ?? 0,
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
            StatusCard(
              title: "Ditolak",
              count: statusCounts['rejected'] ?? 0,
              icon: Icons.block,
              color: Colors.grey,
            ),
            StatusCard(
              title: "Dalam Pengiriman",
              count: statusCounts['in transit'] ?? 0,
              icon: Icons.local_shipping_outlined,
              color: Colors.blue,
            ),
            StatusCard(
              title: "Sedang Digunakan",
              count: statusCounts['in use'] ?? 0,
              icon: Icons.motorcycle,
              color: Colors.purple,
            ),
            StatusCard(
              title: "Menunggu Kembali",
              count: statusCounts['awaiting return'] ?? 0,
              icon: Icons.access_time,
              color: Colors.orange,
            ),
            StatusCard(
              title: "Selesai",
              count: statusCounts['completed'] ?? 0,
              icon: Icons.check_circle,
              color: Colors.teal,
            ),
          ],
        ),
      ],
    );
  }
}
