import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/auth_service.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'dart:async';

class OTPVerificationScreen extends StatefulWidget {
  final String email;

  const OTPVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false;
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes in seconds
  final Color _themeColor = const Color(0xFF225378);

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto-focus ke input berikutnya jika diisi
    for (int i = 0; i < 5; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelRegistration() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Batalkan Registrasi?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Apakah Anda yakin ingin membatalkan registrasi? Data yang belum diverifikasi akan dihapus.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Tidak"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Ya"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldCancel == true) {
      setState(() => _isLoading = true);

      AuthService authService = AuthService();
      final response =
          await authService.cancelRegistration(email: widget.email);

      setState(() => _isLoading = false);

      if (response["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registrasi dibatalkan."),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Gagal membatalkan."),
            backgroundColor: _themeColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan 6 digit kode OTP")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();
    final response = await authService.verifyOTP(email: widget.email, otp: otp);

    setState(() {
      _isLoading = false;
    });

    if (response["success"]) {
      _timer?.cancel(); // Cancel the timer if verification is successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("OTP berhasil diverifikasi! Silakan login.")),
      );

      // Navigasi ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isVerySmallScreen = screenWidth < 300;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Verifikasi Kode',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: _themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _cancelRegistration,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isVerySmallScreen
                ? 12
                : isSmallScreen
                    ? 16
                    : 24,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Verifikasi Alamat Email",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isVerySmallScreen
                      ? 4
                      : isSmallScreen
                          ? 8
                          : 0,
                ),
                child: Text(
                  "Kode OTP telah dikirim ke: ${widget.email}",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: isVerySmallScreen ? 12 : 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Responsive OTP Input Fields
              LayoutBuilder(
                builder: (context, constraints) {
                  final boxSize = constraints.maxWidth / 8;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (index) => Container(
                        width: boxSize,
                        height: boxSize,
                        margin: EdgeInsets.symmetric(
                          horizontal: isVerySmallScreen ? 2 : 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: boxSize * 0.5,
                            fontWeight: FontWeight.bold,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            } else if (value.isNotEmpty && index == 5) {
                              _verifyOTP();
                            }
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _remainingSeconds == 0
                        ? () {
                            setState(() {
                              _remainingSeconds = 600;
                            });
                            _startTimer();
                          }
                        : null,
                    child: Text(
                      "Kirim ulang kode",
                      style: TextStyle(
                        fontSize: isVerySmallScreen ? 12 : 14,
                        color: _remainingSeconds == 0
                            ? const Color(0xFF1A5276)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5276),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Konfirmasi Kode",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              TextButton(
                onPressed: _isLoading ? null : _cancelRegistration,
                child: Text(
                  "Batalkan Registrasi",
                  style: TextStyle(
                    fontSize: isVerySmallScreen ? 12 : 14,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallScreen
                        ? 4
                        : isSmallScreen
                            ? 8
                            : 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: isVerySmallScreen ? 14 : 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Cek kolom spam jika tidak menemukan atau tidak menerima email verifikasi",
                        style: TextStyle(
                          fontSize: isVerySmallScreen ? 10 : 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
