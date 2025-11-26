import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/view/user/pesanan/detail_pesanan/pesanan.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'dart:convert';

class NotifikasiPage extends StatefulWidget {
  final int userId;
  const NotifikasiPage({super.key, required this.userId});

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late List<Map<String, dynamic>> _notifications = [];
  final storage = FlutterSecureStorage();
  final Color _themeColor = const Color(0xFF225378);

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
        Uri.parse('${ApiConfig.baseUrl}/customer/bookings'),
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
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications/$id');
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

    if (booking.isEmpty || booking['motor'] == null) {
      return null;
    }

    final imagePath = booking['motor']['image']?.toString();
    if (imagePath != null && imagePath.isNotEmpty) {
      return imagePath.startsWith('http')
          ? imagePath
          : '${ApiConfig.baseUrl}$imagePath';
    }
    return null;
  }

  Future<void> _loadNotifications() async {
    final userId = widget.userId;
    debugPrint("User ID from parameter: $userId");

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/notifications?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['notifications'];

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(
          data.map((item) => item as Map<String, dynamic>),
        );
        // Sort notifications by created_at in descending order (newest first)
        _notifications.sort((a, b) {
          final DateTime dateTimeA = DateTime.parse(
              a['created_at'] ?? DateTime.now().toIso8601String());
          final DateTime dateTimeB = DateTime.parse(
              b['created_at'] ?? DateTime.now().toIso8601String());
          return dateTimeB.compareTo(dateTimeA); // Reverse order (newest first)
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal mengambil notifikasi'),
          backgroundColor: _themeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _updateNotificationStatus(int id, String status) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}/notifications/$id/status?status=$status');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Hapus Semua Notifikasi',
                      style: TextStyle(
                          color: _themeColor, fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                        'Apakah Anda yakin ingin menghapus semua notifikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal',
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _notifications.clear();
                          });
                          Navigator.pop(context);
                        },
                        child: Text('Hapus',
                            style: TextStyle(
                                color: _themeColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _themeColor.withOpacity(0.05),
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _themeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: _themeColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada notifikasi',
                      style: TextStyle(
                        fontSize: 18,
                        color: _themeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Anda akan menerima notifikasi di sini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final bool isRead = (notification['status'] == 'read') ||
                      (notification['read'] ?? false);

                  final String timestamp = notification['created_at'] ??
                      DateTime.now().toIso8601String();
                  final String type = notification['type'] ?? 'system';

                  // Get motor image for booking notifications
                  String? motorImageUrl;
                  if (notification.containsKey('booking_id')) {
                    int bookingId = notification['booking_id'];
                    motorImageUrl = _getMotorImageByBookingId(bookingId);
                  }

                  return Dismissible(
                    key: Key('notification_${notification['id']}'),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(15),
                      ),
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
                        SnackBar(
                          content: const Text('Notifikasi dihapus'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: _themeColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFE8F1F8),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: _themeColor.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: isRead
                              ? Colors.grey.shade200
                              : _themeColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _themeColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: motorImageUrl != null
                                ? Image.network(
                                    motorImageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.motorcycle,
                                      size: 28,
                                      color: _themeColor,
                                    ),
                                  )
                                : Icon(
                                    type == 'booking'
                                        ? Icons.motorcycle
                                        : Icons.notifications,
                                    size: 28,
                                    color: _themeColor,
                                  ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            notification['message'] ?? 'Notifikasi',
                            style: TextStyle(
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.bold,
                              color: isRead
                                  ? _themeColor.withOpacity(0.8)
                                  : _themeColor,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimestamp(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: type == 'booking'
                                    ? _themeColor.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
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
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _themeColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
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
                    backgroundColor: _themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    shadowColor: _themeColor.withOpacity(0.4),
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
