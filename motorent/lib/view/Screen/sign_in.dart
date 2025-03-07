import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk inputFormatters
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import tambahan
import 'package:motorent2/view/Screen/user_selection_page.dart';
import 'package:motorent2/controller/authController.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false; // Variabel untuk status loading
  final AuthController authController = AuthController(); // Inisialisasi controller

  // Fungsi untuk menekan tombol sign-in
  void _signIn() {
    setState(() {
      isLoading = true; // Menyalakan loading spinner
    });

    authController.loginUser().then((_) {
      setState(() {
        isLoading = false; // Matikan loading spinner setelah proses selesai
      });
      // Lakukan navigasi setelah login berhasil
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserSelectionScreen(),
        ),
      );
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      // Tampilkan pesan error jika login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B4E75),
                  Color(0xFF102A43),
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
          // Form login
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      TextField(
                        controller: authController.usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: authController.passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: _signIn,//login
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
                                  )
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
