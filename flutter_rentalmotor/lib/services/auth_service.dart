import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://your-api-url.com/api'; // Ganti dengan URL API backend-mu

  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String birthDate,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
          "birth_date": birthDate,
        }),
      );

      if (response.statusCode == 201) {
        return {"success": true, "message": "Registration successful"};
      } else {
        final responseBody = jsonDecode(response.body);
        return {"success": false, "message": responseBody["error"] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }
}
