import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/view/vendor/chat_page.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({super.key});

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
          _connectToNotificationWebSocket(userId);
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
        backgroundColor: const Color(0xFF1A567D),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text(
              "Pesan Masuk",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_totalUnreadMessages > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_totalUnreadMessages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality could be added here
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
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
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.teal[600],
              ),
            )
          : chatRooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.teal[200],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada percakapan",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.teal[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          "Tunggu sampai ada customer memulai chat dengan anda",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.teal[600],
                  onRefresh: () async {
                    if (userId != null) {
                      await _fetchChatRooms(userId!);
                      await _fetchUnreadCount(userId!);
                    }
                  },
                  child: ListView.separated(
                    itemCount: chatRooms.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.grey[200],
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final room = chatRooms[index];
                      final chatRoom = room['chat_room'];
                      final unreadCount = room['unread_count'] ?? 0;
                      final otherUserInfo = room['other_user_info'];

                      // Pastikan data tidak null
                      if (chatRoom == null || otherUserInfo == null) {
                        return const SizedBox.shrink();
                      }

                      final lastMessage = chatRoom['last_message'] ?? "";
                      final lastMessageSenderId =
                          chatRoom['last_message_sender_id'];
                      final bool isLastMessageFromCurrentUser =
                          lastMessageSenderId == userId;

                      final profileImage = otherUserInfo['profile_image'];
                      final imageUrl = (profileImage is List)
                          ? "${ApiConfig.baseUrl}${profileImage.isNotEmpty ? profileImage[0] : ''}"
                          : "${ApiConfig.baseUrl}$profileImage";

                      // Format waktu pesan terakhir
                      String lastMessageTime = "";
                      bool isLastMessageUnread =
                          !chatRoom['last_message_is_read'];

                      if (chatRoom['last_sent_at'] != null) {
                        try {
                          final DateTime sentAt =
                              DateTime.parse(chatRoom['last_sent_at']);
                          final now = DateTime.now();
                          final difference = now.difference(sentAt);

                          if (difference.inDays > 0) {
                            if (difference.inDays == 1) {
                              lastMessageTime = 'Kemarin';
                            } else if (difference.inDays < 7) {
                              lastMessageTime = '${difference.inDays}h';
                            } else {
                              // Format as date for older messages
                              lastMessageTime = '${sentAt.day}/${sentAt.month}';
                            }
                          } else if (difference.inHours > 0) {
                            lastMessageTime = '${difference.inHours}j';
                          } else if (difference.inMinutes > 0) {
                            lastMessageTime = '${difference.inMinutes}m';
                          } else {
                            lastMessageTime = 'Baru saja';
                          }
                        } catch (e) {
                          lastMessageTime = '';
                        }
                      }

                      // Display shop name for vendors
                      final displayName =
                          otherUserInfo['name'] ?? otherUserInfo['name'];

                      return InkWell(
                        onTap: () {
                          // Hanya tandai terbaca jika pesan terakhir dari lawan bicara
                          // dan bukan dari user saat ini
                          if (unreadCount > 0 &&
                              !isLastMessageFromCurrentUser) {
                            _markChatRoomAsRead(chatRoom['id']);
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                chatRoomId: chatRoom['id'],
                                receiverId: otherUserInfo['id'],
                                receiverName: otherUserInfo['name'] ??
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
                        child: Container(
                          color: isLastMessageUnread &&
                                  !isLastMessageFromCurrentUser
                              ? Colors.teal.withOpacity(0.08)
                              : null,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              // Profile Image with vendor indicator
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: NetworkImage(imageUrl),
                                  ),
                                  if (otherUserInfo['role'] == 'vendor')
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.teal, width: 1.5),
                                        ),
                                        child: Icon(
                                          Icons.store,
                                          size: 12,
                                          color: Colors.teal[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Chat details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Name
                                        Expanded(
                                          child: Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isLastMessageUnread &&
                                                      !isLastMessageFromCurrentUser
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Time
                                        Text(
                                          lastMessageTime,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isLastMessageUnread &&
                                                    !isLastMessageFromCurrentUser
                                                ? Colors.teal[600]
                                                : Colors.grey[600],
                                            fontWeight: isLastMessageUnread &&
                                                    !isLastMessageFromCurrentUser
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // Last message and unread count
                                    Row(
                                      children: [
                                        // Message status indicator
                                        if (isLastMessageFromCurrentUser)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Icon(
                                              chatRoom['last_message_is_read']
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: 16,
                                              color: chatRoom[
                                                      'last_message_is_read']
                                                  ? Colors.blue[400]
                                                  : Colors.grey[400],
                                            ),
                                          ),

                                        // Prefix for messages sent by current user
                                        if (isLastMessageFromCurrentUser)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 4),
                                            child: Text(
                                              "Anda: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),

                                        Expanded(
                                          child: Text(
                                            lastMessage,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isLastMessageUnread &&
                                                      !isLastMessageFromCurrentUser
                                                  ? Colors.black87
                                                  : Colors.grey[600],
                                              fontWeight: isLastMessageUnread &&
                                                      !isLastMessageFromCurrentUser
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        if (unreadCount > 0 &&
                                            !isLastMessageFromCurrentUser)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.teal[600],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              unreadCount.toString(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                      );
                    },
                  ),
                ),
    );
  }
}
