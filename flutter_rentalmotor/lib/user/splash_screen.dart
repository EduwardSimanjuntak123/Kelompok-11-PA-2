import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/vendor/homepagevendor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLoading = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Tampilkan logo dulu selama 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showLoading = true; // Setelah 3 detik, tampilkan loading
      });

      // Setelah loading 2 detik, cek status login
      Future.delayed(Duration(seconds: 2), () {
        _checkLoginStatus();
      });
    });
  }

  Future<void> _checkLoginStatus() async {
    // Ambil token dan role dari secure storage
    String? token = await storage.read(key: "auth_token");
    String? role = await storage.read(key: "role");

    if (token != null && role != null) {
      if (role == "vendor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomepageVendor()),
        );
      } else if (role == "customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
      } else {
        // Jika role tidak dikenali, arahkan ke HomePageUser sebagai default
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
      }
    } else {
      // Jika tidak ada token atau role, arahkan ke HomePageUser (atau halaman login jika perlu)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: showLoading ? const Color(0xFF2D88C3) : const Color(0xFF174D78),
        child: Center(
          child: showLoading
              ? const CircularProgressIndicator(
                  color: Color(0xFF174D78),
                )
              : Image.asset(
                  'assets/images/logo1.png',
                  width: 150,
                ),
        ),
      ),
    );
  }
}
