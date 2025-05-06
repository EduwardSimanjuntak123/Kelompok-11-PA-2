import 'package:flutter/material.dart';

class BookingDetailsCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final Color primaryBlue;

  const BookingDetailsCard({
    Key? key,
    required this.booking,
    required this.primaryBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: primaryBlue,
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Detail Pesanan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey[200]),

          // Booking Details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailItem(
                  Icons.location_on,
                  "Lokasi Pengantaran",
                  booking['pickup_location'] ?? '-',
                  primaryBlue,
                ),
                _buildDetailItem(
                  Icons.location_off,
                  "Lokasi Pengembalian",
                  booking['dropoff_location']?.isNotEmpty == true
                      ? booking['dropoff_location']
                      : "-",
                  primaryBlue,
                ),
                _buildDetailItem(
                  Icons.calendar_today,
                  "Tanggal Mulai",
                  (booking['start_date'] ?? '').toString().split('T')[0],
                  primaryBlue,
                ),
                _buildDetailItem(
                  Icons.event_available,
                  "Tanggal Selesai",
                  (booking['end_date'] ?? '').toString().split('T')[0],
                  primaryBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      IconData icon, String title, String value, Color primaryBlue) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 18),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
