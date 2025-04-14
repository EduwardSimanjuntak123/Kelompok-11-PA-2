import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotifikasiPage extends StatefulWidget {
  // Ubah parameter dari List<String> menjadi List<Map<String, dynamic>>
  final List<Map<String, dynamic>> notifications;

  const NotifikasiPage({Key? key, required this.notifications})
      : super(key: key);

  @override
  _NotifikasiPageState createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('notification_list');

    List<Map<String, dynamic>> storedNotifications = [];
    if (stored != null) {
      final List<dynamic> rawList = json.decode(stored);
      storedNotifications = rawList.cast<Map<String, dynamic>>();
    }

    // Merge notifikasi baru (dari widget.notifications) dengan yang sudah tersimpan,
    // dengan pengecekan agar tidak terjadi duplikasi.
    for (var notif in widget.notifications) {
      if (!storedNotifications.any((existing) =>
          existing['text'] == notif['text'] &&
          existing['timestamp'] == notif['timestamp'])) {
        storedNotifications.add(notif);
      }
    }

    _notifications = storedNotifications;
    _sortNotifications();
    _saveNotifications();
    setState(() {});
  }

  void _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notification_list', json.encode(_notifications));
  }

  void _sortNotifications() {
    _notifications.sort((a, b) => DateTime.parse(b['timestamp'])
        .compareTo(DateTime.parse(a['timestamp'])));
  }

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]['read'] = true;
    });
    _saveNotifications();
  }

  void _removeNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
    _saveNotifications();
  }

  Future<void> _refreshNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _sortNotifications();
    setState(() {});
  }

  String _formatTime(String iso) {
    final dt = DateTime.parse(iso);
    return DateFormat.Hm().format(dt);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;

    if (diff == 0) return 'Hari ini';
    if (diff == 1) return 'Kemarin';
    return DateFormat("EEEE, d MMMM y", 'id').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan notifikasi berdasarkan tanggal (format yyyy-MM-dd)
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var notif in _notifications) {
      final dt = DateTime.parse(notif['timestamp']);
      final dateKey = DateFormat('yyyy-MM-dd').format(dt);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notif);
    }

    // Urutkan key secara descending (paling baru di atas)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    // Hitung total item untuk ListView (header tiap grup + item)
    final int totalCount =
        sortedKeys.fold<int>(0, (sum, k) => sum + grouped[k]!.length + 1);

    int runningIndex = 0; // untuk iterasi indeks kombinasi header dan item

    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Notifikasi")),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: _notifications.isEmpty
            ? const Center(child: Text("Tidak ada notifikasi"))
            : ListView.builder(
                itemCount: totalCount,
                itemBuilder: (context, index) {
                  int currentIndex = 0;
                  for (var dateKey in sortedKeys) {
                    // Header grup
                    if (index == currentIndex) {
                      final headerDate = DateTime.parse(dateKey);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Text(
                          _formatDateHeader(headerDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      );
                    }
                    currentIndex++;

                    final items = grouped[dateKey]!;
                    if (index < currentIndex + items.length) {
                      final notifIndex = index - currentIndex;
                      final notif = items[notifIndex];
                      final globalIndex = _notifications.indexWhere((element) =>
                          element['text'] == notif['text'] &&
                          element['timestamp'] == notif['timestamp']);
                      final isRead = notif['read'] as bool;

                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          _removeNotification(globalIndex);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Notifikasi terhapus")),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _markAsRead(globalIndex),
                          child: Card(
                            color: isRead ? Colors.white : Colors.blue[50],
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                isRead
                                    ? Icons.mark_email_read
                                    : Icons.mark_email_unread,
                                color: isRead ? Colors.grey : Colors.blue,
                              ),
                              title: Text(
                                notif['text'],
                                style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                _formatTime(notif['timestamp']),
                                style: TextStyle(
                                  color: isRead ? Colors.grey : Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _removeNotification(globalIndex),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    currentIndex += items.length;
                  }
                  return const SizedBox.shrink(); // fallback
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
