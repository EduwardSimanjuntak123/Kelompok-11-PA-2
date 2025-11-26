import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final Color primaryBlue;
  final VoidCallback onActionPressed;
  final bool isFilteredEmpty;

  const EmptyState({
    super.key,
    required this.primaryBlue,
    required this.onActionPressed,
    this.isFilteredEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFilteredEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 40,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Tidak ada pesanan dengan status ini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pesanan Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
  icon: Icon(Icons.motorcycle, size: 16, color: Colors.white),  // ikon putih
  label: Text(
    'Sewa Motor Sekarang',
    style: TextStyle(fontSize: 14, color: Colors.white),  // teks putih
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: primaryBlue,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: onActionPressed,
)

        ],
      ),
    );
  }
}
