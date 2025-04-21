// services/detail_motor_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';

class DetailMotorApi {
  static Future<Map<String, dynamic>?> fetchMotorById(int id) async {
    final String url = '${ApiConfig.baseUrl}/motor/';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> motors = data["data"] ?? [];

      try {
        return motors.firstWhere((motor) => motor["id"] == id);
      } catch (e) {
        return null; // Motor dengan ID tidak ditemukan
      }
    } else {
      throw Exception('Failed to load motor data');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchReviewsByMotorId(int motorId) async {
    final String url = '${ApiConfig.baseUrl}/reviews/motor/$motorId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
