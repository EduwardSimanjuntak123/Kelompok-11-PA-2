import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/customer/chat_services.dart';
import 'package:flutter_rentalmotor/view/user/chat/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatVendorButton extends StatelessWidget {
  final int vendorId;
  final Map<String, dynamic>? vendorData;

  const ChatVendorButton({
    Key? key,
    required this.vendorId,
    required this.vendorData,
  }) : super(key: key);

  Future<void> _startChat(BuildContext context) async {
    try {
      // Debug output untuk vendorId dan vendorData
      print("Vendor ID: $vendorId");
      print("Vendor Data: $vendorData");

      final chatRoom =
          await ChatService.getOrCreateChatRoom(vendorId: vendorId);

      if (chatRoom != null) {
        final prefs = await SharedPreferences.getInstance();
        final customerId = prefs.getInt('user_id');

        // Debug output untuk customerId
        print("Customer ID: $customerId");

        if (customerId != null) {
          final receiverId = vendorData?['user_id'] ??
              0; // Menggunakan vendorData untuk receiverId

          // Debug output untuk receiverId
          print("Receiver ID: $receiverId");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                chatRoomId: chatRoom['id'],
                receiverId: receiverId,
                receiverName: vendorData?['shop_name'] ?? 'Nama Penerima',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Silakan masuk untuk mulai chat')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai chat')),
        );
      }
    } catch (e) {
      // Debug output untuk error
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
