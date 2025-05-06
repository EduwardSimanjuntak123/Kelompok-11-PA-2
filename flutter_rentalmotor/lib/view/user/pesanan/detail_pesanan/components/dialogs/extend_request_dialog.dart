import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/components/calendar_extension.dart';

class ExtendRequestDialog extends StatefulWidget {
  final Map<String, dynamic> booking;
  final List<DateTime> unavailableDates;
  final Function(int additionalDays) onSubmit;
  final bool cannotExtend;

  const ExtendRequestDialog({
    Key? key,
    required this.booking,
    required this.unavailableDates,
    required this.onSubmit,
    this.cannotExtend = false,
  }) : super(key: key);

  @override
  _ExtendRequestDialogState createState() => _ExtendRequestDialogState();
}

class _ExtendRequestDialogState extends State<ExtendRequestDialog> {
  int additionalDays = 3;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.all(16),
      title: Text(
        'Ajukan Perpanjangan',
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C567E)),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar
            CalendarExtension(
              unavailableDates: widget.unavailableDates,
              booking: widget.booking,
            ),

            SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6),
                _buildLegendItem(Colors.orange[200]!, "Booking Anda"),
                SizedBox(height: 6),
                _buildLegendItem(
                    Colors.red[100]!, "Tanggal yang sudah di Booking"),
              ],
            ),
            SizedBox(height: 16),
            if (widget.cannotExtend) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tidak bisa perpanjang karena tanggal yang diminta sudah berbenturan dengan booking lain.',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
            if (!widget.cannotExtend) ...[
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah Hari Tambahan',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    additionalDays = int.tryParse(value) ?? 1;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Tutup', style: TextStyle(color: Colors.grey)),
        ),
        if (!widget.cannotExtend) ...[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2C567E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSubmit(additionalDays);
            },
            child: Text('Kirim', style: TextStyle(color: Colors.white)),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
