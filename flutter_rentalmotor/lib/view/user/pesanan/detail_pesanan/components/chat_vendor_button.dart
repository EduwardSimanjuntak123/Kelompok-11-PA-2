import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/customer/chat_services.dart';
import 'package:flutter_rentalmotor/view/user/chat/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatVendorButton extends StatelessWidget {
  final int vendorId;
  final Map<String, dynamic>? vendorData;

  const ChatVendorButton({
    super.key,
    required this.vendorId,
    required this.vendorData,
  });
Future<void> _startChat(BuildContext context) async {
  try {
    print("Vendor ID: $vendorId");
    print("Vendor Data: $vendorData");

    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt('user_id'); // pelanggan yang login

    print("Customer ID: $customerId");

    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan masuk untuk mulai chat')),
      );
      return;
    }

    final chatRoom = await ChatService.getOrCreateChatRoom(
      customerId: customerId,
      vendorId: vendorId,
    );

    if (chatRoom != null) {
      final receiverId = vendorData?['user_id'] ?? vendorId;
      print("Receiver ID: $receiverId");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatRoomId: chatRoom['id'],
            receiverId: receiverId,
            receiverName: vendorData?['shop_name'] ?? 'Nama Vendor',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memulai chat')),
      );
    }
  } catch (e) {
    print("Error starting chat: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E8EDE), Color(0xFF2C567E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2C567E).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startChat(context),
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Chat Vendor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
