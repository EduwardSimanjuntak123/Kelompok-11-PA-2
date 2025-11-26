import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/utils/booking_status_utils.dart';

class ExtensionList extends StatelessWidget {
  final List<dynamic> extensions;
  final bool isLoading;
  final Color primaryBlue;

  const ExtensionList({
    super.key,
    required this.extensions,
    required this.isLoading,
    required this.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (extensions.isEmpty) {
      return Text('Belum ada permintaan perpanjangan');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: extensions.map((ext) {
        final status = ext['status'];
        final Color bgColor = status == 'pending'
            ? Colors.yellow.shade100
            : status == 'approved'
                ? Colors.green.shade100
                : Colors.red.shade100;

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.update, size: 20, color: primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    "Permintaan Perpanjangan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildExtensionDetail('Tanggal Permintaan',
                  ext['requested_at']?.split('T')[0] ?? '-'),
              _buildExtensionDetail('Tanggal Selesai Baru',
                  ext['requested_end_date']?.split('T')[0] ?? '-'),
              _buildExtensionDetail(
                  'Harga Tambahan', 'Rp ${ext['additional_price'] ?? 0}'),
              _buildExtensionDetail(
                  'Status', BookingStatusUtils.capitalizeStatus(status)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExtensionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
