import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/chat.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/cancelBooking_api.dart';

class PesananPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const PesananPage({Key? key, required this.booking}) : super(key: key);

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  int _selectedIndex = 1;
  bool _isCancelling = false;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return "Menunggu Konfirmasi";
      case 'confirmed':
        return "Dikonfirmasi, motor sedang disiapkan";
      case 'in use':
        return "Sedang saat ini digunakan";
      case 'rejected':
        return "Pesanan Ditolak";
      case 'in transit':
        return "Motor sedang diantar ke lokasi";
      case 'completed':
        return "Pesanan Selesai";
      case 'awaiting return':
        return "Menunggu Pengembalian";
      case 'canceled':
        return "Pesanan Dibatalkan";
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return Colors.green;
      case 'in use':
      case 'in transit':
      case 'awaiting return':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'rejected':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> showCancelConfirmation(int bookingId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Ya, Batalkan"),
          ),
        ],
      ),
    );

    if (result == true) {
      await cancelBooking(bookingId);
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    setState(() => _isCancelling = true);

    final success = await BatalkanPesananAPI.cancelBooking(bookingId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pesanan berhasil dibatalkan.")),
      );
      setState(() {
        widget.booking['status'] = 'canceled';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membatalkan pesanan.")),
      );
    }

    setState(() => _isCancelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final motor = booking['motor'] ?? {};
    final status = booking['status'] ?? '';
    String imageUrl = motor['image'] ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = "${ApiConfig.baseUrl}$imageUrl";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C567E),
        title: const Text("Detail Pesanan",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                getStatusText(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(status)),
              ),
            ),
            const SizedBox(height: 20),

            // Motor Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${motor['name'] ?? ''}".toUpperCase(),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${motor['brand'] ?? ''} ${motor['model'] ?? ''}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            buildRequiredField(
                "Lokasi Pengantaran", booking['pickup_location'] ?? '-'),
            buildRequiredField(
                "Lokasi Pengembalian",
                booking['dropoff_location']?.isNotEmpty == true
                    ? booking['dropoff_location']
                    : "-"),
            buildRequiredField("Tanggal Mulai",
                (booking['start_date'] ?? '').toString().split('T')[0]),
            buildRequiredField("Tanggal Selesai",
                (booking['end_date'] ?? '').toString().split('T')[0]),
            const SizedBox(height: 20),

            if (status == 'pending') ...[
              buildButton(
                _isCancelling ? "Membatalkan..." : "Batalkan Pesanan",
                Colors.red,
                Colors.white,
                _isCancelling
                    ? null
                    : () => showCancelConfirmation(booking['id']),
              ),
              const SizedBox(height: 10),
            ],

            buildButton(
              "Hubungi Vendor Sewa",
              Colors.blue[900]!,
              Colors.white,
              () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ChatPage())),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Beranda"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Pesanan"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Akun"),
        ],
      ),
    );
  }

  Widget buildRequiredField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget buildButton(
      String text, Color bgColor, Color textColor, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }
}
