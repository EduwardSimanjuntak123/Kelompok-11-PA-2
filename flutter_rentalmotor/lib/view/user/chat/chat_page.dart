import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
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
  WebSocketChannel? _channel;
  int _currentUser_Id = 0;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _getCurrentUser();
    await _loadMessages();
    _connectWebSocket();
    // Tandai semua pesan sebagai dibaca saat membuka chat
    _markAllMessagesAsRead();
  }

  Future<void> _getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser_Id = prefs.getInt('user_id') ?? 0;
    });
    if (_currentUser_Id == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID tidak ditemukan')));
    }
  }

  // Fungsi baru untuk menandai semua pesan sebagai dibaca
  Future<void> _markAllMessagesAsRead() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/chat/mark-all-read');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_room_id': widget.chatRoomId,
          'user_id': _currentUser_Id,
        }),
      );

      if (response.statusCode != 200) {
        print(
          'Gagal menandai semua pesan sebagai dibaca: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error marking all messages as read: $e');
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
          '${ApiConfig.baseUrl}/chat/messages?chat_room_id=${widget.chatRoomId}&user_id=$_currentUser_Id',
        ),
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

        _scrollToBottom();
      } else {
        throw Exception('Gagal mengambil pesan dari server');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading messages: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading messages: $e')));
    }
  }

  void _connectWebSocket() {
    try {
      // Sesuaikan dengan format endpoint WebSocket di backend Go
      final wsUrl =
          '${ApiConfig.wsUrl}/ws/chat?sender_id=$_currentUser_Id&chat_room_id=${widget.chatRoomId}';
      print('Connecting to WebSocket: $wsUrl');

      _channel = IOWebSocketChannel.connect(Uri.parse(wsUrl));

      setState(() {
        _isConnected = true;
      });

      _channel!.stream.listen(
        (dynamic data) {
          print('WebSocket received: $data');
          try {
            final Map<String, dynamic> messageData = jsonDecode(data);
            final newMessage = Message.fromJson(messageData);

            setState(() {
              // Cek apakah pesan sudah ada di list (untuk menghindari duplikasi)
              bool isDuplicate = false;
              for (var msg in _messages) {
                // Jika ID sama dan bukan 0 (pesan sementara), maka duplikat
                if (msg.id == newMessage.id && newMessage.id != 0) {
                  isDuplicate = true;
                  break;
                }

                // Jika konten dan waktu kirim hampir sama, mungkin duplikat
                if (msg.content == newMessage.content &&
                    msg.senderId == newMessage.senderId &&
                    msg.id == 0 && // Hanya cek untuk pesan sementara (id=0)
                    newMessage.sentAt.difference(msg.sentAt).inSeconds.abs() <
                        5) {
                  // Ganti pesan sementara dengan pesan dari server
                  _messages[_messages.indexOf(msg)] = newMessage;
                  isDuplicate = true;
                  break;
                }
              }

              // Jika bukan duplikat, tambahkan ke daftar pesan
              if (!isDuplicate) {
                _messages.add(newMessage);
              }
            });

            // Tandai pesan yang diterima sebagai sudah dibaca jika bukan dari pengguna saat ini
            if (newMessage.senderId != _currentUser_Id) {
              _showIncomingMessageNotification(widget.receiverName);
            }
            _scrollToBottom();
          } catch (e) {
            print('Error parsing WebSocket message: $e');
            print('Raw message: $data');
          }
        },
        onError: (error) {
          print('WebSocket Error: $error');
          setState(() {
            _isConnected = false;
          });
          // Coba reconnect setelah error
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              _connectWebSocket();
            }
          });
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            _isConnected = false;
          });
          // Coba reconnect ketika koneksi tertutup
          if (mounted) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && !_isConnected) {
                _connectWebSocket();
              }
            });
          }
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
      // Coba reconnect setelah error
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _connectWebSocket();
        }
      });
    }
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
    _messageController.clear();

    // Tampilkan pesan di UI terlebih dahulu (optimistic UI)
    final tempMessage = Message(
      id: 0, // ID sementara, akan diupdate setelah respons dari server
      chatRoomId: widget.chatRoomId,
      senderId: _currentUser_Id,
      content: messageText,
      sentAt: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      // Kirim pesan melalui HTTP API
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_room_id': widget.chatRoomId,
          'sender_id': _currentUser_Id,
          'message': messageText, // Perhatikan nama field sesuai dengan backend
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Gagal mengirim pesan ke server: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
    }
  }

  // Fungsi untuk mencari pesan
  Future<void> _searchMessages(String keyword) async {
    if (keyword.isEmpty) {
      _loadMessages(); // Jika keyword kosong, tampilkan semua pesan
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/chat/search?user_id=$_currentUser_Id&keyword=$keyword',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Message> searchResults = (data['messages'] as List)
            .where(
              (msg) => msg['chat_room_id'] == widget.chatRoomId,
            ) // Filter hanya pesan di chat room ini
            .map((msg) => Message.fromJson(msg))
            .toList();

        setState(() {
          _messages = searchResults;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mencari pesan: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error searching messages: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching messages: $e')));
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      _channel!.sink.close();
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 8),
            Text(
              widget.receiverName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C567E),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Tambahkan tombol pencarian
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String searchKeyword = '';
                  return AlertDialog(
                    title: const Text('Cari Pesan'),
                    content: TextField(
                      onChanged: (value) {
                        searchKeyword = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Masukkan kata kunci...',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _loadMessages(); // Reset pencarian
                        },
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _searchMessages(searchKeyword);
                        },
                        child: const Text('Cari'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
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
                                DateFormat(
                                  'hh:mm a',
                                ).format(message.sentAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              if (isMe)
                                Text(
                                  message.isRead ? "Dibaca" : "Terkirim",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
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
      id: json['ID'] ?? json['id'] ?? 0,
      chatRoomId: json['ChatRoomID'] ?? json['chat_room_id'] ?? 0,
      senderId: json['SenderID'] ?? json['sender_id'] ?? 0,
      content: json['Message'] ?? json['message'] ?? '',
      sentAt: DateTime.parse(json['sent_at'] ?? DateTime.now().toString()),
      isRead: json['is_read'] ?? false,
    );
  }
}
