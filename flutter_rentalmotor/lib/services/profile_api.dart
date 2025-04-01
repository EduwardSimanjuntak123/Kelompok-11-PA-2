import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class ProfileAPI {
  final String baseUrl = ApiConfig.baseUrl;

  /// Memanggil API untuk mendapatkan data profile customer dan mengubah path gambar menjadi URL lengkap
  Future<Map<String, dynamic>> getCustomerProfile({String? token}) async {
    final url = Uri.parse('$baseUrl/customer/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data["user"];

        // Jika field profile_image ada, pastikan URL-nya lengkap
        String path = user["profile_image"] ?? "";
        if (path.isNotEmpty && !path.startsWith("http")) {
          user["profile_image"] = "$baseUrl$path";
        }
        return {"success": true, "data": user};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData["error"] ?? "Gagal mengambil data profile"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
