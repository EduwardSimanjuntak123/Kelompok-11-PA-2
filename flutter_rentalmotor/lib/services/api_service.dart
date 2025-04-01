import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final String baseUrl = ApiConfig.baseUrl;
  final url =
      Uri.parse('$baseUrl/login'); // Pastikan URL benar

  try {
    print("Mengirim request login ke: $url");
    print("Data yang dikirim: Email: $email, Password: $password");

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(Duration(seconds: 10));

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey("user") && data["user"]["role"] == "customer") {
        return data;
      } else {
        return {"error": "Hanya customer yang diizinkan login."};
      }
    } else {
      return {"error": "Gagal login. Periksa email dan password."};
    }
  } on TimeoutException catch (e) {
    print("Timeout saat login: $e");
    return {"error": "Waktu koneksi habis. Coba lagi nanti."};
  } catch (e) {
    print("Error saat login: $e");
    return {"error": "Tidak dapat terhubung ke server. Coba lagi nanti."};
  }
}
