import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookingService {
  static final Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> createBooking({
    required BuildContext context,
    required int motorId,
    required String startDate,
    required String duration,
    required String pickupLocation,
    String? dropoffLocation,
    String? bookingPurpose, // Tambahkan parameter booking purpose
    required File photoId,
    required dynamic motorData, // Data motor
    required bool isGuest,
  }) async {
    try {
      final String baseUrl = ApiConfig.baseUrl;
      var uri = Uri.parse('$baseUrl/customer/bookings');
      var request = http.MultipartRequest("POST", uri);

      final storage = const FlutterSecureStorage();
      String? token = await storage.read(key: "auth_token");

      if (token == null || token.isEmpty) {
        return {
          "success": false,
          "message": "Sesi login habis, silakan login ulang."
        };
      }

      request.headers['Authorization'] = "Bearer $token";
      request.fields['motor_id'] = motorId.toString();
      request.fields['start_date'] =
          DateTime.parse(startDate).toUtc().toIso8601String();
// atau jika Anda ingin tetap mengirim sebagai WIB, beri tahu backend // tanpa .toUtc()

      request.fields['duration'] = duration;
      request.fields['pickup_location'] = pickupLocation;

      if (dropoffLocation != null && dropoffLocation.isNotEmpty) {
        request.fields['dropoff_location'] = dropoffLocation;
      }

      // Tambahkan booking purpose ke request
      if (bookingPurpose != null && bookingPurpose.isNotEmpty) {
        request.fields['booking_purpose'] = bookingPurpose;
      }

      // Compress images before uploading
      request.files.add(await http.MultipartFile.fromPath(
        'photo_id',
        photoId.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      // Add timeout to the request
      var response = await request.send().timeout(_timeout);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Booking sukses: $responseBody");
        final data = json.decode(responseBody);

        // Konversi start_date dari UTC ke waktu lokal
        String utcStartDateStr = data['booking']['start_date'];
        DateTime utcTime = DateTime.parse(utcStartDateStr);
        DateTime localTime = utcTime.toLocal();

        // Jika Anda ingin mengganti nilainya di dalam response:
        data['booking']['start_date_local'] = localTime.toIso8601String();

        return {
          "success": true,
          "message": "Booking berhasil dibuat",
          "motorData": motorData,
          "isGuest": isGuest,
          "booking":
              data['booking'], // include booking data with local start_date
        };
      } else {
        print("❌ Error ${response.statusCode}: $responseBody");
        try {
          final data = responseBody.isNotEmpty ? json.decode(responseBody) : {};
          return {
            "success": false,
            "message": data['error'] ?? 'Gagal melakukan booking',
          };
        } catch (e) {
          return {
            "success": false,
            "message": 'Terjadi kesalahan, silakan coba lagi.',
          };
        }
      }
    } on TimeoutException {
      print('❌ Request timeout');
      return {
        "success": false,
        "message":
            'Waktu permintaan habis. Silakan periksa koneksi internet Anda dan coba lagi.',
      };
    } catch (e) {
      print('❌ Exception: $e');
      return {
        "success": false,
        "message": 'Terjadi kesalahan: $e',
      };
    }
  }
}
