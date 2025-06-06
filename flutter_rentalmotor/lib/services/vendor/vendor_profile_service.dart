// services/vendor_service.dart
import 'dart:convert';
import 'dart\:io';
import 'package:mime/mime.dart';
import 'package\:http\_parser/http\_parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/api_config.dart';
import '../../models/vendor_profile_model.dart';

class VendorService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String _logTag = '[VendorService]';

  Future<VendorProfileModel?> getVendorProfile() async {
    print('$_logTag Starting vendor profile fetch...');

    try {
      // 1. Get auth token
      print('$_logTag Retrieving auth token from secure storage...');
      final token = await storage.read(key: "auth_token");

      if (token == null) {
        print('$_logTag ❌ Error: No auth token found in secure storage');
        throw Exception('Token tidak tersedia');
      }
      print('$_logTag ✅ Auth token retrieved successfully');

      // 2. Make API request
      final url = '${ApiConfig.baseUrl}/vendor/profile';
      print('$_logTag Making GET request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 3. Handle response
      print('$_logTag Received response with status: ${response.statusCode}');
      print('$_logTag Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('$_logTag ✅ Successfully fetched vendor profile');
        final data = json.decode(response.body);

        // Debug print the complete response structure
        print('$_logTag Complete API response structure:');
        print(data.toString());

        final user = data['user'];
        final vendor = user['vendor'];

        // Validate required fields
        if (vendor == null || user == null) {
          print('$_logTag ❌ Error: Missing required fields in response');
          throw Exception('Invalid vendor profile data structure');
        }

        print('$_logTag Parsed vendor data:');
        print('Shop Name: ${vendor['shop_name']}');
        print('Email: ${user['email']}');
        print('Profile Image: ${user['profile_image']}');

        return VendorProfileModel(
          id: vendor['id'],
          name: user['name'],
          shopName: vendor['shop_name'],
          shopAddress: vendor['shop_address'],
          shopDescription: vendor['shop_description'],
          districtName: vendor['kecamatan'] != null
              ? vendor['kecamatan']['nama_kecamatan']?.trim()
              : null,
          email: user['email'],
          phone: user['phone'],
          address: user['address'],
          profileImage: user['profile_image'],
        );
      } else {
        print(
            '$_logTag ❌ Error: API request failed with status ${response.statusCode}');
        throw Exception('Gagal memuat profil vendor: ${response.statusCode}');
      }
    } catch (e) {
      print('$_logTag ❌ Exception occurred: $e');
      print('$_logTag Stack trace: ${e is Error ? e.stackTrace : ''}');
      throw Exception('Error: $e');
    } finally {
      print('$_logTag Profile fetch process completed');
    }
  }

  Future<void> updateVendorProfile({
    String? name,
    String? shopName,
    String? phone,
    String? address,
    File? imageFile,
    int? kecamatanId,
  }) async {
    print('$_logTag Starting profile update...');
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token tidak tersedia');

      final uri = Uri.parse('${ApiConfig.baseUrl}/vendor/profile/edit');
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token';

      // Attach only non-null fields
      if (name != null) request.fields['name'] = name;
      if (shopName != null) request.fields['shop_name'] = shopName;
      if (phone != null) request.fields['phone'] = phone;
      if (address != null) request.fields['address'] = address;
      if (kecamatanId != null)
        request.fields['id_kecamatan'] = kecamatanId.toString();

      if (imageFile != null) {
        final mimeType =
            lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imageFile.path,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      }

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);
      print('$_logTag Update response status: ${resp.statusCode}');
      print('$_logTag Update response body: ${resp.body}');

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Gagal memperbarui profil: ${resp.statusCode}');
      }

      print('$_logTag ✅ Profile updated successfully');
    } catch (e) {
      print('$_logTag ❌ Error updating profile: $e');
      rethrow;
    }
  }
}
