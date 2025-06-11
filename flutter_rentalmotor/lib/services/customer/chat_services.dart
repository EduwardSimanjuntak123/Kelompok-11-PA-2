import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ChatService {
  static Future<Map<String, dynamic>?> getOrCreateChatRoom({
    required int customerId,
    required int vendorId,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/chat/room');

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "customer_id": customerId,
        "vendor_id": vendorId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['chat_room'];
    } else {
      print(
          'Gagal membuat/ambil chat room: ${response.statusCode} ${response.body}');
      return null;
    }
  }
}
