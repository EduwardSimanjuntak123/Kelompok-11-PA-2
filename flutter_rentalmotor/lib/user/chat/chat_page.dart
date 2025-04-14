import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final int chatRoomId;
  final int receiverId;
  final String receiverName;

  const ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  late WebSocketChannel _channel;
  int _currentUser_Id = 0;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _getCurrentUser();
    await _loadMessages();
    _connectWebSocket();
  }

  Future<void> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser_Id = prefs.getInt('user_id') ?? 0;
  }

  Future<void> _markMessageAsRead(int messageId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/messages/$messageId/read');
    try {
      final response = await http.put(url, headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode != 200) {
        throw Exception('Gagal menandai pesan sebagai dibaca');
      }
    } catch (e) {
      print('Error mark as read: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/chat/messages?chat_room_id=${widget.chatRoomId}&user_id=$_currentUser_Id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Message> loadedMessages = (data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();

        setState(() {
          _messages = loadedMessages;
          _isLoading = false;
        });

        // Tandai pesan yang belum dibaca dan bukan dikirim oleh user saat ini
        for (var msg in loadedMessages) {
          if (msg.senderId != _currentUser_Id && !msg.isRead) {
            _markMessageAsRead(msg.id);
          }
        }
        _scrollToBottom();
      } else {
        throw Exception('Gagal mengambil pesan dari server');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading messages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  void _connectWebSocket() {
    // Gunakan _currentUser_Id sebagai sender_id untuk WebSocket
    _channel = WebSocketChannel.connect(
      Uri.parse(
          '${ApiConfig.wsUrl}/ws/chat?chat_room_id=${widget.chatRoomId}&sender_id=$_currentUser_Id'),
    );

    _channel.stream.listen((data) {
      final newMessage = Message.fromJson(jsonDecode(data));
      setState(() {
        _messages.add(newMessage);
      });

      if (newMessage.senderId != _currentUser_Id) {
        _markMessageAsRead(newMessage.id);
        _showIncomingMessageNotification(widget.receiverName);
      }
      _scrollToBottom();
    }, onError: (error) {
      print('WebSocket Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WebSocket Error: $error')),
      );
    });
  }

  void _showIncomingMessageNotification(String senderName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pesan baru dari $senderName'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final newMessage = Message(
      id: 0,
      chatRoomId: widget.chatRoomId,
      senderId: _currentUser_Id,
      content: messageText,
      sentAt: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_room_id': widget.chatRoomId,
          // Kirim _currentUser_Id sebagai sender_id agar dapat berupa vendor atau customer
          'sender_id': _currentUser_Id,
          'content': messageText,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengirim pesan ke server');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim pesan: $e')),
      );
    }
  }

  Future<bool> _confirmExitChat() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Chat?'),
        content: const Text('Pesan baru tidak akan diterima jika Anda keluar.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExitChat,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: const Color(0xFF2C567E),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.receiverName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isMe = message.senderId == _currentUser_Id;
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFFD1E9FF)
                                  : const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.content,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  DateFormat('hh:mm a').format(message.sentAt),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                if (isMe)
                                  Text(
                                    message.isRead ? "Dibaca" : "Terkirim",
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['ID'] ?? 0,
      chatRoomId: json['ChatRoomID'] ?? 0,
      senderId: json['SenderID'] ?? 0,
      content: json['Message'] ?? '',
      sentAt: DateTime.parse(json['sent_at'] ?? DateTime.now().toString()),
      isRead: json['is_read'] ?? false,
    );
  }
}
