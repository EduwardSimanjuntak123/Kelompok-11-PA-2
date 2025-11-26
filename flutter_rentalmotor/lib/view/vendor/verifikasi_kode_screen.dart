import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_rentalmotor/view/vendor/kata_sandi_baru_screenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

final String baseUrl = ApiConfig.baseUrl;

Future<bool> requestVerifyOtp(String email, String otp) async {
  final url = '$baseUrl/verify-otp'; // Replace with your actual API URL
  final headers = {
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'email': email,
    'otp': otp,
  });

  print("Verifying OTP for email: $email with OTP: $otp");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['status'] ==
          'success'; // Adjust based on your API response structure
    } else {
      print("Failed to verify OTP: ${response.body}");
      return false;
    }
  } catch (e) {
    print('Error during OTP verification: $e');
    return false;
  }
}

class VerifikasiKodevScreen extends StatefulWidget {
  final String email;

  const VerifikasiKodevScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifikasiKodevScreen> createState() => _VerifikasiKodevScreenState();
}

class _VerifikasiKodevScreenState extends State<VerifikasiKodevScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _remainingSeconds = 29;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Auto-focus ke kolom berikutnya jika diisi
    for (int i = 0; i < 5; i++) {
      _codeControllers[i].addListener(() {
        if (_codeControllers[i].text.length == 1) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _formatTime(int seconds) {
    return '00:${seconds.toString().padLeft(2, '0')}';
  }

  void _verifyCode() async {
    String code = _codeControllers.map((c) => c.text).join();
    if (code.length == 6) {
      bool isVerified = await requestVerifyOtp(widget.email, code);
      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KataSandiBaruScreenv(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode OTP salah')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silahkan masukkan kode 6 digit')),
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Verifikasi Kode",
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

            // Judul Halaman
            const Text(
              "Verifikasi Alamat Email",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Teks Informasi Email
            Text(
              "Email verifikasi dikirim ke: ${widget.email}",
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Kotak Input Kode Verifikasi
// Kotak Input Kode Verifikasi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Expanded(
                  // Use Expanded to make the TextFields flexible
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        } else if (value.isNotEmpty && index == 5) {
                          _verifyCode();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5276),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Konfirmasi Kode",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Timer & Tombol Kirim Ulang Kode
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _remainingSeconds == 0
                      ? () {
                          setState(() {
                            _remainingSeconds = 29;
                          });
                          _startTimer();
                        }
                      : null,
                  child: Text(
                    "Kirim ulang kode konfirmasi",
                    style: TextStyle(
                      color: _remainingSeconds == 0
                          ? const Color(0xFF1A5276)
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
