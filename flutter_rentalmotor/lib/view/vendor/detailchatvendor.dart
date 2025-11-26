import 'package:flutter/material.dart';

class ChatPagev extends StatefulWidget {
  const ChatPagev({super.key});

  @override
  State<ChatPagev> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPagev> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C567E),
        title: Column(
          children: [
            const Text(
              "Boas Rayhan Turnip",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              "● online",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length + (_showConfirmation ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessage(
                    _messages[index].text,
                    _messages[index].isSender,
                  );
                } else if (_showConfirmation) {
                  return _buildConfirmation();
                }
                return null;
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isSender) {
    return Row(
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) _buildProfilePicture(isSender), 
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
        if (isSender) _buildProfilePicture(isSender), 
      ],
    );
  }

  Widget _buildProfilePicture(bool isSender) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(
          isSender ? "assets/images/c1.png" : "assets/images/c2.png", 
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: "Tulis pesan...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                setState(() {
                  _messages.add(ChatMessage(
                    text: _messageController.text,
                    isSender: true,
                  ));
                  _messageController.clear();
                  _showConfirmation = false;
                });
              }
            },
          ),
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
