import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Selamat pagi pak saya mau konfirmasi pesanan saya untuk hari rabu tanggal 23 juni, available kan pak?",
      isSender: true,
    ),
    ChatMessage(
      text: "Hai Mas, untuk pesanan diatas tersedia mas.",
      isSender: false,
    ),
    ChatMessage(
      text: "Saya konfirmasi sekarang ya mas.",
      isSender: false,
    ),
    ChatMessage(
      text: "Oke, terimakasih Pak",
      isSender: true,
    ),
  ];
  bool _showConfirmation = true;
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isSender: true,
        ),
      );
      _messageController.clear();
      _showConfirmation = false;
    });

    // Show sending indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate response delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _showConfirmation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gaol Rental"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C567E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Status online
          Container(
            padding: const EdgeInsets.all(5),
            child: const Text(
              "● online",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length + (_showConfirmation ? 1 : 0) + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessage(
                    _messages[index].text,
                    _messages[index].isSender,
                  );
                } else if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                } else if (_showConfirmation) {
                  return _buildConfirmation();
                }
                return null;
              },
            ),
          ),

          // Input chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Tulis pesan..",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isSender ? Colors.green : Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isSender ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isSender ? const Radius.circular(0) : const Radius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 100),
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 5,
              height: 5,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 5),
            Text(
              "Mengetik...",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmation() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
        color: Colors.green.withOpacity(0.1),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Pesanan Sudah Dikonfirmasi",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 5),
          Icon(Icons.check_circle, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isSender;

  ChatMessage({
    required this.text,
    required this.isSender,
  });
}