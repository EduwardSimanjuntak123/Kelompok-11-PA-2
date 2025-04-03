import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class HomePageApi {
  final String baseUrl = ApiConfig.baseUrl;

  // Mengambil daftar vendor dari API
  Future<List<Map<String, dynamic>>> fetchVendors() async {
    final response = await http.get(Uri.parse("$baseUrl/vendor"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
          data['data']); // Sesuaikan dengan struktur JSON API
    } else {
      throw Exception("Gagal mengambil data vendor");
    }
  }

  // Mengambil daftar motor dari API
  Future<List<Map<String, dynamic>>> fetchMotors() async {
    try {
      print("🔄 Memanggil API untuk data motor...");
      final response = await http
          .get(Uri.parse('$baseUrl/motor/'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey("data") && jsonResponse["data"] is List) {
          List<dynamic> data = jsonResponse["data"];

          // Konversi dan pemetaan data motor
          List<Map<String, dynamic>> motors = data.map((motor) {
            return {
              "id": motor["id"],
              "name": motor["name"],
              "brand": motor["brand"],
              "model": motor["model"],
              "year": motor["year"].toString(),
              "price": motor["price"].toString(),
              "color": motor["color"],
              "rating": motor["rating"],
              "status": motor["status"],
              "type": motor["type"], // Tambahkan tipe motor
              "description": motor["description"], // Tambahkan deskripsi
              "image": "$baseUrl${motor["image"]}",
            };
          }).toList();

          print("✅ Data motor berhasil diambil.");
          return motors;
        } else {
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        throw Exception("Gagal mengambil data motor");
      }
    } catch (e) {
      throw Exception("Terjadi kesalahan saat mengambil data motor: $e");
    }
  }
}
