import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/homepagevendor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/api_service.dart';
import 'package:flutter_rentalmotor/welcome.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isEmailFilled = false;
  bool _isPasswordFilled = false;
  bool _isLoading = false;
  String _errorMessage = "";

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);

    // Inisialisasi controller animasi
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    // Konfigurasi animasi slide
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    // Konfigurasi animasi fade
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Mulai animasi ketika layar dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          _errorMessage = "Akses ditolak! Peran tidak dikenali.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Terjadi kesalahan saat login. Silakan coba lagi nanti.";
        _isLoading = false;
      });
      print("Error selama login: $e");
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
              color: Colors.blue,
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
                backgroundColor: Colors.blue,
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
    return WillPopScope(
      onWillPop: () async {
        // Navigasi ke HomePageUser ketika tombol kembali ditekan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePageUser()),
        );
        return false; // Mencegah perilaku default tombol kembali
      },
      child: Scaffold(
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
            child: Column(
              children: [
                // Header dengan logo dan teks selamat datang - Animasi
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
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
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Text(
                                "Selamat Datang Kembali!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Masuk untuk melanjutkan ke Rental Motor",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form login card - Animasi
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
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
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C567E),
                                ),
                              ),
                              SizedBox(height: 30),

                              // Field email
                              _buildTextField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isFilled: _isEmailFilled,
                              ),
                              SizedBox(height: 20),

                              // Field password
                              _buildTextField(
                                controller: passwordController,
                                label: "Kata Sandi",
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

                              // Tombol masuk
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
                                    disabledBackgroundColor:
                                        Colors.grey.shade300,
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
                                              "Sedang masuk...",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          "MASUK",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Opsi daftar
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Belum punya akun? ",
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
                                        "Daftar",
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

                              // Pesan error
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
