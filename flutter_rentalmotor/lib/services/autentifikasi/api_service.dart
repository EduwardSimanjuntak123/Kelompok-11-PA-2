import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Inisialisasi penyimpanan
final FlutterSecureStorage storage = FlutterSecureStorage();

// Fungsi untuk menyimpan token
Future<void> saveToken(String token) async {
  await storage.write(key: "auth_token", value: token);
  print("✅ Token berhasil disimpan!");
}

// Fungsi untuk menyimpan data vendor atau customer
// Fungsi untuk menyimpan data vendor atau customer
Future<void> saveVendorData(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  final storage = FlutterSecureStorage();

  final role = user['role'];
  final userId = user['id'];
  final userName = user['name']; // Simpan nama user

  // Simpan data dasar user
  await prefs.setInt('userId', userId);
  await prefs.setString('userName', userName);
  await prefs.setString('userRole', role);

  if (role == 'vendor') {
    final vendor = user['vendor'];
    if (vendor != null) {
      // Simpan data vendor ke SharedPreferences
      await prefs.setInt('vendorId', vendor['id']);
      await prefs.setString('businessName', vendor['business_name']);
      await prefs.setString('vendorAddress', vendor['address']);
      
      // Simpan juga ke Secure Storage untuk keamanan
      await storage.write(key: 'vendorId', value: vendor['id'].toString());
      await storage.write(key: 'businessName', value: vendor['business_name']);
      await storage.write(key: 'vendorAddress', value: vendor['address']);
      
      print("✅ Data vendor berhasil disimpan!");
    } else {
      print("⚠️ Data vendor kosong meskipun role vendor.");
    }
  } else if (role == 'customer') {
    print("✅ Data customer berhasil disimpan (userId: $userId)!");
  } else {
    print("⚠️ Role tidak dikenal: $role");
  }
}

// Fungsi untuk melakukan login
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
        // Simpan token
        await saveToken(data["token"]);

        // Simpan role jika ada
        if (data.containsKey("user") &&
            data["user"].containsKey("role") &&
            data["user"]["role"] != null) {
          await storage.write(key: "role", value: data["user"]["role"]);
          print("✅ Role berhasil disimpan: ${data["user"]["role"]}");
        }

        // Simpan data vendor jika ada
        if (data.containsKey("user")) {
          await saveVendorData(data["user"]);
        }
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
