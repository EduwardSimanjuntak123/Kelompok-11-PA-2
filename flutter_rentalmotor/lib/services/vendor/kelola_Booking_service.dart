import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KelolaBookingService {
  final String baseUrl = ApiConfig.baseUrl;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<void> confirmBooking(String bookingId) async {
    await _putRequest('/vendor/bookings/$bookingId/confirm');
  }

  Future<void> rejectBooking(String bookingId) async {
    await _putRequest('/vendor/bookings/$bookingId/reject');
  }

  Future<void> setBookingToTransit(String bookingId) async {
    await _putRequest('/vendor/bookings/transit/$bookingId');
  }

  Future<void> setBookingToInUse(String bookingId) async {
    await _putRequest('/vendor/bookings/inuse/$bookingId');
  }

  Future<void> completeBooking(String bookingId) async {
    await _putRequest('/vendor/bookings/complete/$bookingId');
  }

  Future<void> _putRequest(String endpoint) async {
    try {
      final token = await storage.read(key: 'auth_token');
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Status update successful');
      } else {
        throw Exception(
            'Failed to update booking status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating booking status: $e');
      rethrow; // Re-throw the exception to handle it in the UI
    }
  }
}
