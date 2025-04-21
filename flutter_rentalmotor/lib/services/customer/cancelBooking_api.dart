import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class BatalkanPesananAPI {
  static final storage = FlutterSecureStorage();

  static Future<bool> cancelBooking(int bookingId) async {
    final token = await storage.read(key: "auth_token");
    final url =
        Uri.parse("${ApiConfig.baseUrl}/customer/bookings/$bookingId/cancel");

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }
}
