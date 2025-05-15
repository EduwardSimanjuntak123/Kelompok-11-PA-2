import 'package:flutter/material.dart';

class StatusUtils {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'in transit':
        return Colors.blue;
      case 'in use':
        return Colors.purple;
      case 'awaiting return':
        return Colors.amber;
      case 'completed':
        return Colors.teal;
      case 'canceled':
      case 'rejected':
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
      case 'in transit':
        return Icons.local_shipping;
      case 'in use':
        return Icons.directions_bike;
      case 'awaiting return':
        return Icons.assignment_return;
      case 'completed':
        return Icons.task_alt;
      case 'canceled':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'in transit':
        return 'Dalam Pengiriman';
      case 'in use':
        return 'Sedang Digunakan';
      case 'awaiting return':
        return 'Menunggu Pengembalian';
      case 'completed':
        return 'Selesai';
      case 'canceled':
        return 'Dibatalkan';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Status Tidak Dikenal';
    }
  }

  static List<String> getStatusList() {
    return [
      'Semua',
      'pending',
      'confirmed',
      'in transit',
      'in use',
      'awaiting return',
      'completed',
      'canceled',
      'rejected',
    ];
  }
}
