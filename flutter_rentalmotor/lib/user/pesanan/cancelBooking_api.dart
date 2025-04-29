import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

class BatalkanPesananAPI {
  static Future<bool> cancelBooking(int bookingId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customer/bookings/$bookingId/cancel');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Map<String, dynamic>> postRequestExtend(int bookingId, String requestedEndDate) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/customer/bookings/$bookingId/extend');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "requested_end_date": requestedEndDate,
      }),
    );

    final decoded = jsonDecode(response.body);
    return decoded;
  }
}
