import 'package:flutter/material.dart';

class BookingStatusUtils {
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return "Menunggu Konfirmasi";
      case 'confirmed':
        return "Dikonfirmasi, motor sedang disiapkan";
      case 'in use':
        return "Sedang saat ini digunakan";
      case 'rejected':
        return "Pesanan Ditolak";
      case 'in transit':
        return "Motor sedang diantar ke lokasi";
      case 'completed':
        return "Pesanan Selesai";
      case 'awaiting return':
        return "Menunggu Pengembalian";
      case 'canceled':
        return "Pesanan Dibatalkan";
      default:
        return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return Colors.green;
      case 'in use':
      case 'in transit':
      case 'awaiting return':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'rejected':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'in use':
        return Icons.directions_bike;
      case 'rejected':
        return Icons.cancel;
      case 'in transit':
        return Icons.local_shipping;
      case 'completed':
        return Icons.task_alt;
      case 'awaiting return':
        return Icons.assignment_return;
      case 'canceled':
        return Icons.highlight_off;
      default:
        return Icons.help_outline;
    }
  }

  static String capitalizeStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
