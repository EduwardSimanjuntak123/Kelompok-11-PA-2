import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarPesananVendorScreen extends StatefulWidget {
  const DaftarPesananVendorScreen({Key? key}) : super(key: key);

  @override
  State<DaftarPesananVendorScreen> createState() =>
      _DaftarPesananVendorScreenState();
}

class _DaftarPesananVendorScreenState extends State<DaftarPesananVendorScreen> {
  final storage = const FlutterSecureStorage();
  final String baseUrl = 'http://192.168.132.159:8080';
  bool isLoading = true;
  List<dynamic> bookings = [];
  String selectedStatus = 'Semua';

  final List<String> statusFilters = [
    'Semua',
    'pending',
    'confirmed',
    'in transit',
    'in use',
    'awaiting return',
    'completed',
    'canceled',
    'rejected',
  ];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      final token = await storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('✅ Status Code: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookings = data;
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat pesanan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredBookings {
    if (selectedStatus == 'Semua') return bookings;
    return bookings.where((b) => b['status'] == selectedStatus).toList();
  }

  Widget buildStatusFilter() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusFilters.length,
        itemBuilder: (context, index) {
          final status = statusFilters[index];
          final isSelected = selectedStatus == status;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(status),
              selected: isSelected,
              selectedColor: const Color(0xFF2C567E),
              onSelected: (_) {
                setState(() {
                  selectedStatus = status;
                });
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildBookingCard(dynamic booking) {
    final motor = booking['motor'];
    final imageUrl =
        motor?['image']?.replaceFirst("localhost", "192.168.132.159");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Customer: ${booking['customer_name'] ?? 'Tidak diketahui'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Motor: ${motor?['name'] ?? 'Tidak diketahui'}'),
                  Text('Booking: ${booking['booking_date'] ?? '-'}'),
                  Text('Mulai: ${booking['start_date'] ?? '-'}'),
                  Text('Selesai: ${booking['end_date'] ?? '-'}'),
                  Text('Status: ${booking['status'] ?? '-'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C567E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 10),
                buildStatusFilter(),
                const Divider(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchBookings,
                    child: filteredBookings.isEmpty
                        ? const Center(
                            child: Text('Tidak ada pesanan dengan status ini.'))
                        : ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              return buildBookingCard(filteredBookings[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
