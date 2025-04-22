import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        final data = json.decode(response.body);
        final user = data['user'];
        final vendor = user['vendor'];

        // Periksa apakah vendor ada
        if (vendor == null) {
          // Menangani jika data vendor kosong atau null
          throw Exception("Data vendor tidak ditemukan.");
        }

        // Menyimpan informasi vendor di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('vendorId', vendor['id']);
        await prefs.setString('businessName', vendor['shop_name']);
        await prefs.setString('vendorAddress', vendor['shop_address']);
        await prefs.setString('vendorEmail', user['email']);

        return {
          'vendorId': vendor['id'],
          'businessName': vendor['shop_name'],
          'vendorAddress': vendor['shop_address'],
          'vendorImagePath': user['profile_image'],
          'vendorEmail': user['email'],
        };
      } else {
        final error = json.decode(response.body)['error'] ?? "Gagal memuat data vendor";
        throw Exception(error);
      }
    } catch (e) {
      print("Error loading vendor profile: $e");
      throw Exception("Gagal memuat profil vendor");
    }
  }

  // Get bookings data
  Future<List<dynamic>> getBookings() async {
    try {
      final token = await secureStorage.read(key: "auth_token");
      final String baseUrl = ApiConfig.baseUrl;
      final bookingsUrl = Uri.parse('$baseUrl/vendor/bookings');
      
      final bookingsResponse = await http.get(
        bookingsUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (bookingsResponse.statusCode == 200) {
        final bookingsData = json.decode(bookingsResponse.body);

        // Pastikan bahwa data bookings tidak kosong atau null
        if (bookingsData == null || bookingsData.isEmpty) {
          return [];  // Kembalikan list kosong jika tidak ada data
        }

        return bookingsData;
      } else {
        throw Exception("Gagal memuat data pesanan");
      }
    } catch (e) {
      print("Error loading bookings: $e");
      throw Exception("Gagal memuat data pesanan");
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
          return [];  // Kembalikan list kosong jika tidak ada data transaksi
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
