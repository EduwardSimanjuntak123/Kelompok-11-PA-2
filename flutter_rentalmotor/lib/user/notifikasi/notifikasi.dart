import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/user/pesanan/pesanan.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';

class NotifikasiPage extends StatefulWidget {
  final int userId;
  const NotifikasiPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late List<Map<String, dynamic>> _notifications = [];
  String _filterType = 'all'; // 'all', 'booking', 'system'
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _loadBookings();
  }

  List<Map<String, dynamic>> _bookings = [];
  Future<void> _loadBookings() async {
    try {
      // Membaca token dari storage
      String? token = await storage.read(key: "auth_token");
      print("TOKEN: $token");

      // Memastikan token ada sebelum melakukan permintaan
      if (token == null) {
        debugPrint('Token tidak ditemukan');
        return;
      }

      // Mengirim permintaan HTTP dengan token di header Authorization
      final response = await http.get(
        Uri.parse('http://192.168.24.159:8080/customer/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(
              data.map((e) => e as Map<String, dynamic>));
        });
      } else {
        debugPrint('Gagal mengambil bookings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saat mengambil bookings: $e');
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      final url = Uri.parse('http://192.168.24.159:8080/notifications/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        debugPrint('Notifikasi dengan ID $id berhasil dihapus');
      } else {
        debugPrint('Gagal menghapus notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saat menghapus notifikasi: $e');
    }
  }

  String? _getMotorImageByBookingId(int bookingId) {
    final booking = _bookings.firstWhere(
      (item) => item['id'] == bookingId,
      orElse: () => {},
    );
    final imagePath = booking['motor']?['image']?.toString();
    if (imagePath != null && imagePath.isNotEmpty) {
      return imagePath.startsWith('http')
          ? imagePath
          : 'http://192.168.24.159:8080$imagePath';
    }
    return null;
  }

  Future<void> _loadNotifications() async {
    final userId = widget.userId;
    debugPrint("User ID from parameter: $userId");

    final response = await http.get(
      Uri.parse('http://192.168.24.159:8080/notifications?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['notifications'];

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil notifikasi')),
      );
    }
  }

  Future<void> _updateNotificationStatus(int id, String status) async {
    try {
      final url = Uri.parse(
          'http://192.168.24.159:8080/notifications/$id/status?status=$status');
      final response = await http.put(url);

      if (response.statusCode == 200) {
        debugPrint('Status notifikasi $id diperbarui menjadi $status');
      } else {
        debugPrint('Gagal memperbarui status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error update status notifikasi: $e');
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return 'Waktu tidak valid';
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_filterType == 'all') {
      return _notifications;
    } else {
      return _notifications
          .where((notif) => notif['type'] == _filterType)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (value) {
                setState(() {
                  _filterType = value;
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'all', child: Text('Semua Notifikasi')),
                PopupMenuItem(value: 'booking', child: Text('Booking')),
                PopupMenuItem(value: 'system', child: Text('Sistem')),
              ],
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Semua Notifikasi'),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus semua notifikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _notifications.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _filteredNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = _filteredNotifications[index];
                final bool isRead = (notification['status'] == 'read') ||
                    (notification['read'] ?? false);

                final String timestamp = notification['created_at'] ??
                    DateTime.now().toIso8601String();
                final String type = notification['type'] ?? 'system';

                return Dismissible(
                  key: Key('notification_${notification['id']}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    setState(() {
                      _notifications.remove(notification);
                    });

                    if (notification.containsKey('id')) {
                      await _deleteNotification(notification['id']);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifikasi dihapus'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.shade200
                            : Colors.blue.shade200,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: notification.containsKey('booking_id')
                            ? Image.network(
                                _getMotorImageByBookingId(
                                        notification['booking_id']) ??
                                    '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.motorcycle,
                                        size: 32, color: Colors.grey),
                              )
                            : Icon(
                                type == 'booking'
                                    ? Icons.motorcycle
                                    : Icons.notifications,
                                color: isRead ? Colors.grey : Colors.blue,
                              ),
                      ),
                      title: Text(
                        notification['message'] ?? 'Notifikasi',
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead ? Colors.black87 : Colors.black,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatTimestamp(timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      onTap: () async {
                        // 1. Log notifikasi dan booking_id
                        debugPrint(
                            '>> onTap notification: ${notification['id']}');
                        if (notification.containsKey('booking_id')) {
                          final bookingId = notification['booking_id'];
                          debugPrint(
                              '>> Found booking_id: $bookingId, mencari di _bookings…');
                        } else {
                          debugPrint(
                              '!! Notifikasi ini tidak memiliki booking_id');
                        }

                        // 2. Tandai sebagai read
                        setState(() {
                          notification['status'] = 'read';
                          notification['read'] = true;
                        });
                        if (notification.containsKey('id')) {
                          await _updateNotificationStatus(
                              notification['id'], 'read');
                          debugPrint(
                              '>> Status notifikasi ${notification['id']} di‐update ke read di server');
                        }

                        // 3. Coba cari booking di lokal
                        if (notification.containsKey('booking_id')) {
                          final bookingId = notification['booking_id'];
                          final booking = _bookings.firstWhere(
                            (item) => item['id'] == bookingId,
                            orElse: () {
                              debugPrint(
                                  '!! booking dengan id $bookingId tidak ditemukan di _bookings');
                              return <String, dynamic>{};
                            },
                          );

                          // 4. Jika booking ada, navigasi
                          if (booking.isNotEmpty) {
                            debugPrint(
                                '>> Navigasi ke PesananPage dengan booking: $booking');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PesananPage(booking: booking),
                              ),
                            ).then((_) {
                              debugPrint('<< Kembali dari PesananPage');
                            });
                          }
                        }
                      },
                      trailing: !isRead
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: _notifications.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      for (var notification in _notifications) {
                        notification['status'] = 'read';
                        notification['read'] = true;
                        if (notification.containsKey('id')) {
                          _updateNotificationStatus(notification['id'], 'read');
                        }
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tandai semua sebagai dibaca',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
