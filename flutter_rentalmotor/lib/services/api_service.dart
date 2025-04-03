import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final String baseUrl = ApiConfig.baseUrl;
  final url = Uri.parse('$baseUrl/login'); // Pastikan URL benar

  try {
    print("Mengirim request login ke: $url");
    print("Data yang dikirim: Email: $email, Password: $password");

    // Kirim request POST ke server
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(Duration(seconds: 30)); // Set timeout menjadi 30 detik

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    // Periksa status code dan respon dari server
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Cek apakah data valid dan sesuai role
      if (data.containsKey("user") && data["user"]["role"] == "customer") {
        // Misalnya, Anda bisa menyimpan token atau informasi lain
        // Anda bisa menggunakan shared_preferences untuk menyimpan token
        return data; // Kembalikan data login jika sukses
      } else {
        return {
          "error": "Hanya customer yang diizinkan login."
        }; // Role selain customer
      }
    } else {
      return {
        "error": "Gagal login. Periksa email dan password."
      }; // Status code bukan 200
    }
  } on TimeoutException catch (e) {
    print("Timeout saat login: $e");
    return {"error": "Waktu koneksi habis. Coba lagi nanti."}; // Timeout
  } catch (e) {
    print("Error saat login: $e");
    return {
      "error": "Tidak dapat terhubung ke server. Coba lagi nanti."
    }; // Kesalahan lainnya
  }
}
