import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

final String baseUrl = ApiConfig.baseUrl;

/// Fungsi untuk meminta OTP reset password
Future<bool> requestResetPasswordOtp(String email) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: "auth_token");

  if (token == null) {
    print("Token tidak ditemukan");
    return false;
  }

  final url = Uri.parse("$baseUrl/request-reset-password-otp");

  print("Requesting OTP for email: $email");

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("Error during OTP request: $e");
    return false;
  }
}

/// Fungsi untuk memverifikasi OTP
Future<bool> requestVerifyOtp(String email, String otp) async {
  final url = Uri.parse("$baseUrl/verify-otp");

  print("Verifying OTP for email: $email with OTP: $otp");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['status'] == 'success';
    } else {
      return false;
    }
  } catch (e) {
    print("Error during OTP verification: $e");
    return false;
  }
}

/// Fungsi untuk mengganti password
Future<bool> updatePassword(String oldPassword, String newPassword) async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: "auth_token");

  if (token == null) {
    print("Token tidak ditemukan");
    return false;
  }

  final url = Uri.parse("$baseUrl/reset-password");

  print("Sending request to update password");

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    return response.statusCode == 200;
  } catch (e) {
    print("Error during password update: $e");
    return false;
  }
}
