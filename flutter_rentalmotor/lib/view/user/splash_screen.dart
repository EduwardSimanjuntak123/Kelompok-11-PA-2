import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/homepagevendor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showLoading = false;
  bool showLogo = false;
  final FlutterSecureStorage storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Animasi logo muncul
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        showLogo = true;
      });
    });

    // Tampilkan loading setelah 3 detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        showLoading = true;
      });

      // Lanjutkan cek login setelah 2 detik loading
      Future.delayed(Duration(seconds: 2), () {
        _cekStatusLogin();
      });
    });
  }

  Future<void> _cekStatusLogin() async {
    String? token = await storage.read(key: "auth_token");
    String? role = await storage.read(key: "role");
    print("Token: $token, Peran: $role");

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
      }
    } else {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF174D78), Color(0xFF2D88C3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: showLogo ? 1.0 : 0.0,
                duration: Duration(seconds: 1),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    key: ValueKey('splashLogo'),
                    'assets/images/logo1.png',
                    width: 160,
                  ),
                ),
              ),
              SizedBox(height: 30),
              showLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(
                          key: ValueKey('loadingIndicator'),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Sedang memuat...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'Poppins', // pastikan font diimport
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
