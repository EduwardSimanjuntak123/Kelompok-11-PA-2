import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/motor.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8080"; // Sesuaikan dengan backend

  // Fungsi untuk mengambil daftar motor dari backend
  Future<List<Motor>> fetchMotors() async {
    final response = await http.get(Uri.parse("$baseUrl/motors"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Motor.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data motor");
    }
  }

  // Fungsi untuk menambahkan motor baru ke backend
  // Future<void> addMotor(Motor motor) async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/motor"),
  //     body: json.encode(motor.toJson()),
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //   }
  //   if (response.statusCode == 201) {
  //     print("Motor berhasil ditambahkan");
  //   } else {
  //     throw Exception("Gagal menambahkan motor");
  //   }
  
}
