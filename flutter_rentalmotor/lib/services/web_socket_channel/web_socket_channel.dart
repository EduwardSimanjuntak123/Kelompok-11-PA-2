import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

Future<void> connectWebSocket() async {
  final prefs = await SharedPreferences.getInstance();
  final userId =
      prefs.getInt('user_id'); // Pastikan user_id disimpan saat login

  if (userId == null) {
    print("❌ User belum login");
    return;
  }

  final channel = WebSocketChannel.connect(
    Uri.parse('${ApiConfig.wsUrl}/ws?user_id=$userId'),
  );

  channel.stream.listen((message) {
    print('📨 Notifikasi: $message');
    // Tampilkan notifikasi pop-up atau badge di sini
  });
}
