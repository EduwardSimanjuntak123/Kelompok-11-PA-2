import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

class WebSocketService {
  IOWebSocketChannel? _channel;
  final Function(Map<String, dynamic>) onNotificationReceived;
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  WebSocketService({
    required this.onNotificationReceived,
    required this.notificationsPlugin,
  });

  void connectWebSocket(int userId) {
    // Close existing connection if any
    _channel?.sink.close();

    // Ensure the WebSocket URL has the correct format with the /ws/ prefix
    final wsUrl = "${ApiConfig.wsUrl}/ws/notifikasi?user_id=$userId";

    debugPrint("Connecting to WebSocket: $wsUrl");

    try {
      _channel = IOWebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        (data) async {
          debugPrint("WebSocket data received: $data");
          try {
            // Parse the outer JSON object
            final Map<String, dynamic> outer = json.decode(data);

            // The message field contains another JSON string that needs to be parsed
            if (outer.containsKey('message')) {
              final String messageStr = outer['message'];
              final Map<String, dynamic> inner = json.decode(messageStr);

              final int bookingId = inner['booking_id'];
              final String message = inner['message'];

              final newNotification = {
                'text': "Booking #$bookingId: $message",
                'read': false,
                'timestamp': DateTime.now().toIso8601String(),
                'booking_id': bookingId,
                'type': 'booking',
              };

              onNotificationReceived(newNotification);
              _showLocalNotification("Booking #$bookingId", message);
            } else {
              // Fallback if the expected format is different
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
            // If parsing fails, still try to show the notification with the raw data
            final fallbackNotification = {
              'text': data.toString(),
              'read': false,
              'timestamp': DateTime.now().toIso8601String(),
              'type': 'system',
            };
            onNotificationReceived(fallbackNotification);
            _showLocalNotification("Notifikasi", "Ada notifikasi baru");
          }
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          // Try to reconnect after a delay
          Future.delayed(const Duration(seconds: 5), () {
            connectWebSocket(userId);
          });
        },
        onDone: () {
          debugPrint("WebSocket connection closed");
          // Try to reconnect after a delay
          Future.delayed(const Duration(seconds: 5), () {
            connectWebSocket(userId);
          });
        },
      );
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
      // Try to reconnect after a delay
      Future.delayed(const Duration(seconds: 5), () {
        connectWebSocket(userId);
      });
    }
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
  }
}
