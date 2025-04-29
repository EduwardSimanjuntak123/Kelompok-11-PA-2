import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD
=======
import 'package:flutter_rentalmotor/services/autentifikasi/reg_vendor_api.dart';
import 'package:flutter_rentalmotor/user/registrasi/otp_verification.dart';
import 'package:flutter_rentalmotor/signin.dart';
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
=======

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopDescriptionController =
      TextEditingController();

  int? _selectedKecamatanId;
  List<Map<String, dynamic>> _kecamatanList = [];
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e

  XFile? _profileImage;
  bool _isLoading = false;
  int? _selectedKecamatanId;

  // Dummy kecamatan list
  final List<Map<String, dynamic>> _kecamatanList = [
    {'id': 1, 'name': 'Baiturrahman'},
    {'id': 2, 'name': 'Banda Raya'},
    {'id': 3, 'name': 'Jaya Baru'},
    {'id': 4, 'name': 'Kuta Alam'},
    {'id': 5, 'name': 'Meuraxa'},
    {'id': 6, 'name': 'Syiah Kuala'},
    {'id': 7, 'name': 'Ulee Kareng'},
    {'id': 8, 'name': 'Lueng Bata'},
    {'id': 9, 'name': 'Kuta Raja'},
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate registration process
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isLoading = false;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran Berhasil!')),
      );
    }
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: const Text(
    'Daftar Vendor',
    style: TextStyle(
      color: Colors.white, // Ubah warna teks di sini
    ),
  ),
  backgroundColor: const Color(0xFF1A5276),
  elevation: 0,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
  ),
),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF1A5276), const Color(0xFF2980B9)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.store, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Informasi Vendor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Lengkapi data untuk mendaftarkan toko Anda',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Profile image section
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1A5276),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                            child: _profileImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt, size: 40, color: Color(0xFF1A5276)),
                                      const SizedBox(height: 5),
                                      const Text(
                                        'Foto Profil',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF1A5276),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'Tap untuk memilih',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF1A5276),
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
                      if (_profileImage != null)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A5276),
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
                const SizedBox(height: 24),
                
                // Personal Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: const Color(0xFF1A5276)),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Pribadi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A5276),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedTextField(_nameController, 'Nama Lengkap', Icons.person_outline),
                      _buildEnhancedTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                      _buildEnhancedTextField(_passwordController, 'Password', Icons.lock_outline, obscureText: true),
                      _buildEnhancedTextField(_phoneController, 'No. Telepon', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                
                // Shop Information Section
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.store, color: const Color(0xFF1A5276)),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Toko',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A5276),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedTextField(_shopNameController, 'Nama Toko', Icons.storefront),
                      _buildEnhancedTextField(_shopAddressController, 'Alamat Toko', Icons.location_on_outlined),
                      _buildEnhancedTextField(_shopDescriptionController, 'Deskripsi Toko', Icons.description_outlined),
                      const SizedBox(height: 16),
                      
                      // Kecamatan Dropdown
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Pilih Kecamatan',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            prefixIcon: Icon(Icons.location_city, color: const Color(0xFF1A5276)),
                          ),
                          value: _selectedKecamatanId,
                          items: _kecamatanList.map((kecamatan) {
                            return DropdownMenuItem<int>(
                              value: kecamatan['id'],
                              child: Text(kecamatan['name']),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedKecamatanId = value),
                          validator: (value) => value == null ? 'Pilih kecamatan' : null,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1A5276)),
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Register Button
                Container(
                  width: double.infinity,
                  height: 55,
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A5276),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: const Color(0xFF1A5276).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Mendaftar...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          )
                        : const Text(
                            'Daftar Sekarang',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:Colors.white),
                          ),
                  ),
                ),
              ],
            ),
=======
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate() ||
        _profileImage == null ||
        _selectedKecamatanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lengkapi semua data dan pilih gambar profil.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'phone': _phoneController.text.trim(),
      'shop_name': _shopNameController.text.trim(),
      'shop_address': _shopAddressController.text.trim(),
      'shop_description': _shopDescriptionController.text.trim(),
      'id_kecamatan': _selectedKecamatanId.toString(),
    };

    final errorMessage = await registerVendor(data, _profileImage!);

    setState(() => _isLoading = false);

    if (errorMessage == 'success') {
      final email = _emailController.text.trim();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A5276),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Daftar Vendor',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Nama Lengkap'),
              _buildTextField(_emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              _buildTextField(_passwordController, 'Password',
                  obscureText: true),
              _buildTextField(_phoneController, 'No. Telepon',
                  keyboardType: TextInputType.phone),
              _buildTextField(_shopNameController, 'Nama Toko'),
              _buildTextField(_shopAddressController, 'Alamat Toko'),
              _buildTextField(_shopDescriptionController, 'Deskripsi Toko'),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Kecamatan',
                  border: OutlineInputBorder(),
                ),
                value: _selectedKecamatanId,
                items: _kecamatanList.map((kecamatan) {
                  return DropdownMenuItem<int>(
                    value: kecamatan['id'],
                    child: Text(kecamatan['name']),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedKecamatanId = value),
                validator: (value) => value == null ? 'Pilih kecamatan' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null
                        ? FileImage(File(_profileImage!.path))
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Sudah punya akun? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
  // Add this new method for enhanced text fields
  Widget _buildEnhancedTextField(TextEditingController controller, String label, IconData icon,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
=======
  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
>>>>>>> d814fc8dd728d951339a11020384023e1d60a65e
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1A5276)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A5276), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }
}