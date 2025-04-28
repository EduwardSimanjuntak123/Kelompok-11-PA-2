import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/user/registrasi/otp_verification.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/auth_service.dart';

class SignUpCustomer extends StatefulWidget {
  const SignUpCustomer({Key? key}) : super(key: key);

  @override
  _SignUpCustomerState createState() => _SignUpCustomerState();
}

class _SignUpCustomerState extends State<SignUpCustomer> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _profileImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please complete all fields and select profile image')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password and confirmation do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.registerCustomer(
        name: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate: _birthDateController.text.trim(),
        profileImage: _profileImage,
      );

      if (response["success"]) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OTPVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggle,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _birthDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Tanggal Lahir',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectBirthDate,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Pilih tanggal lahir" : null,
      ),
    );
  }

  Widget _buildSignInOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Sudah punya akun? "),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen())),
          child: const Text(
            "Sign in",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Daftar Pelanggan',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_fullNameController, 'Nama Lengkap'),
              _buildTextField(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              _buildPasswordField(
                  _passwordController, 'Kata Sandi', _obscurePassword, () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              _buildPasswordField(_confirmPasswordController,
                  'Konfirmasi Kata Sandi', _obscureConfirmPassword, () {
                setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword);
              }),
              _buildTextField(_phoneController, 'Nomor Telepon',
                  keyboardType: TextInputType.phone),
              _buildTextField(_addressController, 'Alamat'),
              _buildDateField(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt,
                          size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5276),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSignInOption(context),
            ],
          ),
        ),
      ),
    );
  }
}
