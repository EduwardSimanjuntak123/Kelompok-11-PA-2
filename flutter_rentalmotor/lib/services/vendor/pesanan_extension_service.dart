import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/customer/cancelBooking_api.dart';

class PesananExtensionService {
  // Fetch unavailable dates for a motor
  static Future<List<DateTime>> getUnavailableDates(int motorId) async {
    try {
      final token = await BatalkanPesananAPI.storage.read(key: "auth_token");
      final url = Uri.parse("${ApiConfig.baseUrl}/bookings/motor/$motorId");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<DateTime> dates = [];

        for (var booking in data) {
          DateTime start = DateTime.parse(booking['start_date']).toLocal();
          DateTime end = DateTime.parse(booking['end_date']).toLocal();

          // Debugging: Menampilkan tanggal mulai dan selesai yang diterima dari API
          print('Start Date: $start');
          print('End Date: $end');

          // Normalisasi untuk mengambil hanya tanggal
          start = DateTime(start.year, start.month, start.day);
          end = DateTime(end.year, end.month, end.day);

          // Debugging: Menampilkan tanggal yang telah dinormalisasi
          print('Normalized Start Date: $start');
          print('Normalized End Date: $end');

          // Menambahkan semua tanggal antara tanggal mulai dan selesai ke daftar
          for (int i = 0; i <= end.difference(start).inDays; i++) {
            final day = start.add(Duration(days: i));
            dates.add(day);
            // Debugging: Menampilkan setiap tanggal yang ditambahkan
            print('Unavailable Date: $day');
          }
        }

        return dates;
      } else {
        throw Exception("Gagal mengambil data pemesanan");
      }
    } catch (e) {
      print("Error fetching unavailable dates: $e");
      return [];
    }
  }

  // Request extension for a booking
  static Future<Map<String, dynamic>> requestExtensionDays(
      int bookingId, int additionalDays) async {
    try {
      final token = await BatalkanPesananAPI.storage.read(key: "auth_token");
      final url =
          Uri.parse("${ApiConfig.baseUrl}/customer/bookings/$bookingId/extend");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'additional_days': additionalDays}),
      );

      print("=== RESPONSE EXTEND BOOKING ===");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");
      print("===============================");

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Terjadi kesalahan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Fetch extensions for a booking
  static Future<List<dynamic>> fetchExtensions(int bookingId) async {
    try {
      final token = await BatalkanPesananAPI.storage.read(key: 'auth_token');
      final url = Uri.parse(
          '${ApiConfig.baseUrl}/customer/bookings/$bookingId/extensions');

      // Debugging: Menampilkan URL dan token yang digunakan
      print('Request URL: $url');
      print('Authorization Header: Bearer $token');

      final resp =
          await http.get(url, headers: {'Authorization': 'Bearer $token'});

      // Debugging: Menampilkan status code dan response body
      print('Response Status Code: ${resp.statusCode}');
      print('Response Body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return data['extensions'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching extensions: $e");
      return [];
    }
  }
}
