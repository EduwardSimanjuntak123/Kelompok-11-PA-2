import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/chat/chat_page.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({Key? key}) : super(key: key);

  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  List<dynamic> chatRooms = [];
  int? userId;
  

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
      _fetchChatRooms(id);
    } else {
      print('⚠️ Tidak ditemukan user_id di SharedPreferences');
    }
  }

  Future<void> _fetchChatRooms(int userId) async {
    final url =
        Uri.parse("http://192.168.168.159:8080/chat/rooms?user_id=$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        chatRooms =
            data['chat_rooms']; // Sesuaikan dengan struktur respons backend
      });
    } else {
      print(
          '❌ Gagal mengambil chat rooms dengan status: ${response.statusCode}');
    }
  }

  // Fungsi untuk mengambil pesan terakhir dari list pesan
  String _getLastMessage(dynamic room) {
    if (room['messages'] != null && room['messages'].isNotEmpty) {
      // Pastikan key pesan sesuai dengan yang dikirimkan backend,
      // misalnya "message" (huruf kecil) atau "Message"
      return room['messages'].last['message'] ?? "Tidak ada pesan";
    }
    return "Belum ada pesan";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesan Masuk")),
      body: chatRooms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final room = chatRooms[index];
                final vendor = room['vendor'];
                final customer = room['customer'];
                final isUserVendor = userId == vendor['id'];
                final otherUser = isUserVendor ? customer : vendor;

                // Hitung jumlah pesan belum dibaca
                final unreadCount = room['messages']
                        ?.where((msg) =>
                            msg['sender_id'] != userId &&
                            msg['is_read'] == false)
                        .length ??
                    0;

                // Ambil pesan terakhir untuk ditampilkan
                final lastMessage = _getLastMessage(room);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          chatRoomId: room['id'],
                          receiverId: otherUser['id'],
                          receiverName:
                              otherUser['shop_name'] ?? otherUser['name'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                      color:
                          unreadCount > 0 ? Colors.blue.shade50 : Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'http://192.168.168.159:8080${otherUser['profile_image']}'),
                        ),
                        title:
                            Text(otherUser['shop_name'] ?? otherUser['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (unreadCount > 0)
                              Text(
                                '$unreadCount pesan belum dibaca',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red),
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
                                      fontSize: 12, color: Colors.white),
                                ),
                              )
                            : null,
                      )),
                );
              },
            ),
    );
  }
}
