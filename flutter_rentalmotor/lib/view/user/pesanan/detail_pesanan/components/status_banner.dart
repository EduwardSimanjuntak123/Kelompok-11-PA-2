import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/utils/booking_status_utils.dart';

class StatusBanner extends StatelessWidget {
  final String status;

  const StatusBanner({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: BookingStatusUtils.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BookingStatusUtils.getStatusColor(status).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BookingStatusUtils.getStatusColor(status).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              BookingStatusUtils.getStatusIcon(status),
              color: BookingStatusUtils.getStatusColor(status),
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status Pesanan",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  BookingStatusUtils.getStatusText(status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BookingStatusUtils.getStatusColor(status),
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