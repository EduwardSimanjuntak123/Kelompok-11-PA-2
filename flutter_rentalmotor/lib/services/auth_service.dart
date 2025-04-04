import 'dart:convert';
import 'dart:io';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  /// **📌 Register Customer**
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String birthDate,
    File? profileImage,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/customer/register');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['address'] = address;
      request.fields['birth_date'] = birthDate;

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Simpan data user ke SharedPreferences jika respons mengandung key "data"
        if (responseData["data"] != null) {
          await _saveUserData(responseData["data"]);
        }
        return {
          "success": true,
          "message": "Registration successful",
          "data": responseData
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          "success": false,
          "message": responseBody["error"] ?? "Registration failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// **📌 Verify OTP**
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/verify-otp');
      var response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Simpan data user ke SharedPreferences jika respons mengandung key "data"
        if (responseData["data"] != null) {
          await _saveUserData(responseData["data"]);
        }
        return {
          "success": true,
          "message": "OTP verification successful",
          "data": responseData
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          "success": false,
          "message": responseBody["error"] ?? "OTP verification failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// **📌 Simpan Data User ke SharedPreferences**
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', userData["name"]);
    await prefs.setString('user_email', userData["email"]);
    await prefs.setInt('user_id', userData["id"]);
    await prefs.setString('user_role', userData["role"]);
    await prefs.setString('user_phone', userData["phone"]);
    await prefs.setString('user_address', userData["address"]);
  }

  /// **📌 Ambil Data User dari SharedPreferences**
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString('user_name'),
      "email": prefs.getString('user_email'),
      "id": prefs.getInt('user_id'),
      "role": prefs.getString('user_role'),
      "phone": prefs.getString('user_phone'),
      "address": prefs.getString('user_address'),
    };
  }
}
