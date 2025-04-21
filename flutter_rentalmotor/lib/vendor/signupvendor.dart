import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/services/reg_vendor_api.dart';
import 'package:flutter_rentalmotor/user/registrasi/otp_verification.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _shopDescriptionController = TextEditingController();

  int? _selectedKecamatanId;
  List<Map<String, dynamic>> _kecamatanList = [];

  XFile? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKecamatan();
  }

  Future<void> _fetchKecamatan() async {
    final kecamatans = await fetchKecamatan();
    if (kecamatans != null) {
      setState(() {
        _kecamatanList = kecamatans;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate() || _profileImage == null || _selectedKecamatanId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lengkapi semua data dan pilih gambar profil.')),
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
  // Ambil email dari controller dan arahkan ke halaman OTP
  final email = _emailController.text.trim();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => OTPVerificationScreen(email: email),
    ),
  );
} else {
    // Menampilkan pesan error sesuai respons dari backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Vendor'),
        backgroundColor: const Color(0xFF1A5276),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Nama Lengkap'),
              _buildTextField(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
              _buildTextField(_passwordController, 'Password', obscureText: true),
              _buildTextField(_phoneController, 'No. Telepon', keyboardType: TextInputType.phone),
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
                onChanged: (value) => setState(() => _selectedKecamatanId = value),
                validator: (value) => value == null ? 'Pilih kecamatan' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _profileImage != null ? FileImage(File(_profileImage!.path)) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
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
        validator: (value) => value == null || value.isEmpty ? 'Tidak boleh kosong' : null,
      ),
    );
  }
}
