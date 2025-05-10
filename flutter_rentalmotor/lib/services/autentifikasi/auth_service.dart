// auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = ApiConfig.baseUrl;

  /// **📌 Register Vendor**
  Future<Map<String, dynamic>> registerVendor({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String shopName,
    required String shopAddress,
    required String shopDescription,
    required int kecamatanId,
    required String birthDate,
    File? profileImage,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/vendor/register');
      var request = http.MultipartRequest('POST', uri);

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['shop_name'] = shopName;
      request.fields['shop_address'] = shopAddress;
      request.fields['birth_date'] = birthDate;
      request.fields['shop_description'] = shopDescription;
      request.fields['id_kecamatan'] = kecamatanId.toString();

      if (profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
        ));
      }

      // LOG REQUEST FIELDS
      print("=== REQUEST TO: $uri ===");
      print("Headers: ${request.headers}");
      print("Fields:");
      request.fields.forEach((key, value) {
        print("  $key: $value");
      });

      // LOG FILES
      if (request.files.isNotEmpty) {
        for (var file in request.files) {
          print(
              "File: ${file.field} - ${file.filename} (${file.length} bytes)");
        }
      } else {
        print("No file uploaded.");
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData["data"] != null) {
          await _saveUserData(responseData["data"]);
        }
        return {
          "success": true,
          "message": "Vendor registration successful",
          "data": responseData
        };
      } else {
        final responseBody = jsonDecode(response.body);
        return {
          "success": false,
          "message": responseBody["error"] ?? "Vendor registration failed"
        };
      }
    } catch (e) {
      print("Exception during registerVendor: $e");
      return {"success": false, "message": "Error: $e"};
    }
  }

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

  Future<Map<String, dynamic>> cancelRegistration(
      {required String email}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/customer/cancel-registration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return {"success": true};
    } else {
      final body = jsonDecode(response.body);
      return {
        "success": false,
        "message": body["error"] ?? "Terjadi kesalahan saat membatalkan."
      };
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
