import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/auth_service.dart';
import 'package:flutter_rentalmotor/signin.dart';

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

  @override
  void initState() {
    super.initState();

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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _cancelRegistration() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Registrasi?"),
        content: const Text(
            "Apakah Anda yakin ingin membatalkan registrasi? Data yang belum diverifikasi akan dihapus."),
        actions: [
          TextButton(
            child: const Text("Tidak"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text("Ya"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
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
          const SnackBar(content: Text("Registrasi dibatalkan.")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Gagal membatalkan.")),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _cancelRegistration,
        ),
        title: const Text(
          "Verifikasi OTP",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Masukkan Kode OTP",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "Kode OTP telah dikirim ke: ${widget.email}",
              style: const TextStyle(color: Colors.black54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
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
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              ),
            ),
            const SizedBox(height: 24),
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
                    : const Text("Verifikasi Kode",
                        style: TextStyle(fontSize: 16)),
              ),
            ),
            TextButton(
              onPressed: _isLoading ? null : _cancelRegistration,
              child: const Text(
                "Batalkan Registrasi",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
