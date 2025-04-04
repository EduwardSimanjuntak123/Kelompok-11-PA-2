import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLoading = false;

  @override
  void initState() {
    super.initState();

    // Tampilkan logo dulu selama 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showLoading = true; // Setelah 3 detik, tampilkan loading
      });

      // Setelah loading 2 detik, masuk ke halaman utama
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: showLoading
            ? Color(0xFF2D88C3)
            : Color(0xFF174D78), // Ubah warna sesuai tahap
        child: Center(
          child: showLoading
              ? CircularProgressIndicator(
                  color: Color(0xFF174D78), // Warna loading
                )
              : Image.asset('assets/images/logo1.png',
                  width: 150), // Tampilan logo awal
        ),
      ),
    );
  }
}
