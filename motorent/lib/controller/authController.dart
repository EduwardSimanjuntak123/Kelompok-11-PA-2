import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Fungsi untuk melakukan login
  Future loginUser() async {

    // Debugging: Cek apakah email dan password yang dimasukkan
    print("Attempting to login with Email: ${usernameController.text}");
    print("Attempting to login with Password: ${passwordController.text}");

    // Kirim POST request dengan body berupa JSON
    try {
      final response = await http.post(
        Uri.parse("http://192.168.56.1:8080/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": usernameController.text, // Mengambil input email
          "password": passwordController.text // Mengambil input password
        }),
      );
      print(response.headers["location"]);
      // Debugging: Cek status code dari server
      print("Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        var loginData = json.decode(response.body);
        print("Login Success: ${loginData['message']}");
        print("Token: ${loginData['token']}");
        throw Exception("login berhasil");

        // Lakukan sesuatu setelah login sukses, seperti navigasi
        // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        print("Error: ${response.body}");
        throw Exception("login gagal");
        // Tampilkan error jika login gagal
        // Show error message to the user
      }
    } catch (e) {
      print("Request failed with error: $e");
      // Menampilkan error jika request gagal
    }
  }
}
