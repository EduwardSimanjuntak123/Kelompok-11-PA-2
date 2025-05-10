import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/view/user/chat/chat_page.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  List<dynamic> chatRooms = [];
  int? userId;
  bool _isConnected = false;
  bool _isLoading = true;
  int _totalUnreadMessages = 0;
  final Color _themeColor = const Color(0xFF225378);

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
    } else {
      print('⚠ Tidak ditemukan user_id di SharedPreferences');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchChatRooms(int userId) async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/rooms?user_id=$userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(
          ' data chat room: ${response.body}',
        );
        if (mounted) {
          setState(() {
            chatRooms = data['chat_rooms'];
            _isLoading = false;
          });
        }
      } else {
        print(
          '❌ Gagal mengambil chat rooms dengan status: ${response.body}',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Row(
          children: [
            Text(
              "Pesan Masuk",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                    color: _themeColor,
                    fontWeight: FontWeight.bold,
                  ),
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
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
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
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: _themeColor,
                ),
              )
            : chatRooms.isEmpty
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
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: _themeColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada percakapan",
                          style: TextStyle(
                            fontSize: 20,
                            color: _themeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            "Mulai chat dengan vendor untuk menyewa motor",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: _themeColor,
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
                                lastMessageTime =
                                    '${sentAt.day}/${sentAt.month}';
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
                            otherUserInfo['shop_name'] ?? otherUserInfo['name'];

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
                          child: Container(
                            color: isLastMessageUnread &&
                                    !isLastMessageFromCurrentUser
                                ? _themeColor.withOpacity(0.08)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            child: Row(
                              children: [
                                // Profile Image with vendor indicator
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _themeColor.withOpacity(0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _themeColor.withOpacity(0.1),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: NetworkImage(imageUrl),
                                      ),
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
                                                color: _themeColor, width: 1.5),
                                          ),
                                          child: Icon(
                                            Icons.store,
                                            size: 12,
                                            color: _themeColor,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Chat details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                color: isLastMessageUnread &&
                                                        !isLastMessageFromCurrentUser
                                                    ? _themeColor
                                                    : Colors.black87,
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
                                                  ? _themeColor
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
                                              padding: const EdgeInsets.only(
                                                  right: 4),
                                              child: Icon(
                                                chatRoom['last_message_is_read']
                                                    ? Icons.done_all
                                                    : Icons.done,
                                                size: 16,
                                                color: chatRoom[
                                                        'last_message_is_read']
                                                    ? _themeColor
                                                    : Colors.grey[400],
                                              ),
                                            ),

                                          // Prefix for messages sent by current user
                                          if (isLastMessageFromCurrentUser)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4),
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
                                              margin: const EdgeInsets.only(
                                                  left: 8),
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: _themeColor,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: _themeColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ],
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
      ),
    );
  }
}
