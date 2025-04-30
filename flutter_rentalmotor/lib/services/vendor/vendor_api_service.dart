import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class VendorApiService {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Get vendor profile data
  Future<Map<String, dynamic>> getVendorProfile() async {
    try {
      final token = await secureStorage.read(key: "auth_token");
      final String baseUrl = ApiConfig.baseUrl;
      final url = Uri.parse('$baseUrl/vendor/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;
        final vendor = user['vendor'] as Map<String, dynamic>?;

        if (vendor == null) {
          throw Exception("Data vendor tidak ditemukan.");
        }

        // Simpan di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('vendorId', vendor['id'] as int);
        await prefs.setInt('vendorUserId', user['id'] as int); // ← tambahan
        await prefs.setString('businessName', vendor['shop_name'] as String);
        await prefs.setString(
            'vendorAddress', vendor['shop_address'] as String);
        await prefs.setString('vendorEmail', user['email'] as String);

        return {
          'vendorId': vendor['id'],
          'vendorUserId': user['id'], // ← tambahan
          'businessName': vendor['shop_name'],
          'vendorAddress': vendor['shop_address'],
          'vendorImagePath': user['profile_image'],
          'vendorEmail': user['email'],
        };
      } else {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final error = body['error'] ?? "Gagal memuat data vendor";
        throw Exception(error);
      }
    } catch (e) {
      debugPrint("Error loading vendor profile: $e");
      throw Exception("Gagal memuat profil vendor");
    }
  }

  // Get bookings data
  Future<List<dynamic>> getBookings() async {
    try {
      final token = await secureStorage.read(key: "auth_token");
      final bookingsUrl = Uri.parse('${ApiConfig.baseUrl}/vendor/bookings');
      final response = await http.get(
        bookingsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debug: print status code dan response body
      debugPrint('getBookings() status: ${response.statusCode}');
      debugPrint('getBookings() body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = json.decode(response.body);
        debugPrint('Decoded bookingsData length: ${bookingsData.length}');
        if (bookingsData.isEmpty) {
          debugPrint('Warning: bookingsData is empty!');
          return [];
        }
        return bookingsData;
      } else {
        debugPrint('Error: status ${response.statusCode}');
        throw Exception("Gagal memuat data pesanan");
      }
    } catch (e, st) {
      debugPrint('Exception in getBookings(): $e\n$st');
      rethrow;
    }
  }

  // Get transactions data
  Future<List<dynamic>> getTransactions() async {
    try {
      final token = await secureStorage.read(key: "auth_token");
      final String baseUrl = ApiConfig.baseUrl;
      final transactionsUrl = Uri.parse('$baseUrl/transaction/');

      final transactionsResponse = await http.get(
        transactionsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (transactionsResponse.statusCode == 200) {
        final transactionsData = json.decode(transactionsResponse.body);

        // Pastikan bahwa data transaksi tidak kosong atau null
        if (transactionsData == null || transactionsData.isEmpty) {
          return []; // Kembalikan list kosong jika tidak ada data transaksi
        }

        return transactionsData;
      } else {
        throw Exception("Gagal memuat data transaksi");
      }
    } catch (e) {
      print("Error loading transactions: $e");
      throw Exception("Gagal memuat data transaksi");
    }
  }

  // Logout
  Future<void> logout() async {
    await secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
