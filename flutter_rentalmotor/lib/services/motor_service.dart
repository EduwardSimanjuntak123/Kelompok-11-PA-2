import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class MotorService {
  final String baseUrl = ApiConfig.baseUrl;

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
              "year": motor["year"].toString(), // Pastikan String
              "price": motor["price"].toString(), // Pastikan String
              "color": motor["color"],
              "rating": motor["rating"],
              "status": motor["status"],
              "image": "$baseUrl${motor["image"]}", // Tambahkan URL dasar
              "vendor": {
                "id": motor["vendor"]["id"],
                "shop_name": motor["vendor"]["shop_name"],
                "shop_address": motor["vendor"]["shop_address"],
                "rating":
                    motor["vendor"]["rating"].toString() // Pastikan String
              }
            };
          }).toList();

          print("✅ Data motor berhasil diambil.");
          return motors;
        } else {
          print("❌ Format respons API tidak sesuai");
          throw Exception("Format respons API tidak sesuai");
        }
      } else {
        print("❌ Gagal mengambil data. Kode status: ${response.statusCode}");
        throw Exception("Gagal mengambil data motor");
      }
    } on TimeoutException {
      print("⏳ Permintaan API timeout! Periksa koneksi internet.");
      throw Exception("Timeout: Tidak dapat mengambil data motor");
    } catch (e) {
      print("⚠️ Error saat mengambil data motor: $e");
      throw Exception("Terjadi kesalahan saat mengambil data motor");
    }
  }
}
