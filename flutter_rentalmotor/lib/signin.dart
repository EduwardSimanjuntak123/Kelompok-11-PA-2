import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/SignUpCustomer.dart';
import 'package:flutter_rentalmotor/services/api_service.dart';
import 'package:flutter_rentalmotor/vendor/homepagevendor.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isEmailFilled = false;
  bool _isPasswordFilled = false;
  bool _isLoading = false;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isEmailFilled = emailController.text.isNotEmpty;
      _isPasswordFilled = passwordController.text.isNotEmpty;
    });
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      print("Memulai proses login...");
      final response = await loginUser(
        emailController.text.trim(),
        passwordController.text,
      );

      if (response.containsKey("error")) {
        setState(() {
          _errorMessage = response["error"];
          _isLoading = false;
        });
        return;
      }

      final user = response["user"];
      final role = user["role"];
      final token = response["token"];

      // Simpan data login ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_name', user["name"]);
      await prefs.setInt('user_id', user["id"]);

      if (role == "customer") {
        _showSuccessDialog();
      } else if (role == "vendor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomepageVendor()),
        );
      } else {
        setState(() {
          _errorMessage = "Akses ditolak! Role tidak dikenali.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Terjadi kesalahan saat login. Coba lagi nanti.";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Berhasil"),
          content: Text("Selamat datang di aplikasi rental motor."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageUser()),
                );
              },
              child: Text("Lanjutkan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFEFEF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                color: Color(0xFF2C567E),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              padding: EdgeInsets.only(top: 80, left: 20),
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello!!",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Log In",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Input Email
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  suffixIcon: Icon(Icons.check_circle,
                      color: _isEmailFilled ? Colors.green : Colors.grey),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Input Password
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Tombol Sign In
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: (_isEmailFilled && _isPasswordFilled && !_isLoading)
                    ? _handleLogin
                    : null,
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : Text("SIGN IN",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
            // Sign Up Text
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpCustomer()));
              },
              child: Text("Sign up",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
