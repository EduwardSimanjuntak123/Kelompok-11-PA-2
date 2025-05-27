import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rentalmotor/services/vendor/kelola_Booking_service.dart';

import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/view/vendor/detail_booking_screen.dart';

class DaftarPesananVendorScreen extends StatefulWidget {
  const DaftarPesananVendorScreen({Key? key}) : super(key: key);

  @override
  State<DaftarPesananVendorScreen> createState() =>
      _DaftarPesananVendorScreenState();
}

class _DaftarPesananVendorScreenState extends State<DaftarPesananVendorScreen> {
  final storage = const FlutterSecureStorage();
  final String baseUrl = '${ApiConfig.baseUrl}';
  bool isLoading = true;
  List<dynamic> bookings = [];
  String selectedStatus = 'Semua';
  bool isRefreshing = false;

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
  final Map<String, String> statusLabelsIndo = {
    'pending': 'Menunggu',
    'confirmed': 'Dikonfirmasi',
    'in transit': 'Dalam Pengiriman',
    'in use': 'Sedang Dipakai',
    'awaiting return': 'Menunggu Pengembalian',
    'completed': 'Selesai',
    'canceled': 'Dibatalkan',
    'rejected': 'Ditolak',
    'Semua': 'Semua',
  };

  // Status priority order (lower index = higher priority)
  final List<String> statusPriority = [
    'pending',
    'confirmed',
    'in transit',
    'in use',
    'awaiting return',
    'completed',
    'canceled',
    'rejected',
  ];

  final Map<String, Color> statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'in transit': Colors.purple,
    'in use': Colors.teal,
    'awaiting return': Colors.amber,
    'completed': Colors.green,
    'canceled': Colors.red,
    'rejected': Colors.red.shade900,
  };

  final KelolaBookingService _bookingService = KelolaBookingService();

  @override
  void initState() {
    super.initState();
    _refreshData(); // Refresh data saat aplikasi dibuka
  }

  Future<void> fetchBookings() async {
    if (!isRefreshing) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final token = await storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan masuk kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("📡 GET: $baseUrl/vendor/bookings");
      print("📦 Status Code: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty || response.body == 'null') {
          // Jika kosong atau null
          setState(() {
            bookings = [];
          });
          print('⚠️ Data bookings kosong.');
        } else {
          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            // Jika response adalah List langsung
            setState(() {
              bookings = decoded;
            });
          } else if (decoded is Map && decoded['data'] is List) {
            // Jika data ada di dalam key "data"
            setState(() {
              bookings = decoded['data'];
            });
          } else {
            throw Exception("Format data bookings tidak dikenali.");
          }
        }
      } else {
        throw Exception('Gagal memuat pesanan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        isLoading = false;
        isRefreshing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      isLoading = false;
      isRefreshing = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await fetchBookings();
  }

  List<dynamic> get filteredBookings {
    if (selectedStatus == 'Semua') {
      // Sort bookings by status priority
      final sortedBookings = List<dynamic>.from(bookings);
      sortedBookings.sort((a, b) {
        // First sort by status priority
        final statusA = a['status'] ?? '';
        final statusB = b['status'] ?? '';

        final priorityA = statusPriority.indexOf(statusA);
        final priorityB = statusPriority.indexOf(statusB);

        if (priorityA != priorityB) {
          return priorityA - priorityB;
        }

        // If same status, sort by newest booking date
        final dateA = a['booking_date'] != null
            ? DateTime.parse(a['booking_date'])
            : DateTime(1900);
        final dateB = b['booking_date'] != null
            ? DateTime.parse(b['booking_date'])
            : DateTime(1900);

        return dateB.compareTo(dateA); // Newest first
      });

      return sortedBookings;
    }

    // If filtering by specific status, still sort by date (newest first)
    final filtered =
        bookings.where((b) => b['status'] == selectedStatus).toList();
    filtered.sort((a, b) {
      final dateA = a['booking_date'] != null
          ? DateTime.parse(a['booking_date'])
          : DateTime(1900);
      final dateB = b['booking_date'] != null
          ? DateTime.parse(b['booking_date'])
          : DateTime(1900);
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  Widget buildStatusFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statusFilters.length,
        itemBuilder: (context, index) {
          final status = statusFilters[index];
          final isSelected = selectedStatus == status;
          final statusColor = status == 'Semua'
              ? const Color(0xFF1976D2)
              : statusColors[status] ?? Colors.grey;
          final statusLabel = statusLabelsIndo[status] ?? status;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(statusLabel),
              selected: isSelected,
              selectedColor: statusColor.withOpacity(0.2),
              checkmarkColor: statusColor,
              labelStyle: TextStyle(
                color: isSelected ? statusColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? statusColor : Colors.transparent,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  selectedStatus = status;
                });
              },
            ),
          );
        },
      ),
    );
  }

  String formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget buildBookingCard(dynamic booking) {
    final motor = booking['motor'];
    final imageUrl = motor?['image']
        ?.replaceFirst("localhost", "192.168.151.159"); // Menggunakan baseUrl
    final status = booking['status'] ?? '-';
    final statusColor = statusColors[status] ?? Colors.grey;
    final statusLabel = statusLabelsIndo[status] ?? status;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBookingPage(bookingId: booking['id']),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '$baseUrl$imageUrl', // Menggunakan baseUrl untuk gambar
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.motorcycle,
                              color: Colors.grey, size: 40),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.motorcycle,
                          color: Colors.grey, size: 40),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          motor?['name'] ?? 'Tidak diketahui',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customer: ${booking['customer_name'] ?? 'Tidak diketahui'}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.calendar_today,
                            'Booking: ${formatDate(booking['booking_date'])}'),
                        _buildInfoRow(Icons.play_circle_outline,
                            'Mulai: ${formatDate(booking['start_date'])}'),
                        _buildInfoRow(Icons.stop_circle_outlined,
                            'Selesai: ${formatDate(booking['end_date'])}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1976D2)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Daftar Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1A567D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          buildStatusFilter(),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF1976D2),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                      ),
                    )
                  : filteredBookings.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_outlined,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tidak ada pesanan ${selectedStatus != 'Semua' ? 'dengan status ${statusLabelsIndo[selectedStatus] ?? selectedStatus}' : ''}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Tarik ke bawah untuk menyegarkan',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
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
