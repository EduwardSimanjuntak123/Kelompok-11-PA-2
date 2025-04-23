import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotifikasiPage extends StatefulWidget {
  final List<Map<String, dynamic>> notifications;

  const NotifikasiPage({Key? key, required this.notifications})
      : super(key: key);

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  late List<Map<String, dynamic>> _notifications;
  String _filterType = 'all'; // 'all', 'booking', 'system'

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.notifications);
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
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('Semua Notifikasi'),
                ),
                const PopupMenuItem(
                  value: 'booking',
                  child: Text('Booking'),
                ),
                const PopupMenuItem(
                  value: 'system',
                  child: Text('Sistem'),
                ),
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
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = _filteredNotifications[index];
                final bool isRead = notification['read'] ?? false;
                final String timestamp = notification['timestamp'] ??
                    DateTime.now().toIso8601String();
                final String type = notification['type'] ?? 'system';

                return Dismissible(
                  key: Key(
                      'notification_${index}_${DateTime.now().millisecondsSinceEpoch}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.remove(notification);
                    });
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
                      leading: CircleAvatar(
                        backgroundColor: isRead
                            ? Colors.grey.shade200
                            : Colors.blue.shade100,
                        child: Icon(
                          type == 'booking'
                              ? Icons.motorcycle
                              : Icons.notifications,
                          color: isRead ? Colors.grey.shade600 : Colors.blue,
                        ),
                      ),
                      title: Text(
                        notification['text'] ?? 'Notifikasi',
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
                      onTap: () {
                        setState(() {
                          notification['read'] = true;
                        });

                        // If it's a booking notification, you could navigate to booking details
                        if (type == 'booking' &&
                            notification.containsKey('booking_id')) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => BookingDetailPage(
                          //       bookingId: notification['booking_id'],
                          //     ),
                          //   ),
                          // );
                        }
                      },
                      trailing: !isRead
                          ? Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
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
                        notification['read'] = true;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua notifikasi telah dibaca'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tandai Semua Dibaca',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    // Return updated notifications to the previous screen
    Navigator.pop(context, _notifications);
    super.dispose();
  }
}
