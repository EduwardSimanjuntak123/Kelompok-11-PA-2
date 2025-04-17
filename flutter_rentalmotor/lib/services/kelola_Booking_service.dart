// kelola_Booking_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KelolaBookingService {
  final String baseUrl = 'http://192.168.6.159:8080';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> confirmBooking(String bookingId) async {
    await _updateBookingStatus(bookingId, 'confirm');
  }

  Future<void> rejectBooking(String bookingId) async {
    await _updateBookingStatus(bookingId, 'reject');
  }

  Future<void> setBookingToTransit(String bookingId) async {
    await _updateBookingStatus(bookingId, 'transit');
  }

  Future<void> setBookingToInUse(String bookingId) async {
    await _updateBookingStatus(bookingId, 'inuse');
  }

  Future<void> completeBooking(String bookingId) async {
    await _updateBookingStatus(bookingId, 'complete');
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await storage.read(key: 'auth_token');
      final url = Uri.parse('$baseUrl/vendor/bookings/$status/$bookingId');
      
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Status update successful');
      } else {
        throw Exception('Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating booking status: $e');
    }
  }
}
