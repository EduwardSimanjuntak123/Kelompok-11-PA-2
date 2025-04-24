import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/vendor/detail_booking_screen.dart';

class AppNotification {
  final String id;
  final String message;
  final DateTime timestamp;
  bool read;

  AppNotification({
    required this.id,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      message: json['text'] ?? json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      read: json['read'] ?? json['status'] == 'read',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': message,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };
}

class NotifikasiPagev extends StatefulWidget {
  final int userId;
  const NotifikasiPagev({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotifikasiPagev> createState() => _NotifikasiPagevState();
}

class _NotifikasiPagevState extends State<NotifikasiPagev> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  int _vendorId = 0;
  final storage = FlutterSecureStorage();
  final String baseUrl = 'http://192.168.24.159:8080';

  @override
  void initState() {
    super.initState();
    debugPrint('NotifikasiPagev initialized with userId: ${widget.userId}');
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      debugPrint('Loading initial data...');
      await _loadBookings();
      await _loadNotifications();
      debugPrint('Initial data loaded successfully');
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  String? _getMotorImageByBookingId(int bookingId) {
    try {
      debugPrint('Getting motor image for booking ID: $bookingId');

      // Check if bookings is empty
      if (_bookings.isEmpty) {
        debugPrint('Bookings list is empty');
        return null;
      }

      final booking = _bookings.firstWhere(
        (b) => b['id'] == bookingId,
        orElse: () => {},
      );

      // More verbose debugging
      debugPrint('Looking for booking ID: $bookingId');
      debugPrint('Found booking: ${booking.isEmpty ? "Not found" : "Found"}');

      // Check if booking is empty
      if (booking.isEmpty) {
        debugPrint('Booking not found for ID: $bookingId');
        return null;
      }

      // Check if motor exists
      if (booking['motor'] == null) {
        debugPrint('Motor data is null for booking ID: $bookingId');
        return null;
      }

      final imagePath = booking['motor']['image'];
      debugPrint('Motor Image Path: $imagePath');

      if (imagePath != null && imagePath is String && imagePath.isNotEmpty) {
        final fullUrl =
            imagePath.startsWith('http') ? imagePath : '$baseUrl$imagePath';
        debugPrint('Full Motor Image URL: $fullUrl');
        return fullUrl;
      } else {
        debugPrint('Image path is null, empty, or not a string');
      }
      return null;
    } catch (e) {
      debugPrint('Error in _getMotorImageByBookingId: $e');
      return null;
    }
  }

  Future<void> _loadBookings() async {
    try {
      debugPrint('Loading bookings...');
      // Ambil token dari secure storage
      String? token = await storage.read(key: "auth_token");

      if (token == null) {
        debugPrint('Token tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Bookings API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        debugPrint('Received ${data.length} bookings');

        setState(() {
          _bookings = List<Map<String, dynamic>>.from(data);
        });

        // Log the first booking for debugging
        if (_bookings.isNotEmpty) {
          debugPrint('First booking sample: ${json.encode(_bookings.first)}');
        }
      } else {
        debugPrint('Gagal ambil bookings: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error ambil bookings: $e');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('Loading notifications for user ID: ${widget.userId}');
      final response = await http.get(
        Uri.parse('$baseUrl/notifications?user_id=${widget.userId}'),
      );

      debugPrint('Notifications API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['notifications'];
        debugPrint('Received ${data.length} notifications');

        setState(() {
          _notifications =
              data.map((item) => AppNotification.fromJson(item)).toList();
        });

        // Log the first notification for debugging
        if (_notifications.isNotEmpty) {
          debugPrint(
              'First notification sample: ${json.encode(_notifications.first.toJson())}');
        }
      } else {
        debugPrint('Failed to load notifications: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint("Gagal load notifikasi: $e");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _markAsRead(AppNotification notification) async {
    try {
      debugPrint('Marking notification ${notification.id} as read');
      setState(() => notification.read = true);
      final response = await http.put(
        Uri.parse(
            '$baseUrl/notifications/${notification.id}/status?status=read'),
      );

      debugPrint('Mark as read API response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint(
            'Failed to mark notification as read: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      debugPrint('Deleting notification with ID: $id');
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$id'),
      );

      debugPrint(
          'Delete notification API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
        });
        debugPrint('Notification deleted successfully');
      } else {
        debugPrint('Failed to delete notification: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint("Gagal hapus notifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building NotifikasiPagev widget');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
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
                        onPressed: () async {
                          for (var notif in _notifications) {
                            await _deleteNotification(notif.id);
                          }
                          setState(() => _notifications.clear());
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada notifikasi',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    debugPrint('Manual refresh triggered');
                    await _loadInitialData();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) =>
                            _deleteNotification(notification.id),
                        child: _buildNotificationItem(context, notification),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('Manual refresh button pressed');
          await _loadInitialData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data refreshed')),
          );
        },
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, AppNotification notification) {
    String title = 'Notifikasi';
    String message = notification.message;
    int? bookingId;

    // Coba ekstrak ID booking dari pesan notifikasi
    if (message.contains("booking baru")) {
      title = 'Pesanan Masuk';

      // Cari booking yang cocok berdasarkan nama pelanggan dan motor
      try {
        // Ekstrak nama pelanggan dan nama motor dari pesan
        final customerNameMatch = RegExp(r'dari ([^untuk]+)').firstMatch(message);
        final motorNameMatch = RegExp(r'untuk motor ([^pada]+)').firstMatch(message);

        if (customerNameMatch != null && motorNameMatch != null) {
          final customerName = customerNameMatch.group(1)?.trim();
          final motorName = motorNameMatch.group(1)?.trim();

          debugPrint('Mencari booking dengan customer: $customerName, motor: $motorName');

          // Cari booking yang cocok
          final matchingBooking = _bookings.firstWhere(
            (b) =>
                b['customer_name']?.toString().contains(customerName ?? '') == true &&
                b['motor']?['name']?.toString().contains(motorName ?? '') == true,
            orElse: () => {},
          );

          if (matchingBooking.isNotEmpty) {
            bookingId = matchingBooking['id'];
            debugPrint('Menemukan booking ID: $bookingId dari pesan notifikasi');
          }
        }
      } catch (e) {
        debugPrint('Error saat mencoba ekstrak booking ID: $e');
      }
    }

    final formattedDate =
        DateFormat('dd-MM-yyyy HH:mm').format(notification.timestamp);

    return InkWell(
      onTap: () async {
        try {
          await _markAsRead(notification);
          debugPrint('Notifikasi ditekan: ${notification.id}');
          debugPrint('Pesan: ${notification.message}');

          if (bookingId != null) {
            debugPrint('Redirect ke detail pesanan dengan ID: $bookingId');

            // Force reload bookings to ensure we have the latest data
            await _loadBookings();

            final booking = _bookings.firstWhere(
              (b) => b['id'] == bookingId,
              orElse: () => {},
            );

            if (booking.isNotEmpty) {
              debugPrint('Booking ditemukan, data: ${json.encode(booking)}');
              // Use Future.delayed to ensure the UI has time to update
              Future.delayed(Duration.zero, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailBookingPage(bookingId: booking['id']),
                  ),
                );
              });
            } else {
              debugPrint(
                  'Booking dengan ID $bookingId tidak ditemukan dalam _bookings');
              debugPrint(
                  'Semua booking IDs: ${_bookings.map((b) => b['id']).toList()}');

              // Try to navigate anyway with just the ID
              Future.delayed(Duration.zero, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailBookingPage(bookingId: bookingId!),
                  ),
                );
              });
            }
          } else {
            debugPrint('Booking ID tidak ditemukan di pesan notifikasi');
          }
        } catch (e) {
          debugPrint('Error handling notification tap: $e');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: bookingId != null &&
                      _getMotorImageByBookingId(bookingId) != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _getMotorImageByBookingId(bookingId)!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: $error');
                          return Icon(
                            Icons.motorcycle,
                            color: Colors.blue.shade700,
                            size: 24,
                          );
                        },
                      ),
                    )
                  : Icon(
                      title == 'Pesanan Masuk'
                          ? Icons.motorcycle
                          : Icons.notifications,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(message,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(formattedDate,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
