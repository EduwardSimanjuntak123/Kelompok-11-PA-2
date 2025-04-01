import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class VendorService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchVendors() async {
    final response = await http.get(Uri.parse("$baseUrl/vendor"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception("Gagal mengambil data vendor!");
    }
  }
}
