import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'dart:async';

class WebSocketService {
  IOWebSocketChannel? _channel;
  Timer? _pingTimer;
  IOWebSocketChannel? _chatNotificationChannel;
  final Function(Map<String, dynamic>) onNotificationReceived;
  final Function(int)? onChatMessageReceived;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  WebSocketService({
    required this.onNotificationReceived,
    this.onChatMessageReceived,
    required this.notificationsPlugin,
  });

  void connectWebSocket(int userId) {
    // Tutup koneksi lama dulu kalau ada
    _channel?.sink.close();
    _pingTimer?.cancel(); // Stop ping sebelumnya

    final wsUrl = "${ApiConfig.wsUrl}/ws/notifikasi?user_id=$userId";
    debugPrint("Connecting to WebSocket: $wsUrl");

    try {
      _channel = IOWebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        (data) async {
          debugPrint("WebSocket data received: $data");
          try {
            final Map<String, dynamic> outer = json.decode(data);

            if (outer.containsKey('message')) {
              final String messageStr = outer['message'];
              final Map<String, dynamic> inner = json.decode(messageStr);

              final int bookingId = inner['booking_id'];
              final String message = inner['message'];

              final newNotification = {
                'text': "Booking!",
                'read': false,
                'timestamp': DateTime.now().toIso8601String(),
                'booking_id': bookingId,
                'type': 'booking',
              };

              onNotificationReceived(newNotification);
              _showLocalNotification("Booking #$bookingId", message);
            } else {
              final fallbackNotification = {
                'text': data.toString(),
                'read': false,
                'timestamp': DateTime.now().toIso8601String(),
                'type': 'system',
              };
              onNotificationReceived(fallbackNotification);
              _showLocalNotification("Notifikasi", data.toString());
            }
          } catch (e) {
            debugPrint("Error parsing notification: $e");
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _reconnect(userId);
        },
        onDone: () {
          debugPrint("WebSocket connection closed");
          _reconnect(userId);
        },
      );

      // Mulai timer untuk kirim ping setiap 30 detik
      _pingTimer = Timer.periodic(Duration(seconds: 30), (_) {
        debugPrint("Sending ping...");
        _channel?.sink.add(json.encode({"type": "ping"}));
      });
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
      _reconnect(userId);
    }
  }

  void _reconnect(int userId) {
    _pingTimer?.cancel(); // Pastikan ping timer dihentikan dulu
    Future.delayed(Duration(seconds: 5), () {
      connectWebSocket(userId);
    });
  }
  
  Future<void> _showLocalNotification(String title, String body) async {
    // Configure Android notification details with high importance
    const androidDetails = AndroidNotificationDetails(
      'rental_motor_channel_v3',
      'Rental Motor Notifications',
      channelDescription: 'Notifications for Rental Motor app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
      visibility: NotificationVisibility.public,
      fullScreenIntent: true, // This will show as a heads-up notification
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      DateTime.now().millisecond, // unique ID
      title,
      body,
      notificationDetails,
      payload:
          'notification_payload', // You can use this to pass data when notification is tapped
    );
  }

  void dispose() {
    _channel?.sink.close();
    _chatNotificationChannel?.sink.close();
    _pingTimer?.cancel();
  }
}
