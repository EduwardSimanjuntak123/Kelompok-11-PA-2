import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/view/user/registrasi/otp_verification.dart';
import 'package:flutter_rentalmotor/services/autentifikasi/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SignUpVendorScreen extends StatefulWidget {
  const SignUpVendorScreen({Key? key}) : super(key: key);

  @override
  _SignUpVendorScreenState createState() => _SignUpVendorScreenState();
}

class _SignUpVendorScreenState extends State<SignUpVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopDescriptionController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  File? _profileImage;
  bool _isLoading = false;
  int? _selectedKecamatanId;
  DateTime? _selectedDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  List<Map<String, dynamic>> _kecamatanList = [];

  final Color primaryColor = const Color(0xFF225378);
  final Color accentColor = const Color(0xFF1695A3);
  final Color lightColor = const Color(0xFFACF0F2);
  final Color backgroundColor = const Color(0xFFF3FFE2);
  final Color darkTextColor = const Color(0xFF0A0A0A);

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  Future<void> _fetchKecamatan() async {
    final String baseUrl = '${ApiConfig.baseUrl}';

    try {
      final response = await http.get(Uri.parse('$baseUrl/kecamatan'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _kecamatanList = List<Map<String, dynamic>>.from(
            data.map((item) => {
                  'id': item['id_kecamatan'],
                  'name': item['nama_kecamatan'],
                }),
          );
        });
      } else {
        throw Exception('Gagal memuat kecamatan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error mengambil data kecamatan: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: darkTextColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Check if image is uploaded
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil wajib diunggah'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if date of birth is selected
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal lahir wajib diisi'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if kecamatan is selected
      if (_selectedKecamatanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kecamatan terlebih dahulu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Format date of birth as YYYY-MM-DD string
      String formattedBirthDate =
          DateFormat('yyyy-MM-dd').format(_selectedDate!);

      AuthService authService = AuthService();
      final response = await authService.registerVendor(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        shopName: _shopNameController.text.trim(),
        shopAddress: _shopAddressController.text.trim(),
        shopDescription: _shopDescriptionController.text.trim(),
        kecamatanId: _selectedKecamatanId!,
        birthDate:
            formattedBirthDate, // Use birthDate parameter name to match the method signature
        profileImage: _profileImage,
      );

      setState(() {
        _isLoading = false;
      });

      if (response["success"]) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response["message"] ?? "Pendaftaran gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Vendor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lightColor.withOpacity(0.2), backgroundColor],
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
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor.withOpacity(0.8), primaryColor],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Vendor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lengkapi data untuk mendaftarkan toko Anda',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
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
                              color: accentColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: lightColor,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          size: 40, color: primaryColor),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Foto Profil',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w500,
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
                                color: accentColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
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

                // Informasi Pribadi
                _buildSectionCard(
                  icon: Icons.person,
                  title: 'Informasi Pribadi',
                  children: [
                    _buildEnhancedTextField(
                        _nameController, 'Nama Lengkap', Icons.person),
                    _buildEnhancedTextField(
                        _emailController, 'Email', Icons.email,
                        keyboardType: TextInputType.emailAddress),

                    // Password field with visibility toggle
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Wajib diisi'
                            : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),

                    // Confirm Password field with visibility toggle
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Wajib diisi';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon:
                              Icon(Icons.lock_outline, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          labelText: 'Konfirmasi Password',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),

                    _buildEnhancedTextField(
                        _phoneController, 'No. Telepon', Icons.phone,
                        keyboardType: TextInputType.phone),

                    // Date of Birth field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _birthDateController,
                            validator: (value) => _selectedDate == null
                                ? 'Tanggal lahir wajib diisi'
                                : null,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: primaryColor),
                              labelText: 'Tanggal Lahir',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Informasi Toko
                _buildSectionCard(
                  icon: Icons.store,
                  title: 'Informasi Toko',
                  children: [
                    _buildEnhancedTextField(
                        _shopNameController, 'Nama Toko', Icons.store),
                    _buildEnhancedTextField(_shopAddressController,
                        'Alamat Toko', Icons.location_on),
                    _buildEnhancedTextField(_shopDescriptionController,
                        'Deskripsi Toko', Icons.description),
                    const SizedBox(height: 16),

                    // Dropdown kecamatan
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.white,
                      ),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Pilih Kecamatan',
                          labelStyle:
                              TextStyle(color: darkTextColor.withOpacity(0.6)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          prefixIcon:
                              Icon(Icons.location_city, color: primaryColor),
                        ),
                        value: _selectedKecamatanId,
                        items: _kecamatanList.map((kecamatan) {
                          return DropdownMenuItem<int>(
                            value: kecamatan['id'],
                            child: Text(kecamatan['name'],
                                style: TextStyle(color: darkTextColor)),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedKecamatanId = value),
                        validator: (value) =>
                            value == null ? 'Pilih kecamatan' : null,
                        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: TextStyle(color: darkTextColor),
                      ),
                    ),
                  ],
                ),

                // Tombol Daftar
                Container(
                  width: double.infinity,
                  height: 55,
                  margin: const EdgeInsets.only(top: 10, bottom: 20),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                      shadowColor: primaryColor.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
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
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          )
                        : const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
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

  Widget _buildSectionCard(
      {required IconData icon,
      required String title,
      required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField(
      TextEditingController controller, String label, IconData icon,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryColor),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }
}
