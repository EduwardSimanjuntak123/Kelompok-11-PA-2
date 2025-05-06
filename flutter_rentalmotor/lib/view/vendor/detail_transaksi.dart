import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
      : super(key: key);

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D); // Modern indigo
  final Color secondaryColor = const Color(0xFF00BFA5); // Modern teal
  final Color accentColor = const Color(0xFFFF6D00); // Modern orange
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light gray
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF263238); // Dark gray
  final Color textSecondaryColor = const Color(0xFF607D8B); // Blue gray
  final Color successColor = const Color(0xFF4CAF50); // Success green
  final Color warningColor = const Color(0xFFFFC107); // Warning amber
  final Color dangerColor = const Color(0xFFF44336); // Danger red

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
    final status = transaction['status'] ?? 'pending';

    final durationDays = calculateDuration(startRaw, endRaw);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Detail Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient at the top
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction ID and Status Card
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.receipt,
                                      color: primaryColor, size: 20),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID Transaksi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                    Text(
                                      '#${transaction['id'] ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        Divider(height: 24),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.1),
                              radius: 20,
                              child: Text(
                                customerName.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pelanggan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  customerName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Motor Information Card
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.motorcycle,
                                  color: secondaryColor, size: 20),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Informasi Motor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow(
                            'Nama Motor', "$motorName ($brand, $year)"),
                        _buildInfoRow('Harga per Hari', pricePerDay),
                        _buildInfoRow('Tipe', type.toUpperCase()),
                      ],
                    ),
                  ),

                  // Booking Details Card
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.calendar_today,
                                  color: accentColor, size: 20),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Detail Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildInfoRow('Tanggal Booking', bookingDate),
                        _buildInfoRow('Tanggal Mulai', startDate,
                            isHighlighted: true),
                        _buildInfoRow('Tanggal Selesai', endDate,
                            isHighlighted: true),
                        _buildInfoRow('Durasi Sewa', "$durationDays hari"),
                        _buildInfoRow('Lokasi Penjemputan', pickup),
                      ],
                    ),
                  ),

                  // Total Price Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Harga',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              totalPrice,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Lunas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: isHighlighted ? primaryColor : textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Selesai';
        break;
      case 'pending':
        statusColor = warningColor;
        statusIcon = Icons.pending_actions;
        statusText = 'Pending';
        break;
      case 'cancelled':
        statusColor = dangerColor;
        statusIcon = Icons.cancel;
        statusText = 'Dibatalkan';
        break;
      default:
        statusColor = textSecondaryColor;
        statusIcon = Icons.info;
        statusText = status.substring(0, 1).toUpperCase() + status.substring(1);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16,
            color: statusColor,
          ),
          SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
