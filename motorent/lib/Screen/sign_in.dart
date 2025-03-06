import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk inputFormatters
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import tambahan
import 'package:motorent2/Screen/user_selection_page.dart';
import 'package:motorent2/Screen/welcome_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false; // Variabel untuk status loading

  // Fungsi untuk menekan tombol sign-in
  void _signIn() {
    setState(() {
      isLoading = true; // Menyalakan loading spinner
    });

    // Simulasi proses login atau operasi lainnya
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false; // Mematikan loading spinner setelah proses selesai
      });

      // Navigasi atau tindakan setelah proses selesai
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserSelectionScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B4E75), // Warna yang diminta
                  Color(0xFF102A43), // Warna gelap sebagai variasi
                ],
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Hello\nSign in!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView( // ✅ Mencegah overflow
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30), // Tambahan spacing
                      TextField(
                        keyboardType: TextInputType.phone, // ✅ Menggunakan keyboard angka
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly], // ✅ Hanya angka yang bisa dimasukkan
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.check, color: Colors.grey),
                          labelText: 'No. Telepon',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4E75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const TextField(
                        obscureText: true, // Menyembunyikan password
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.visibility_off, color: Colors.grey),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B4E75),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF102A43),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Tambahan spacing
                      GestureDetector(
                        onTap: _signIn, // Menjalankan fungsi _signIn saat tombol ditekan
                        child: Container(
                          height: 55,
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1B4E75),
                                Color(0xFF102A43),
                              ],
                            ),
                          ),
                          child: Center(
                            child: isLoading
                                ? const SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 30.0,
                                  ) // Spinner saat loading
                                : const Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40), // Mengurangi tinggi agar tidak overflow
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.black,
                                  decoration: TextDecoration.underline, // Tambahkan garis bawah agar terlihat seperti link
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Menghindari overflow
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
