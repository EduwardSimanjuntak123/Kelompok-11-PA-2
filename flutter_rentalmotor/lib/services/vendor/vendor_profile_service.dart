// services/vendor_profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/models/vendor_profile_model.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

class VendorService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String _logTag = '[VendorService]';

  Future<VendorProfileModel?> getVendorProfile() async {
    print('$_logTag Starting vendor profile fetch...');
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token tidak tersedia');
      final url = '${ApiConfig.baseUrl}/vendor/profile';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode != 200)
        throw Exception('Failed: ${response.statusCode}');
      final data = json.decode(response.body);
      final user = data['user'];
      final vendor = user['vendor'];
      return VendorProfileModel(
        id: vendor['id'],
        shopName: vendor['shop_name'],
        shopAddress: vendor['shop_address'],
        shopDescription: vendor['shop_description'],
        districtName: vendor['kecamatan']?['nama_kecamatan']?.trim(),
        email: user['email'],
        phone: user['phone'],
        address: user['address'],
        profileImage: user['profile_image'],
      );
    } catch (e) {
      print('$_logTag Error: $e');
      rethrow;
    }
  }

  /// Update vendor profile, including optional profile image upload
  Future<void> updateVendorProfile({
    required String name,
    required String phone,
    required String address,
    required String shopName,
    File? imageFile,
  }) async {
    print('$_logTag Starting vendor profile update...');
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token tidak tersedia');
      final uri = Uri.parse('${ApiConfig.baseUrl}/vendor/profile/edit');

      // Prepare multipart request
      final request = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['phone'] = phone
        ..fields['address'] = address
        ..fields['shop_name'] = shopName;

      // If there is a new image, attach it
      if (imageFile != null) {
        final mimeType =
            lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];
        request.files.add(
          http.MultipartFile(
            'profile_image',
            imageFile.readAsBytes().asStream(),
            imageFile.lengthSync(),
            filename: imageFile.path.split('/').last,
            contentType: MediaType(mimeType[0], mimeType[1]),
          ),
        );
      }

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);
      print('$_logTag Update response status: ${resp.statusCode}');
      print('$_logTag Update response body: ${resp.body}');

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        print('$_logTag ✅ Vendor profile updated successfully');
      } else {
        throw Exception('Failed to update profile: ${resp.statusCode}');
      }
    } catch (e) {
      print('$_logTag Error updating profile: $e');
      rethrow;
    }
  }
}
