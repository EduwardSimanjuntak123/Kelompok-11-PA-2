import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final int chatRoomId;
  final int senderId;
  final int receiverId;
  final String receiverName;

  const ChatPage({
    Key? key,
    required this.chatRoomId,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;
  late WebSocketChannel _channel;
  late int _currentUser_Id;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadMessages();
    _connectWebSocket();
  }

  Future<void> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser_Id = prefs.getInt('user_id') ?? 0;
    });
  }

  Future<void> _loadMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/chat/messages?chat_room_id=${widget.chatRoomId}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data received: $data');

        setState(() {
          _messages = (data['messages'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  void _connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
          '${ApiConfig.wsUrl}/ws/chat?chat_room_id=${widget.chatRoomId}&sender_id=${widget.senderId}'),
    );

    _channel.stream.listen((message) {
      final newMessage = Message.fromJson(jsonDecode(message));
      setState(() {
        _messages.add(newMessage);
      });
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('WebSocket error: $error')),
      );
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text;
    final newMessage = Message(
      id: 0, // ID bisa diatur sesuai kebutuhan, misalnya dari server
      chatRoomId: widget.chatRoomId,
      senderId: _currentUser_Id,
      content: message,
      sentAt: DateTime.now(), // Atur waktu pengiriman
    );

    // Tambahkan pesan ke daftar sebelum mengirim
    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_room_id': widget.chatRoomId,
          'sender_id': widget.senderId,
          'content': message,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Color(0xFF2C567E),
      ),
      body: Column(
        children: [
          // Menampilkan nama penerima di atas chat
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.receiverName, // Menggunakan nama penerima
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == _currentUser_Id;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                DateFormat('hh:mm a').format(message.sentAt),
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
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
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
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

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['ID'] ?? 0, // Menggunakan 0 jika null
      chatRoomId: json['ChatRoomID'] ?? 0, // Menggunakan 0 jika null
      senderId: json['SenderID'] ?? 0, // Menggunakan 0 jika null
      content: json['Message'] ?? '', // Menggunakan string kosong jika null
      sentAt: DateTime.parse(json['sent_at'] ??
          DateTime.now().toString()), // Menggunakan waktu sekarang jika null
    );
  }
}
