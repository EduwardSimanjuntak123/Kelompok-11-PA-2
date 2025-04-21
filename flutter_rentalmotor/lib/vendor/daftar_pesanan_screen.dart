import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rentalmotor/services/vendor/kelola_Booking_service.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

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
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (!isRefreshing) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final token = await storage.read(key: 'auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookings = data;
          isLoading = false;
          isRefreshing = false;
        });
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
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await fetchBookings();
  }

  List<dynamic> get filteredBookings {
    if (selectedStatus == 'Semua') return bookings;
    return bookings.where((b) => b['status'] == selectedStatus).toList();
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(status),
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
    final imageUrl =
        motor?['image']?.replaceFirst("localhost", "192.168.132.159");
    final status = booking['status'] ?? '-';
    final statusColor = statusColors[status] ?? Colors.grey;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
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
                  'Booking #${booking['id'] ?? '-'}',
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
                    status,
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

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Motor Image
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
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

                // Booking details
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
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
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

          // Action buttons
          if (_shouldShowActions(status))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: _buildActionButtons(booking),
              ),
            ),
        ],
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

  bool _shouldShowActions(String status) {
    return ['pending', 'confirmed', 'in transit', 'awaiting return']
        .contains(status);
  }

  List<Widget> _buildActionButtons(dynamic booking) {
    final status = booking['status'];
    final id = booking['id'];

    switch (status) {
      case 'pending':
        return [
          _buildActionButton(
            label: 'Tolak',
            icon: Icons.cancel,
            color: Colors.red,
            onPressed: () => _showConfirmationDialog(
              'Tolak Pesanan',
              'Apakah Anda yakin ingin menolak pesanan ini?',
              () => _bookingService.rejectBooking(id),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            label: 'Terima',
            icon: Icons.check_circle,
            color: Colors.green,
            onPressed: () => _showConfirmationDialog(
              'Terima Pesanan',
              'Apakah Anda yakin ingin menerima pesanan ini?',
              () => _bookingService.confirmBooking(id),
            ),
          ),
        ];
      case 'confirmed':
        return [
          _buildActionButton(
            label: 'Dalam Perjalanan',
            icon: Icons.directions_bike,
            color: Colors.blue,
            onPressed: () => _showConfirmationDialog(
              'Ubah Status',
              'Ubah status menjadi "Dalam Perjalanan"?',
              () => _bookingService.setBookingToTransit(id),
            ),
          ),
        ];
      case 'in transit':
        return [
          _buildActionButton(
            label: 'Digunakan',
            icon: Icons.motorcycle,
            color: Colors.teal,
            onPressed: () => _showConfirmationDialog(
              'Ubah Status',
              'Ubah status menjadi "Digunakan"?',
              () => _bookingService.setBookingToInUse(id),
            ),
          ),
        ];
      case 'awaiting return':
        return [
          _buildActionButton(
            label: 'Selesai',
            icon: Icons.done_all,
            color: Colors.green,
            onPressed: () => _showConfirmationDialog(
              'Selesaikan Pesanan',
              'Apakah Anda yakin ingin menyelesaikan pesanan ini?',
              () => _bookingService.completeBooking(id),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  void _showConfirmationDialog(
      String title, String message, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
              _refreshData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
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
        backgroundColor: const Color(0xFF1976D2),
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
                    ))
                  : filteredBookings.isEmpty
                      ? Center(
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
                                'Tidak ada pesanan ${selectedStatus != 'Semua' ? 'dengan status $selectedStatus' : ''}',
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
