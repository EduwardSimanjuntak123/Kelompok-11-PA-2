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
<<<<<<< HEAD
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade800),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        "Join our community and start renting motorcycles",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Profile image picker
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue.shade700, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => _pickImage(ImageSource.gallery),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _image != null
                                    ? FileImage(_image!)
                                    : const AssetImage("assets/default_avatar.png") as ImageProvider,
                                child: _image == null
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.camera_alt,
                                            size: 30,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Add Photo",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.9),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'Tap untuk memilih',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          if (_image != null)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _pickImage(ImageSource.gallery),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Form fields in a card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade700.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.person, color: Colors.blue.shade700, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Personal Information",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildEnhancedTextField('Full Name', _fullNameController, Icons.person_outline),
                          _buildEnhancedTextField('Address', _addressController, Icons.home_outlined),
                          _buildEnhancedTextField('Phone Number', _phoneController, Icons.phone_outlined, TextInputType.phone),
                          _buildEnhancedTextField('Email', _emailController, Icons.email_outlined, TextInputType.emailAddress),
                          _buildEnhancedDateField('Date of Birth', _dateOfBirthController),
                          _buildEnhancedPasswordField('Password', _passwordController, _obscurePassword, () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          }),
                          _buildEnhancedPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirmPassword, () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Register button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isFormValid && !_isLoading ? _registerUser : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.blue.withOpacity(0.5),
                        ),
                        child: _isLoading
                            ? const SpinKitFadingCircle(color: Colors.white, size: 30.0)
                            : const Text(
                                "CREATE ACCOUNT",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sign in option
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context, MaterialPageRoute(builder: (context) => LoginScreen())),
                            child: Text(
                              "Sign in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
=======
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
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  // Add these enhanced field methods
  Widget _buildEnhancedTextField(String label, TextEditingController controller, IconData icon, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: keyboardType,
        validator: (value) => (value == null || value.isEmpty) ? 'Enter your $label' : null,
        onChanged: (value) => _checkFormValidity(),
      ),
    );
  }

  Widget _buildEnhancedDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
          suffixIcon: IconButton(
            icon: Icon(Icons.event, color: Colors.blue.shade700),
            onPressed: () => _selectDate(context, controller),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  Widget _buildEnhancedPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.lock_outline, color: Colors.blue.shade700),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue.shade700,
            ),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Enter your $label' : null,
        onChanged: (value) => _checkFormValidity(),
      ),
    );
  }
}
=======
}
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e
