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
  try {
    final url = Uri.parse("$baseUrl/customer/motors/vendor/$vendorId");
    print("📡 Fetching motors for vendor $vendorId: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded == null || decoded is! Map<String, dynamic>) {
        print("⚠️ Response bukan Map atau null");
        return [];
      }

      final data = decoded['data'];

      if (data is List) {
        print("✅ Data motor berhasil diambil. Jumlah: ${data.length}");
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("⚠️ Data motor null atau tidak dalam format list");
        return [];
      }
    } else {
      print("❌ Status bukan 200: ${response.statusCode}");
      print("❌ Response body: ${response.body}");
      return [];
    }
  } catch (e) {
    print("❌ Exception saat fetch motor vendor $vendorId: $e");
    return [];
  }
}

}


