import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/api_service.dart';
import 'package:flutter_rentalmotor/vendor/homepage/homepagevendor.dart';
import 'package:flutter_rentalmotor/welcome.dart';

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

      // Simpan token ke Secure Storage
      await storage.write(key: 'auth_token', value: token);

      // Simpan data user ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user["name"]);
      await prefs.setInt('user_id', user["id"]);
      await prefs.setString('user_role', role);

      if (role == "customer") {
        _showSuccessDialog();
      } else if (role == "vendor") {
        // Navigasi ke HomepageVendor dengan data vendor
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
      print("Error during login: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Login Berhasil",
            style: TextStyle(
              color: Colors.blue, // Warna teks judul diperindah
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Selamat datang di aplikasi rental motor.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Warna tombol diperindah
                foregroundColor: Colors.white,
              ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C567E), Color(0xFF1A5276)],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header with logo and welcome text
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.motorcycle,
                                size: 50,
                                color: Color(0xFF2C567E),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Sign in to continue to Rental Motor",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Login form card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C567E),
                              ),
                            ),
                            SizedBox(height: 30),

                            // Email field
                            _buildTextField(
                              controller: emailController,
                              label: "Email",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              isFilled: _isEmailFilled,
                            ),
                            SizedBox(height: 20),

                            // Password field
                            _buildTextField(
                              controller: passwordController,
                              label: "Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: _obscureText,
                              onToggleVisibility: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              isFilled: _isPasswordFilled,
                            ),
                            SizedBox(height: 30),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: (_isEmailFilled &&
                                        _isPasswordFilled &&
                                        !_isLoading)
                                    ? _handleLogin
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2C567E),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor:
                                      Color(0xFF2C567E).withOpacity(0.5),
                                ),
                                child: _isLoading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "Signing in...",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "SIGN IN",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Sign up option
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => WelcomePage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C567E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Error message
                            if (_errorMessage.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(
                                            color: Colors.red.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add this helper method for text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    bool isFilled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF2C567E).withOpacity(0.8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: Color(0xFF2C567E)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFF2C567E),
                  ),
                  onPressed: onToggleVisibility,
                )
              : (isFilled
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : null),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
