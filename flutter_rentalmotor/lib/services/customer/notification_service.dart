import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/notification_model.dart';

class NotificationService {
  static const String key = 'notifications';

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> data = jsonDecode(jsonString);
    return data.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(key, jsonData);
  }

  Future<void> addNotification(AppNotification notification) async {
    final list = await getNotifications();
    list.insert(0, notification); // terbaru di atas
    await saveNotifications(list);
  }

  Future<void> deleteNotification(String id) async {
    final list = await getNotifications();
    list.removeWhere((n) => n.id == id);
    await saveNotifications(list);
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
