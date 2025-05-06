import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/utils/status_utils.dart';

class ActiveFilterDisplay extends StatelessWidget {
  final String selectedStatus;

  const ActiveFilterDisplay({
    Key? key,
    required this.selectedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedStatus == 'Semua') {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: StatusUtils.getStatusColor(selectedStatus).withOpacity(0.05),
      child: Row(
        children: [
          Icon(
            StatusUtils.getStatusIcon(selectedStatus),
            size: 16,
            color: StatusUtils.getStatusColor(selectedStatus),
          ),
          SizedBox(width: 8),
          Text(
            'Menampilkan pesanan dengan status: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            selectedStatus[0].toUpperCase() + selectedStatus.substring(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: StatusUtils.getStatusColor(selectedStatus),
            ),
          ),
        ],
      ),
    );
  }
}
