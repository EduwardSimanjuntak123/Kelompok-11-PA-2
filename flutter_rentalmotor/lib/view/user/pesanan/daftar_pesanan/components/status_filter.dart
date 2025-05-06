import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/utils/status_utils.dart';

class StatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final Color primaryBlue;

  const StatusFilter({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.primaryBlue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: primaryBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Filter Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),
              if (selectedStatus != 'Semua')
                TextButton(
                  onPressed: () => onStatusChanged('Semua'),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 0),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onStatusChanged(newValue);
                  }
                },
                items: StatusUtils.getStatusList()
                    .map<DropdownMenuItem<String>>((String value) {
                  Color statusColor = value == 'Semua'
                      ? primaryBlue
                      : StatusUtils.getStatusColor(value);
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        if (value != 'Semua')
                          Icon(
                            StatusUtils.getStatusIcon(value),
                            size: 14,
                            color: statusColor,
                          ),
                        if (value != 'Semua') SizedBox(width: 8),
                        Text(
                          value[0].toUpperCase() + value.substring(1),
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: value == selectedStatus
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
