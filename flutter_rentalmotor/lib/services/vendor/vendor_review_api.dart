import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
    final String baseUrl = ApiConfig.baseUrl;


class VendorReviewApi {

  static final storage = FlutterSecureStorage();

  static Future<List<dynamic>> fetchReviews() async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      
      Uri.parse('$baseUrl/vendor/reviews'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat ulasan: ${response.statusCode}');
    }
  }

  static Future<bool> replyToReview(String reviewId, String replyText) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.post(
      Uri.parse('$baseUrl/vendor/review/$reviewId/reply'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'reply': replyText}),
    );

    if (response.statusCode == 200) {
      print('Balasan berhasil diperbarui');
      return true;
    } else {
      print('Gagal memperbarui balasan, status code: ${response.statusCode}');
      return false;
    }
  }
}
