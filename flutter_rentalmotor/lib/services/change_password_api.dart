import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

      final String baseUrl = ApiConfig.baseUrl;

// Fungsi untuk request reset password OTP
Future<bool> requestResetPasswordOtp(String email) async {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final String? token = await storage.read(key: "auth_token"); // Ambil token

  if (token == null) {
    print("Token tidak ditemukan");
    return false; // Jika token tidak ada, return false
  }

  final url = Uri.parse("$baseUrl/request-reset-password-otp");

  print("Requesting OTP for email: $email");

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',  // Menyertakan token dalam header
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,  // Mengirim email yang dimasukkan
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return true; // Berhasil, return true
    } else {
      print("Failed to request OTP: ${response.body}");
      return false; // Gagal, return false
    }
  } catch (e) {
    // Jika terjadi error saat request
    print('Error during OTP request: $e');
    return false;
  }
}

Future<bool> requestVerifyOtp(String email, String otp) async {
  final url = '$baseUrl/verify-otp'; // Replace with your actual API URL
  final headers = {
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'email': email,
    'otp': otp,
  });

  print("Verifying OTP for email: $email with OTP: $otp");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['status'] == 'success'; // Adjust based on your API response structure
    } else {
      print("Failed to verify OTP: ${response.body}");
      return false;
    }
  } catch (e) {
    print('Error during OTP verification: $e');
    return false;
  }
}

Future<bool> updatePassword(String oldPassword, String newPassword) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: "auth_token");

  if (token == null) {
    print("Token tidak ditemukan");
    return false;
  }

  final url = '$baseUrl/reset-password';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = jsonEncode({
    'old_password': oldPassword.trim(),
    'new_password': newPassword.trim(),
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    //anggap semua 200 OK sebagai sukses:
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error updating password: $e');
    return false;
  }
}

