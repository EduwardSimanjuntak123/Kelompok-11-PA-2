import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/detailmotor.dart';

class BookingService {
  static Future<bool> createBooking({
    required BuildContext context,
    required int motorId,
    required String startDate,
    required String duration,
    required String pickupLocation,
    String? dropoffLocation,
    required File photoId,
    required File ktpId,
    required dynamic motorData, // Data motor untuk redirect ke DetailMotorPage
    required bool isGuest, // Status login user
  }) async {
    try {
      final String baseUrl = ApiConfig.baseUrl;
      var uri = Uri.parse('$baseUrl/customer/bookings');

      var request = http.MultipartRequest("POST", uri);

      final storage = const FlutterSecureStorage();
      String? token = await storage.read(key: "auth_token");

      if (token == null || token.isEmpty) {
        _showSessionExpiredDialog(context);
        return false;
      }

      request.headers['Authorization'] = "Bearer $token";

      request.fields['motor_id'] = motorId.toString();
      request.fields['start_date'] = startDate;
      request.fields['duration'] = duration;
      request.fields['pickup_location'] = pickupLocation;

      if (dropoffLocation != null && dropoffLocation.isNotEmpty) {
        request.fields['dropoff_location'] = dropoffLocation;
      }

      request.files.add(await http.MultipartFile.fromPath(
        'photo_id',
        photoId.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      request.files.add(await http.MultipartFile.fromPath(
        'ktp_id',
        ktpId.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Booking sukses: $responseBody");
        _showSuccessDialog(
            context, "Booking berhasil dibuat", motorData, isGuest);
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Error 401: Token tidak valid");
        _showSessionExpiredDialog(context);
        return false;
      } else {
        print("❌ Error ${response.statusCode}: $responseBody");
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return false;
    }
  }

  static void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sesi Berakhir'),
        content: Text('Sesi telah habis, silakan login kembali.'),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              const storage = FlutterSecureStorage();
              await storage.deleteAll();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showSuccessDialog(
    BuildContext context,
    String message,
    dynamic motorData,
    bool isGuest,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailMotorPage(
                    motorId:motorData["id"],
                    isGuest: isGuest,
                  ),
                ),
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
