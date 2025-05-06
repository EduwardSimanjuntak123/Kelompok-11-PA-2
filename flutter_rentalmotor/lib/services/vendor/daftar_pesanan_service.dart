import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class DaftarPesananService {
  final storage = FlutterSecureStorage();

  Future<List<dynamic>> fetchBookings() async {
    try {
      String? token = await storage.read(key: "auth_token");
      print("TOKEN: $token");

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customer/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> bookings = json.decode(response.body);
        // Sort bookings by created_at date in descending order (newest first)
        bookings.sort((a, b) {
          DateTime dateA =
              DateTime.parse(a['created_at'] ?? DateTime.now().toString());
          DateTime dateB =
              DateTime.parse(b['created_at'] ?? DateTime.now().toString());
          return dateB.compareTo(dateA); // Descending order (newest first)
        });
        return bookings;
      } else {
        throw Exception('Gagal memuat data pesanan');
      }
    } catch (e) {
      print(e);
      return [];
    }
  }
}
