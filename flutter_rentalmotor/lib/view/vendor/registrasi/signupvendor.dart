// lib/vendor/signupvendor.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/view/user/registrasi/otp_verification.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ─── Controllers & State ────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _shopDescController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> _kecamatanList = [];
  String? _selectedKecamatan;
  XFile? _profileImage;
  bool _isLoading = false;

  final Color _primaryBlue = const Color(0xFF1A5276);

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  // ─── Fetch kecamatan ─────────────────────────────────────────────
  Future<void> _fetchKecamatan() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/kecamatan');
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final List data = json.decode(resp.body);
        setState(() {
          _kecamatanList = data.map<Map<String, dynamic>>((item) {
            return {
              'id': item['id_kecamatan'],
              'name': (item['nama_kecamatan'] ?? '').toString().trim(),
            };
          }).toList();
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat kecamatan')),
      );
    }
  }

  // ─── Date picker ──────────────────────────────────────────────────
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // ─── Pick image ───────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) setState(() => _profileImage = p);
  }

  // ─── Register vendor ────────────────────────────────────────────
  Future<bool> _registerVendor(Map<String, String> fields, File? img) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/vendor/register');
    final req = http.MultipartRequest('POST', uri)..fields.addAll(fields);

    if (img != null) {
      req.files
          .add(await http.MultipartFile.fromPath('profile_image', img.path));
    }

    final resp = await req.send();
    return resp.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ─── Header dengan gradient ────────────────────────────────────
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              'Daftar Vendor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ─── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Foto Profil
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _profileImage != null
                              ? FileImage(File(_profileImage!.path))
                              : null,
                          child: _profileImage == null
                              ? Icon(Icons.camera_alt,
                                  size: 40, color: _primaryBlue)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama Lengkap
                    _buildField(_nameController, 'Nama Lengkap', Icons.person),
                    // Email
                    _buildField(_emailController, 'Email', Icons.email,
                        keyboardType: TextInputType.emailAddress),
                    // Password
                    _buildField(_passwordController, 'Password', Icons.lock,
                        obscureText: true),
                    // Telepon
                    _buildField(_phoneController, 'No. Telepon', Icons.phone,
                        keyboardType: TextInputType.phone),
                    // Tanggal Lahir (date picker)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Tanggal Lahir',
                          prefixIcon:
                              Icon(Icons.calendar_today, color: _primaryBlue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onTap: _pickDate,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Pilih tanggal lahir'
                            : null,
                      ),
                    ),
                    // Alamat Lengkap
                    _buildField(
                        _addressController, 'Alamat Lengkap', Icons.home,
                        maxLines: 2),

                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Nama Toko
                    _buildField(_shopNameController, 'Nama Toko', Icons.store),
                    // Alamat Toko
                    _buildField(_shopAddressController, 'Alamat Toko',
                        Icons.location_on),
                    // Deskripsi Toko
                    _buildField(_shopDescController, 'Deskripsi Toko',
                        Icons.description,
                        maxLines: 3),

                    // Dropdown Kecamatan
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: DropdownButtonFormField<String>(
                        value: _selectedKecamatan,
                        hint: const Text('Pilih Kecamatan'),
                        items: _kecamatanList.map((e) {
                          return DropdownMenuItem<String>(
                            value: e['name'],
                            child: Text(e['name']),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setState(() => _selectedKecamatan = v),
                        decoration: InputDecoration(
                          labelText: 'Pilih Kecamatan',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        validator: (v) => v == null ? 'Pilih kecamatan' : null,
                      ),
                    ),

                    // Tombol Daftar
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Daftar Sekarang',
                              style: TextStyle(fontSize: 16)),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => _isLoading = true);

                              // cari id_kecamatan
                              final kec = _kecamatanList
                                  .firstWhere(
                                      (e) => e['name'] == _selectedKecamatan,
                                      orElse: () => {'id': ''})['id']
                                  .toString();

                              // fields
                              final fields = {
                                'name': _nameController.text,
                                'email': _emailController.text,
                                'password': _passwordController.text,
                                'phone': _phoneController.text,
                                'birth_date': _birthDateController.text,
                                'address': _addressController.text,
                                'shop_name': _shopNameController.text,
                                'shop_address': _shopAddressController.text,
                                'shop_description': _shopDescController.text,
                                'id_kecamatan': kec,
                              };

                              final ok = await _registerVendor(
                                fields,
                                _profileImage != null
                                    ? File(_profileImage!.path)
                                    : null,
                              );

                              setState(() => _isLoading = false);

                              if (ok) {
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
                                  const SnackBar(
                                      content: Text('Registrasi gagal')),
                                );
                              }
                            },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper untuk TextFormField yang distyling
  Widget _buildField(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Field tidak boleh kosong' : null,
      ),
    );
  }
}

// Extension helper supaya kita bisa pakai .let() layaknya Kotlin
extension Let<T> on T {
  R let<R>(R Function(T) op) => op(this);
}
