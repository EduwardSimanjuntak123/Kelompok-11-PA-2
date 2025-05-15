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
          Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                children: [
                  TextSpan(text: 'Menampilkan pesanan dengan status: '),
                  TextSpan(
                    text: StatusUtils.getStatusText(selectedStatus),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: StatusUtils.getStatusColor(selectedStatus),
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
