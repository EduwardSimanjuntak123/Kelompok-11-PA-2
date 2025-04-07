import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage storage =
    FlutterSecureStorage(); // Inisialisasi penyimpanan

Future<void> saveToken(String token) async {
  await storage.write(key: "auth_token", value: token);
  print("✅ Token berhasil disimpan!");
}

Future<Map<String, dynamic>> loginUser(String email, String password) async {
  final String baseUrl = ApiConfig.baseUrl;
  final url = Uri.parse('$baseUrl/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data.containsKey("token")) {
        await saveToken(data["token"]); // Simpan token
      }

      return data; // Kembalikan data user
    } else {
      return {"error": "Gagal login. Periksa email dan password."};
    }
  } catch (e) {
    print("Error saat login: $e");
    return {"error": "Tidak dapat terhubung ke server. Coba lagi nanti."};
  }
}
