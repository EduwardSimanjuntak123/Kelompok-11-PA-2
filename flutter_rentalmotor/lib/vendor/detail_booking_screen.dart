import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/vendor/kelola_booking_service.dart';

class DetailBookingPage extends StatefulWidget {
  final int bookingId;
  const DetailBookingPage({super.key, required this.bookingId});

  @override
  State<DetailBookingPage> createState() => _DetailBookingPageState();
}

class _DetailBookingPageState extends State<DetailBookingPage> {
  Map<String, dynamic>? bookingData;
  final String baseUrl = ApiConfig.baseUrl;
  bool isLoading = true;
  final storage = const FlutterSecureStorage();
  final KelolaBookingService kelolaBookingService = KelolaBookingService();

  @override
  void initState() {
    super.initState();
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    setState(() => isLoading = true);
    try {
      final token = await storage.read(key: 'auth_token');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/vendor/bookings/${widget.bookingId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookingData = data['booking'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat detail booking');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionConfirmationDialog(String status) {
    String actionText;
    switch (status) {
      case 'pending':
        actionText = 'Konfirmasi Booking';
        break;
      case 'confirmed':
        actionText = 'Set to Transit';
        break;
      case 'in transit':
        actionText = 'Set to In Use';
        break;
      case 'in use':
        actionText = 'Complete Booking';
        break;
      case 'awaiting return':
        actionText = 'Motor Sudah Kembali';
        break;
      default:
        actionText = 'Unknown Action';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Aksi'),
          content: Text('Apakah Anda yakin ingin $actionText?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _performAction(status);
                Navigator.of(context).pop();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAction(String status) async {
    try {
      switch (status) {
        case 'pending':
          await kelolaBookingService
              .confirmBooking(widget.bookingId.toString());
          break;
        case 'confirmed':
          await kelolaBookingService
              .setBookingToTransit(widget.bookingId.toString());
          break;
        case 'in transit':
          await kelolaBookingService
              .setBookingToInUse(widget.bookingId.toString());
          break;
        case 'in use':
          await kelolaBookingService
              .completeBooking(widget.bookingId.toString());
          break;
        case 'awaiting return':
          await kelolaBookingService
              .completeBooking(widget.bookingId.toString());
          break;
        default:
          break;
      }
      fetchBookingDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status booking diperbarui!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildActionButton(String status) {
    if (status == 'completed' || status == 'rejected') {
      return Container();
    }

    return ElevatedButton.icon(
      onPressed: () => _showActionConfirmationDialog(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      label: Text(
        _getActionButtonText(status),
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getActionButtonText(String status) {
    switch (status) {
      case 'pending':
        return 'Konfirmasi Pesanan';
      case 'confirmed':
        return 'Ubah ke Sedang Diantar';
      case 'in transit':
        return 'Motor Digunakan Pelanggan';
      case 'in use':
        return 'Selesaikan Pesanan';
      case 'awaiting return':
        return 'Motor Sudah Kembali';
      default:
        return 'Unknown Action';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Detail Pesanan', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A567D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Informasi Booking',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const Divider(),
                              buildInfoRow(
                                  'Booking ID', bookingData!['id'].toString()),
                              buildInfoRow('Nama Customer',
                                  bookingData!['customer']?['name']),
                              buildInfoRow('Telepon',
                                  bookingData!['customer']?['phone']),
                              buildInfoRow('Alamat',
                                  bookingData!['customer']?['address']),
                              buildInfoRow('Status', bookingData!['status']),
                              buildInfoRow('Tanggal Booking',
                                  formatDate(bookingData!['booking_date'])),
                              buildInfoRow('Mulai',
                                  formatDate(bookingData!['start_date'])),
                              buildInfoRow('Selesai',
                                  formatDate(bookingData!['end_date'])),
                              buildInfoRow(
                                  'Pickup', bookingData!['pickup_location']),
                              buildInfoRow(
                                  'Dropoff', bookingData!['dropoff_location']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Informasi Motor',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const Divider(),
                              buildInfoRow(
                                  'Nama Motor', bookingData!['motor']?['name']),
                              buildInfoRow(
                                  'Merk', bookingData!['motor']?['brand']),
                              buildInfoRow('Tahun',
                                  bookingData!['motor']?['year']?.toString()),
                              buildInfoRow('Harga',
                                  'Rp ${bookingData!['motor']?['price'] ?? '-'}'),
                              buildInfoRow(
                                  'Warna', bookingData!['motor']?['color']),
                              buildInfoRow(
                                  'Tipe', bookingData!['motor']?['type']),
                              buildInfoRow('Deskripsi',
                                  bookingData!['motor']?['description']),
                              const SizedBox(height: 10),
                              if (bookingData!['motor']?['image'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    '$baseUrl${bookingData!['motor']['image']}',
                                    height: 180,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (bookingData!['photo_id'] != null ||
                          bookingData!['ktp_id'] != null)
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Foto Identitas',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                const Divider(),
                                if (bookingData!['photo_id'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Foto KTP & Diri",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          '$baseUrl${bookingData!['photo_id']}',
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                if (bookingData!['ktp_id'] != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Foto KTP Tambahan",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          '$baseUrl${bookingData!['ktp_id']}',
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      buildActionButton(bookingData!['status']),
                    ],
                  ),
                ),
    );
  }
}
