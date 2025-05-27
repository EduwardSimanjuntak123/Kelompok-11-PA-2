import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/homepagevendor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/api_service.dart';
import 'package:flutter_rentalmotor/welcome.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart' show TestWidgetsFlutterBinding;

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

  // Add validation error messages
  String? _emailError;
  String? _passwordError;

  // Add validation status
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  // Add form key for validation
  final _formKey = GlobalKey<FormState>();

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isEmailFilled = emailController.text.isNotEmpty;
      _isPasswordFilled = passwordController.text.isNotEmpty;

      // Validate email and password as user types
      if (_isEmailFilled) {
        _validateEmail(emailController.text);
      } else {
        _emailError = null;
        _isEmailValid = false;
      }

      if (_isPasswordFilled) {
        _validatePassword(passwordController.text);
      } else {
        _passwordError = null;
        _isPasswordValid = false;
      }
    });
  }

  // Dismiss keyboard when user finishes typing
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // Validate email with visual feedback
  void _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty) {
      setState(() {
        _emailError = "Email tidak boleh kosong";
        _isEmailValid = false;
      });
    } else if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _emailError = "Format email tidak valid";
        _isEmailValid = false;
      });
    } else {
      setState(() {
        _emailError = null;
        _isEmailValid = true;
      });
    }
  }

  // Validate password with visual feedback
  void _validatePassword(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password tidak boleh kosong";
        _isPasswordValid = false;
      });
    } else if (password.length < 6) {
      setState(() {
        _passwordError = "Password minimal 6 karakter";
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordError = null;
        _isPasswordValid = true;
      });
    }
  }

  // Validate form before submission
  bool _validateForm() {
    _validateEmail(emailController.text);
    _validatePassword(passwordController.text);

    return _isEmailValid && _isPasswordValid;
  }

  Future<void> _handleLogin() async {
    // Dismiss keyboard first
    _dismissKeyboard();

    // Validate form first
    if (!_validateForm()) {
      return;
    }

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
        _showVendorSuccessDialog();
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
    print('[DEBUG] _showSuccessDialog dipanggil');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Tambahkan key pada dialog untuk memudahkan pengujian
        return Dialog(
          key: const Key('successDialog'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Login Berhasil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C567E),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Selamat Datang di Aplikasi Motorent.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  key: const Key('lanjutkanButton'),
                  onPressed: () {
                    print("Tombol lanjutkan ditekan");

                    final binding = WidgetsBinding.instance;
                    final bool inWidgetTest =
                        binding is TestWidgetsFlutterBinding;
                    final bool inIntegrationTest =
                        binding is IntegrationTestWidgetsFlutterBinding;

                    if (inWidgetTest || inIntegrationTest) {
                      print("Berjalan dalam mode pengujian/integration test");

                      // Pop + navigasi tanpa animasi
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => HomePageUser(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      // Mode release/debug normal
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => HomePageUser()),
                      );
                    }
                  },
                  child: Text(
                    "Lanjutkan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVendorSuccessDialog() {
    print('[DEBUG] _showVendorSuccessDialog dipanggil');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          key: const Key('vendorSuccessDialog'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  "Login Berhasil",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C567E),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Selamat Datang di Halaman Vendor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  key: const Key('lanjutkanVendorButton'),
                  onPressed: () {
                    print("Tombol lanjutkan vendor ditekan");

                    final binding = WidgetsBinding.instance;
                    final bool inWidgetTest =
                        binding is TestWidgetsFlutterBinding;
                    final bool inIntegrationTest =
                        binding is IntegrationTestWidgetsFlutterBinding;

                    if (inWidgetTest || inIntegrationTest) {
                      print("Berjalan dalam mode pengujian/integration test");

                      // Pop + navigasi tanpa animasi
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => HomepageVendor(),
                          transitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      // Mode release/debug normal
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => HomepageVendor()),
                      );
                    }
                  },
                  child: Text(
                    "Lanjutkan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      child: GestureDetector(
        // Add GestureDetector to dismiss keyboard when tapping outside
        onTap: _dismissKeyboard,
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
                            child: Form(
                              key: _formKey,
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
                                    isValid: _isEmailValid,
                                    errorText: _emailError,
                                    textInputAction: TextInputAction.next,
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
                                    isValid: _isPasswordValid,
                                    errorText: _passwordError,
                                    textInputAction: TextInputAction.done,
                                  ),
                                  SizedBox(height: 30),

                                  // Tombol masuk
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton(
                                      key: Key(
                                          'loginButton'), // Menggunakan Key bukan ValueKey
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
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                                  child:
                                                      CircularProgressIndicator(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                builder: (context) =>
                                                    WelcomePage(),
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
                                        border: Border.all(
                                            color: Colors.red.shade200),
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
                  ),
                ],
              ),
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
    bool isValid = false,
    String? errorText,
    TextInputAction? textInputAction,
  }) {
    // Tentukan warna border berdasarkan validasi/error
    Color borderColor;
    if (errorText != null) {
      borderColor = Colors.red;
    } else if (isFilled && isValid) {
      borderColor = Color(0xFF2C567E); // warna biru
    } else {
      borderColor = Colors.grey.shade300; // default abu-abu
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: Key(label == "Email"
              ? 'emailField'
              : label == "Kata Sandi"
                  ? 'passwordField'
                  : ''),
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onEditingComplete: isPassword ? _dismissKeyboard : null,
          onSubmitted: (_) => _dismissKeyboard(),
          onChanged: (value) {
            if (isPassword) {
              _validatePassword(value);
            } else {
              _validateEmail(value);
            }
          },
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(
              color: errorText != null
                  ? Colors.red
                  : isFilled && isValid
                      ? Color(0xFF2C567E).withOpacity(0.8)
                      : Color(0xFF2C567E).withOpacity(0.8),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: errorText != null
                  ? Colors.red
                  : isFilled && isValid
                      ? Color(0xFF2C567E)
                      : Color(0xFF2C567E),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFF2C567E),
                    ),
                    onPressed: onToggleVisibility,
                  )
                : (isFilled && isValid
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: borderColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.fromLTRB(16, 20, 16, 20),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 8),
            child: Text(
              errorText,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
