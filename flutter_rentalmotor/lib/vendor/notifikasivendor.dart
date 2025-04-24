import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      message: json['text'] ?? json['message'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      read: json['read'] ?? false,
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
  final List<Map<String, dynamic>>? notifications;
  
  const NotifikasiPagev({Key? key, this.notifications}) : super(key: key);
  
  @override
  State<NotifikasiPagev> createState() => _NotifikasiPagevState();
}

class _NotifikasiPagevState extends State<NotifikasiPagev> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('notification_list');

      List<AppNotification> storedNotifications = [];
      if (stored != null) {
        final List<dynamic> rawList = json.decode(stored);
        storedNotifications = rawList
            .cast<Map<String, dynamic>>()
            .map((json) => AppNotification.fromJson(json))
            .toList();
      }

      // Merge notifikasi baru (dari widget.notifications) dengan yang sudah tersimpan
      if (widget.notifications != null) {
        for (var notif in widget.notifications!) {
          final newNotif = AppNotification.fromJson(notif);
          if (!storedNotifications.any((existing) =>
              existing.message == newNotif.message &&
              existing.timestamp.isAtSameMomentAs(newNotif.timestamp))) {
            storedNotifications.add(newNotif);
          }
        }
      }

      // Urutkan berdasarkan timestamp terbaru
      storedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _notifications = storedNotifications;
        _isLoading = false;
      });

      // Simpan kembali notifikasi yang sudah dimerge
      await _saveNotifications(storedNotifications);
    } catch (e) {
      debugPrint("Error loading notifications: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveNotifications(List<AppNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notifications.map((n) => n.toJson()).toList();
      await prefs.setString('notification_list', json.encode(jsonList));
    } catch (e) {
      debugPrint("Error saving notifications: $e");
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    setState(() {
      notification.read = true;
    });
    await _saveNotifications(_notifications);
  }

  @override
  Widget build(BuildContext context) {
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
                    content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() => _notifications = []);
                          await _saveNotifications([]);
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(context, notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, AppNotification notification) {
    // Parse message untuk mendapatkan informasi booking
    String title = 'Notifikasi';
    String message = notification.message;
    
    // Cek apakah pesan mengandung format "Booking #123: Pesan"
    if (message.contains('Booking #')) {
      title = 'Pesanan Masuk';
      // Ekstrak ID booking jika ada
      final bookingIdMatch = RegExp(r'Booking #(\d+)').firstMatch(message);
      if (bookingIdMatch != null) {
        final bookingId = bookingIdMatch.group(1);
        message = message.replaceFirst(RegExp(r'Booking #\d+: '), '');
      }
    }

    // Format tanggal
    final dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
    final formattedDate = dateFormatter.format(notification.timestamp);

    return InkWell(
      onTap: () {
        _markAsRead(notification);
        // Tambahkan navigasi ke detail pesanan jika diperlukan
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
            // Icon notifikasi
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                title == 'Pesanan Masuk' ? Icons.motorcycle : Icons.notifications,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Informasi Notifikasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Icon panah ke kanan
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}