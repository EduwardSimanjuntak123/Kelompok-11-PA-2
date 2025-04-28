import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/chat/chat_page.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  List<dynamic> chatRooms = [];
  int? userId;
  WebSocketChannel? _notificationChannel;
  bool _isConnected = false;
  bool _isLoading = true;
  int _totalUnreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _loadUserAndFetchChatRooms();
  }

  Future<void> _loadUserAndFetchChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    print('🔍 ID pengguna dari SharedPreferences: $id');

    if (id != null) {
      setState(() => userId = id);
      await _fetchChatRooms(id);
      await _fetchUnreadCount(id);
      _connectToNotificationWebSocket(id);
    } else {
      print('⚠️ Tidak ditemukan user_id di SharedPreferences');
      setState(() => _isLoading = false);
    }
  }

  void _connectToNotificationWebSocket(int userId) {
    try {
      // Koneksi ke WebSocket notifikasi
      final wsUrl = '${ApiConfig.wsUrl}/ws/notifikasi?user_id=$userId';
      print('Connecting to notification WebSocket: $wsUrl');

      _notificationChannel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
      });

      _notificationChannel!.stream.listen(
        (dynamic data) {
          print('Notification WebSocket received: $data');
          try {
            // Ketika ada notifikasi baru, refresh daftar chat rooms
            _fetchChatRooms(userId);
            _fetchUnreadCount(userId);
          } catch (e) {
            print('Error handling notification: $e');
          }
        },
        onError: (error) {
          print('Notification WebSocket Error: $error');
          setState(() {
            _isConnected = false;
          });
          // Coba reconnect setelah error
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              _connectToNotificationWebSocket(userId);
            }
          });
        },
        onDone: () {
          print('Notification WebSocket connection closed');
          setState(() {
            _isConnected = false;
          });
          // Coba reconnect ketika koneksi tertutup
          if (mounted) {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted && !_isConnected) {
                _connectToNotificationWebSocket(userId);
              }
            });
          }
        },
      );
    } catch (e) {
      print('Error connecting to notification WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
      // Coba reconnect setelah error
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _connectToNotificationWebSocket(userId!);
        }
      });
    }
  }

  Future<void> _fetchChatRooms(int userId) async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/rooms?user_id=$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            chatRooms = data['chat_rooms'];
            _isLoading = false;
          });
        }
      } else {
        print(
          '❌ Gagal mengambil chat rooms dengan status: ${response.statusCode}',
        );
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('❌ Error fetching chat rooms: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Fungsi baru untuk mengambil jumlah total pesan yang belum dibaca
  Future<void> _fetchUnreadCount(int userId) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/unread?user_id=$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _totalUnreadMessages = data['total_unread'];
          });
        }
      } else {
        print(
          '❌ Gagal mengambil jumlah pesan belum dibaca: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching unread count: $e');
    }
  }

  // Fungsi untuk menandai semua pesan di chat room sebagai sudah dibaca
  Future<void> _markChatRoomAsRead(int chatRoomId) async {
    if (userId == null) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/mark-all-read");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'chat_room_id': chatRoomId, 'user_id': userId}),
      );

      if (response.statusCode == 200) {
        print('Chat room $chatRoomId marked as read');
        // Refresh chat rooms dan jumlah pesan belum dibaca
        _fetchChatRooms(userId!);
        _fetchUnreadCount(userId!);
      } else {
        print('Failed to mark chat room as read: ${response.statusCode}');
      }
    } catch (e) {
      print('Error marking chat room as read: $e');
    }
  }

  @override
  void dispose() {
    if (_notificationChannel != null) {
      _notificationChannel!.sink.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Pesan Masuk"),
            if (_totalUnreadMessages > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_totalUnreadMessages',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            if (!_isConnected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Offline', style: TextStyle(fontSize: 12)),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (userId != null) {
                _fetchChatRooms(userId!);
                _fetchUnreadCount(userId!);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Belum ada percakapan",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Mulai chat dengan vendor untuk menyewa motor",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    if (userId != null) {
                      await _fetchChatRooms(userId!);
                      await _fetchUnreadCount(userId!);
                    }
                  },
                  child: ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      final room = chatRooms[index];
                      final chatRoom = room['chat_room'];
                      final unreadCount = room['unread_count'] ?? 0;
                      final lastMessage = room['last_message'];
                      debugPrint("🧩 Room ID: ${chatRoom['id']}");
                      debugPrint("📦 lastMessage: $lastMessage");
                      final otherUserInfo = room['other_user_info'];

                      // Pastikan data tidak null
                      if (chatRoom == null || otherUserInfo == null) {
                        return const SizedBox.shrink();
                      }

                      // Ambil pesan terakhir untuk ditampilkan
                      String lastMessageTime = "";
                      bool isLastMessageUnread = false;

                      if (lastMessage != null) {
                        // Format waktu pesan terakhir
                        if (lastMessage['sent_at'] != null) {
                          try {
                            final DateTime sentAt = DateTime.parse(
                              lastMessage['sent_at'],
                            );
                            final now = DateTime.now();
                            final difference = now.difference(sentAt);

                            if (difference.inDays > 0) {
                              lastMessageTime = '${difference.inDays}d ago';
                            } else if (difference.inHours > 0) {
                              lastMessageTime = '${difference.inHours}h ago';
                            } else if (difference.inMinutes > 0) {
                              lastMessageTime = '${difference.inMinutes}m ago';
                            } else {
                              lastMessageTime = 'Just now';
                            }
                          } catch (e) {
                            lastMessageTime = '';
                          }
                        }

                        // Cek apakah pesan terakhir belum dibaca dan bukan dari user saat ini
                        isLastMessageUnread =
                            lastMessage['SenderID'] != userId &&
                                lastMessage['is_read'] == false;
                      }

                      return GestureDetector(
                        onTap: () {
                          // Hanya tandai terbaca jika pesan terakhir dari lawan bicara
                          if (unreadCount > 0 &&
                              lastMessage != null &&
                              lastMessage['SenderID'] != userId) {
                            _markChatRoomAsRead(chatRoom['id']);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                chatRoomId: chatRoom['id'],
                                receiverId: otherUserInfo['id'],
                                receiverName: otherUserInfo['shop_name'] ??
                                    otherUserInfo['name'],
                              ),
                            ),
                          ).then((_) {
                            if (userId != null) {
                              _fetchChatRooms(userId!);
                              _fetchUnreadCount(userId!);
                            }
                          });
                        },
                        child: Card(
                          color: unreadCount > 0
                              ? Colors.blue.shade50
                              : Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${ApiConfig.baseUrl}${otherUserInfo['profile_image']}',
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: otherUserInfo['profile_image'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              otherUserInfo['shop_name'] ??
                                  otherUserInfo['name'],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Indikator pesan belum dibaca
                                    if (isLastMessageUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),

                                    if (lastMessageTime.isNotEmpty)
                                      Text(
                                        lastMessageTime,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: isLastMessageUnread
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                if (unreadCount > 0)
                                  Text(
                                    '$unreadCount pesan belum dibaca',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: unreadCount > 0
                                ? CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 12,
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
