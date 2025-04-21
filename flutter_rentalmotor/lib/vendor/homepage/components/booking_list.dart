import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/vendor/daftar_pesanan_screen.dart';

class BookingItem extends StatelessWidget {
  final dynamic booking;
  final NumberFormat currencyFormatter;

  const BookingItem({
    Key? key,
    required this.booking,
    required this.currencyFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = booking['status'] ?? 'pending';
    final Color statusColor = _getStatusColor(status);
    final IconData statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(statusIcon, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Booking #${booking['id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking['customer_name'] ?? 'Pelanggan',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Motor: ${booking['motor']?['name'] ?? 'Unknown'} (${booking['motor']?['brand'] ?? 'Unknown'})",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  _getStatusText(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormatter.format(booking['motor']?['total_price'] ?? 0),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber;
      case 'confirmed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'rejected':
        return Colors.grey;
      case 'intransit':
        return Colors.blue;
      case 'in_use':
        return Colors.purple;
      case 'awaiting_return':
        return Colors.orange;
      case 'completed':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'canceled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.block;
      case 'intransit':
        return Icons.local_shipping_outlined;
      case 'in_use':
        return Icons.motorcycle;
      case 'awaiting_return':
        return Icons.access_time;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'canceled':
        return 'Dibatalkan';
      case 'rejected':
        return 'Ditolak';
      case 'intransit':
        return 'Dalam Pengiriman';
      case 'in_use':
        return 'Digunakan';
      case 'awaiting_return':
        return 'Menunggu Kembali';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}

class BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final NumberFormat currencyFormatter;

  const BookingList({
    Key? key,
    required this.bookings,
    required this.currencyFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pesanan Terbaru",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DaftarPesananVendorScreen(),
                  ),
                );
              },
              child: const Text("Lihat Semua"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (bookings.isEmpty)
          Container(
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
            child: const Center(
              child: Text(
                "Belum ada pesanan",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length > 5 ? 5 : bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingItem(
                booking: booking,
                currencyFormatter: currencyFormatter,
              );
            },
          ),
      ],
    );
  }
}
