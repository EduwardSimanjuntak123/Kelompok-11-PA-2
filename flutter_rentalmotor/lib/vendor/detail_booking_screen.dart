import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/vendor/kelola_booking_service.dart'; // Pastikan file ini diimport

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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value ?? '-')),
        ],
      ),
    );
  }

  // Konfirmasi untuk tombol aksi
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

  // Melakukan aksi untuk memperbarui status booking
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
          // Update status menjadi completed ketika motor sudah kembali
          await kelolaBookingService
              .completeBooking(widget.bookingId.toString());
          break;
        default:
          break;
      }
      fetchBookingDetail(); // Reload data setelah aksi berhasil
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
    // Menyembunyikan tombol jika status sudah `completed` atau `rejected`
    if (status == 'completed' || status == 'rejected') {
      return Container(); // Tidak ada tombol jika status sudah completed atau rejected
    }

    return ElevatedButton(
      onPressed: () => _showActionConfirmationDialog(status),
      child: Text(_getActionButtonText(status)),
    );
  }

  String _getActionButtonText(String status) {
    switch (status) {
      case 'pending':
        return 'Konfirmasi pesanan';
      case 'confirmed':
        return 'ubah status ke sedang diantar';
      case 'in transit':
        return 'Motor sudah digunakan pelanggan';
      case 'in use':
        return 'Complete Booking';
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
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detail Booking',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      buildInfoRow('Booking ID', bookingData!['id'].toString()),
                      buildInfoRow(
                          'Nama Customer', bookingData!['customer']?['name']),
                      buildInfoRow(
                          'Telepon', bookingData!['customer']?['phone']),
                      buildInfoRow(
                          'Alamat', bookingData!['customer']?['address']),
                      buildInfoRow('Status', bookingData!['status']),
                      buildInfoRow('Tanggal Booking',
                          formatDate(bookingData!['booking_date'])),
                      buildInfoRow(
                          'Mulai', formatDate(bookingData!['start_date'])),
                      buildInfoRow(
                          'Selesai', formatDate(bookingData!['end_date'])),
                      buildInfoRow('Pickup', bookingData!['pickup_location']),
                      buildInfoRow('Dropoff', bookingData!['dropoff_location']),
                      const SizedBox(height: 16),
                      Text('Informasi Motor',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      buildInfoRow(
                          'Nama Motor', bookingData!['motor']?['name']),
                      buildInfoRow('Merk', bookingData!['motor']?['brand']),
                      buildInfoRow(
                          'Tahun', bookingData!['motor']?['year']?.toString()),
                      buildInfoRow('Harga',
                          'Rp ${bookingData!['motor']?['price'] ?? '-'}'),
                      buildInfoRow('Warna', bookingData!['motor']?['color']),
                      buildInfoRow('Tipe', bookingData!['motor']?['type']),
                      buildInfoRow(
                          'Deskripsi', bookingData!['motor']?['description']),
                      const SizedBox(height: 16),

                      // Menampilkan gambar motor
                      if (bookingData!['motor']?['image'] != null)
                        Image.network(
                          '$baseUrl${bookingData!['motor']['image']}',
                          height: 200,
                        ),
                      const SizedBox(height: 16),

                      // Menampilkan foto ID & Foto Diri
                      if (bookingData!['photo_id'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Foto KTP & Foto Diri',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Image.network(
                              '$baseUrl${bookingData!['photo_id']}',
                              height: 200,
                            ),
                          ],
                        ),

                      // Jika ada foto KTP
                      if (bookingData!['ktp_id'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Image.network(
                              '$baseUrl${bookingData!['ktp_id']}',
                              height: 200,
                            ),
                          ],
                        ),

                      // Tombol aksi sesuai status booking
                      const SizedBox(height: 20),
                      buildActionButton(bookingData!['status']),
                    ],
                  ),
                ),
    );
  }
}
