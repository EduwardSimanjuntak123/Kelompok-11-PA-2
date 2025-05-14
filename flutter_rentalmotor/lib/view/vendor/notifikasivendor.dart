import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/view/vendor/detail_booking_screen.dart';

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

class _NotifikasiPagevState extends State<NotifikasiPagev>
    with SingleTickerProviderStateMixin {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  int _vendorId = 0;
  final storage = FlutterSecureStorage();
  final String baseUrl = 'http://192.168.34.159:8080';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D); // Modern indigo
  final Color secondaryColor = const Color(0xFF00BFA5); // Modern teal
  final Color accentColor = const Color(0xFFFF6D00); // Modern orange
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light gray
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF263238); // Dark gray
  final Color textSecondaryColor = const Color(0xFF607D8B); // Blue gray
  final Color successColor = const Color(0xFF4CAF50); // Success green
  final Color warningColor = const Color(0xFFFFC107); // Warning amber
  final Color dangerColor = const Color(0xFFF44336); // Danger red

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    debugPrint('NotifikasiPagev initialized with userId: ${widget.userId}');
    _loadInitialData();
    printAllSharedPrefs();
  }

  void printAllSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    if (keys.isEmpty) {
      print('Tidak ada data di SharedPreferences.');
    } else {
      for (String key in keys) {
        final value = prefs.get(key);
        print('$key: $value');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      debugPrint('Loading initial data...');
      await _loadBookings();
      await _loadNotifications();
      debugPrint('Initial data loaded successfully');
      _animationController.forward();
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
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.delete_forever, color: dangerColor),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Hapus Semua Notifikasi',
                          style: TextStyle(
                            color: textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      'Apakah Anda yakin ingin menghapus semua notifikasi?',
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: textSecondaryColor,
                        ),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          for (var notif in _notifications) {
                            await _deleteNotification(notif.id);
                          }
                          setState(() => _notifications.clear());
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: dangerColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete, size: 18),
                            const SizedBox(width: 8),
                            const Text('Hapus Semua'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient at the top
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Memuat notifikasi...',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_off_outlined,
                                size: 80,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Belum ada notifikasi',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Notifikasi akan muncul di sini',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            debugPrint('Manual refresh triggered');
                            await _loadInitialData();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return Dismissible(
                                key: Key(notification.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: dangerColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) =>
                                    _deleteNotification(notification.id),
                                child: _buildNotificationCard(
                                    context, notification),
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          debugPrint('Manual refresh button pressed');
          await _loadInitialData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.refresh, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Notifikasi diperbarui'),
                ],
              ),
              backgroundColor: successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.all(10),
            ),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        tooltip: 'Refresh Data',
        elevation: 4,
      ),
    );
  }

  Widget _buildNotificationCard(
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
        final customerNameMatch =
            RegExp(r'dari ([^untuk]+)').firstMatch(message);
        final motorNameMatch =
            RegExp(r'untuk motor ([^pada]+)').firstMatch(message);

        if (customerNameMatch != null && motorNameMatch != null) {
          final customerName = customerNameMatch.group(1)?.trim();
          final motorName = motorNameMatch.group(1)?.trim();

          debugPrint(
              'Mencari booking dengan customer: $customerName, motor: $motorName');

          // Cari booking yang cocok
          final matchingBooking = _bookings.firstWhere(
            (b) =>
                b['customer_name']?.toString().contains(customerName ?? '') ==
                    true &&
                b['motor']?['name']?.toString().contains(motorName ?? '') ==
                    true,
            orElse: () => {},
          );

          if (matchingBooking.isNotEmpty) {
            bookingId = matchingBooking['id'];
            debugPrint(
                'Menemukan booking ID: $bookingId dari pesan notifikasi');
          }
        }
      } catch (e) {
        debugPrint('Error saat mencoba ekstrak booking ID: $e');
      }
    }

    final formattedDate =
        DateFormat('dd MMM yyyy • HH:mm').format(notification.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.read ? cardColor : cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: notification.read
            ? Border.all(color: Colors.grey.shade200)
            : Border.all(color: primaryColor.withOpacity(0.5), width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
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
                  debugPrint(
                      'Booking ditemukan, data: ${json.encode(booking)}');
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon or Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: bookingId != null
                        ? primaryColor.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: bookingId != null
                          ? primaryColor.withOpacity(0.3)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: bookingId != null &&
                          _getMotorImageByBookingId(bookingId) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _getMotorImageByBookingId(bookingId)!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image: $error');
                              return Icon(
                                Icons.motorcycle,
                                color: primaryColor,
                                size: 30,
                              );
                            },
                          ),
                        )
                      : Icon(
                          title == 'Pesanan Masuk'
                              ? Icons.motorcycle
                              : Icons.notifications,
                          color: title == 'Pesanan Masuk'
                              ? primaryColor
                              : accentColor,
                          size: 30,
                        ),
                ),
                const SizedBox(width: 16),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: notification.read
                                    ? textPrimaryColor
                                    : primaryColor,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: textPrimaryColor.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time and Action Hint
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondaryColor,
                            ),
                          ),
                          if (bookingId != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility,
                                      size: 12, color: primaryColor),
                                  SizedBox(width: 4),
                                  Text(
                                    'Lihat Detail',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
