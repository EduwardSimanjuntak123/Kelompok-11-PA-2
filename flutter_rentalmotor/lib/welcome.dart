import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_rentalmotor/view/vendor/registrasi/signupvendor.dart';
import 'package:flutter_rentalmotor/view/user/registrasi/signupcustomer.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ukuran layar untuk responsif
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Gradient dengan warna tema utama 0xFF1A5276
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A5276),
              Color(0xFF154360),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: size.height * 0.38,
                    child: Lottie.asset(
                      'assets/images/animations/welcome.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: AnimatedTextKit(
                      repeatForever: true,
                      pause: const Duration(milliseconds: 1500),
                      animatedTexts: [
                        FadeAnimatedText("Selamat Datang di MotoRent"),
                        FadeAnimatedText("Sewa Kendaraan Impian Anda"),
                        FadeAnimatedText("Mulai Perjalanan Anda"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Platform sewa motor terbaik, mudah dan terpercaya untuk semua kebutuhanmu.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black38,
                          offset: Offset(1, 1),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 44),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpCustomer()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 12,
                        shadowColor: const Color(0xFF154360).withOpacity(0.7),
                        backgroundColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1A5276),
                              Color(0xFF154360),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45.withOpacity(0.2),
                              offset: const Offset(0, 6),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          constraints: const BoxConstraints(minHeight: 55),
                          child: const Text(
                            "PELANGGAN",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.7,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpVendorScreen()),
                        );
                      },
                      icon: const Icon(Icons.storefront_rounded,
                          color: Colors.white70, size: 24),
                      label: const Text(
                        "VENDOR",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                          letterSpacing: 1.4,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.white70.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  const Opacity(
                    opacity: 0.6,
                    child: Text(
                      "© 2024 MotoRent. All rights reserved.",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
