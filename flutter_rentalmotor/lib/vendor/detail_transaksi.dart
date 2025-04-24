import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
      : super(key: key);

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (_) {
      return '-';
    }
  }

  String formatCurrency(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  int calculateDuration(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return endDate.difference(startDate).inDays + 1; // +1 agar inklusif
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final motor = transaction['motor'];
    final customerName = transaction['customer_name'] ?? 'Tidak diketahui';
    final motorName = motor != null ? motor['name'] ?? '-' : '-';
    final brand = motor != null ? motor['brand'] ?? '-' : '-';
    final year = motor != null ? motor['year']?.toString() ?? '-' : '-';
    final pricePerDay = motor != null
        ? formatCurrency(motor['price_per_day'] ?? 0)
        : formatCurrency(0);

    final pickup = transaction['pickup_location'] ?? '-';
    final startRaw = transaction['start_date'] ?? '';
    final endRaw = transaction['end_date'] ?? '';
    final startDate = formatDate(startRaw);
    final endDate = formatDate(endRaw);
    final bookingDate = formatDate(transaction['booking_date'] ?? '');
    final totalPrice = formatCurrency(transaction['total_price'] ?? 0);
    final type = transaction['type'] ?? '-';

    final durationDays = calculateDuration(startRaw, endRaw);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Transaksi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A567D),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          shadowColor: Colors.black45,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Pelanggan", style: titleStyle),
                SizedBox(height: 4),
                Text(customerName, style: contentStyle),
                Divider(height: 24),
                Text("Nama Motor", style: titleStyle),
                Text("$motorName ($brand, $year)", style: contentStyle),
                SizedBox(height: 12),
                Text("Harga per Hari", style: titleStyle),
                Text(pricePerDay, style: contentStyle),
                SizedBox(height: 12),
                Text("Durasi Sewa", style: titleStyle),
                Text("$durationDays hari", style: contentStyle),
                Divider(height: 24),
                Text("Tipe", style: titleStyle),
                Text(type.toUpperCase(), style: contentStyle),
                Divider(height: 24),
                Text("Tanggal Booking", style: titleStyle),
                Text(bookingDate, style: contentStyle),
                SizedBox(height: 12),
                Text("Tanggal Mulai", style: titleStyle),
                Text(startDate, style: contentStyle),
                SizedBox(height: 12),
                Text("Tanggal Selesai", style: titleStyle),
                Text(endDate, style: contentStyle),
                Divider(height: 24),
                Text("Lokasi Penjemputan", style: titleStyle),
                Text(pickup, style: contentStyle),
                Divider(height: 24),
                Text("Total Harga", style: titleStyle),
                Text(totalPrice,
                    style: contentStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    )),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get titleStyle => TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontWeight: FontWeight.w600,
      );

  TextStyle get contentStyle => TextStyle(
        fontSize: 16,
        color: Colors.black,
      );
}
