import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class VendorService {
  final String baseUrl = ApiConfig.baseUrl;

  // Ambil data vendor berdasarkan ID
  Future<Map<String, dynamic>> fetchVendorById(int vendorId) async {
    final response = await http.get(Uri.parse("$baseUrl/vendor/$vendorId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Sesuai dengan struktur JSON yang dikembalikan
    } else {
      throw Exception("Gagal mengambil data vendor dengan ID: $vendorId");
    }
  }

  Future<List<Map<String, dynamic>>> fetchMotorsByVendor(int vendorId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/customer/motors/vendor/$vendorId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception("Gagal mengambil data motor untuk vendor ID: $vendorId");
    }
  }
}
