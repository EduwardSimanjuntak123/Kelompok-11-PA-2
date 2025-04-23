import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/models/motor_model.dart'; // Import MotorModel
import 'package:flutter_rentalmotor/config/api_config.dart'; // Import API config
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import flutter_secure_storage
import 'package:http_parser/http_parser.dart';

class VendorMotorApi {
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Secure storage instance

  // Fetching motor data from the API
  Future<List<dynamic>> fetchMotorData() async {
    List<dynamic> motorList = [];

    try {
      String? token = await storage.read(key: 'auth_token');
      final String baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/motor/vendor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('← Response Status: ${response.statusCode}');
      print('← Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        motorList = data['data']; // Get motor data
      } else {
        throw Exception("Failed to load motor data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }

    return motorList;
  }

  // Fetch motor details by ID from the API
  Future<MotorModel> fetchMotorDetail(int motorId) async {
    try {
      String? token = await storage.read(key: 'auth_token');
      final String baseUrl = ApiConfig.baseUrl;

      final response = await http.get(
        Uri.parse(
            '$baseUrl/motor/vendor/$motorId'), // Use motorId to fetch details
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('← Response Status: ${response.statusCode}');
      print('← Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MotorModel.fromJson(
            data['data']); // Return motor data as MotorModel
      } else {
        throw Exception("Failed to load motor details: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Update motor details using PUT request with multipart/form-data
  Future<void> updateMotor(MotorModel motor, File? image) async {
    try {
      String? token = await storage.read(key: 'auth_token');
      final String baseUrl = ApiConfig.baseUrl;

      var request = http.MultipartRequest(
          'PUT', Uri.parse('$baseUrl/motor/vendor/${motor.id}'));

      // Attach the text fields
      request.fields['name'] = motor.name;
      request.fields['brand'] = motor.brand;
      request.fields['year'] = motor.year.toString();
      request.fields['price'] = motor.price.toString();
      request.fields['color'] = motor.color;
      request.fields['status'] = motor.status;
      request.fields['type'] = motor.type;
      request.fields['description'] = motor.description;
      request.fields['rating'] = motor.rating.toString();

      // Attach image if selected
      if (image != null) {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: image.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Add token to headers
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request
      var response = await request.send();

      response.stream.transform(utf8.decoder).listen((value) {
        if (response.statusCode == 200) {
          print("Motor updated successfully: ${motor.id}");
        } else {
          print("Failed to update motor: $value");
        }
      });
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Delete motor from the API
  Future<void> deleteMotor(int motorId) async {
    try {
      String? token = await storage.read(key: 'auth_token');
      final String baseUrl = ApiConfig.baseUrl;

      final response = await http.delete(
        Uri.parse(
            '$baseUrl/motor/vendor/$motorId'), // API endpoint to delete motor
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Motor deleted successfully: $motorId");
      } else {
        throw Exception("Failed to delete motor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
