import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KelolaPerpanjnganSewa extends StatefulWidget {
  const KelolaPerpanjnganSewa({Key? key}) : super(key: key);

  @override
  State<KelolaPerpanjnganSewa> createState() => _KelolaPerpanjnganSewaState();
}

final String baseUrl = ApiConfig.baseUrl;
final storage = const FlutterSecureStorage();

class _KelolaPerpanjnganSewaState extends State<KelolaPerpanjnganSewa> {
  bool isLoading = true;
  List<dynamic> extensions = [];
  Map<int, dynamic> bookings = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final String? token = await storage.read(key: "auth_token");

      if (token == null) {
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
        });
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final extensionsResponse = await http.get(
        Uri.parse('$baseUrl/vendor/extensions'),
        headers: headers,
      );

      if (extensionsResponse.statusCode == 200) {
        final extensionsData = json.decode(extensionsResponse.body);
        extensions = extensionsData['extensions'];

        final bookingsResponse = await http.get(
          Uri.parse('$baseUrl/vendor/bookings/'),
          headers: headers,
        );

        if (bookingsResponse.statusCode == 200) {
          final List<dynamic> bookingsData = json.decode(bookingsResponse.body);

          for (var booking in bookingsData) {
            bookings[booking['id']] = booking;
          }
        } else {
          setState(() {
            errorMessage =
                'Gagal memuat data bookings: ${bookingsResponse.statusCode}';
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data perpanjangan: ${extensionsResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveExtension(int extensionId) async {
    try {
      final String? token = await storage.read(key: "auth_token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/vendor/extensions/$extensionId/approve'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perpanjangan berhasil disetujui')),
        );
        fetchData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyetujui: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> rejectExtension(int extensionId) async {
    try {
      final String? token = await storage.read(key: "auth_token");

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token tidak ditemukan. Silakan login ulang.')),
        );
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.put(
        Uri.parse('$baseUrl/vendor/extensions/$extensionId/reject'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perpanjangan berhasil ditolak')),
        );
        fetchData(); // Refresh data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menolak: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Perpanjangan Sewa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : extensions.isEmpty
                  ? const Center(
                      child: Text('Tidak ada permintaan perpanjangan'))
                  : RefreshIndicator(
                      onRefresh: fetchData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: extensions.length,
                        itemBuilder: (context, index) {
                          final extension = extensions[index];
                          final booking = bookings[extension['booking_id']];
                          final String motorImageUrl = booking != null
                              ? '$baseUrl${booking['motor']['image']}'
                              : '';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Motor Image
                                      if (motorImageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            motorImageUrl,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 100,
                                                height: 100,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              );
                                            },
                                          ),
                                        ),
                                      const SizedBox(width: 16),
                                      // Extension Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              extension['motor_name'] ??
                                                  'Unknown Motor',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Pelanggan: ${extension['customer_name']}',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: getStatusColor(
                                                    extension['status']),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                getStatusText(
                                                    extension['status']),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  // Extension Details
                                  Text(
                                    'Biaya Tambahan: Rp ${NumberFormat('#,###').format(extension['additional_price'])}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tanggal Permintaan: ${formatDate(extension['requested_at'])}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Perpanjangan Hingga: ${formatDate(extension['requested_end_date'])}',
                                  ),
                                  if (extension['approved_at'] != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Disetujui Pada: ${formatDate(extension['approved_at'])}',
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  // Action Buttons
                                  if (extension['status'].toLowerCase() !=
                                          'approved' &&
                                      extension['status'].toLowerCase() !=
                                          'rejected')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton(
                                          onPressed: () => rejectExtension(
                                              extension['extension_id']),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Tolak'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => approveExtension(
                                              extension['extension_id']),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Setujui'),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
