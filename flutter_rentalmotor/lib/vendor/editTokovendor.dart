// lib/pages/editprofilvendor.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/vendor/vendor_profile_service.dart';
import '../config/api_config.dart';

class Edittokovendor extends StatefulWidget {
  const Edittokovendor({super.key});

  @override
  State<Edittokovendor> createState() => _EdittokovendorState();
}

class _EdittokovendorState extends State<Edittokovendor> {
  final VendorService _vendorService = VendorService();
  TextEditingController shopNameController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? profileImageUrl;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    loadVendorProfile();
  }

  Future<void> loadVendorProfile() async {
    try {
      final profile = await _vendorService.getVendorProfile();
      if (profile != null) {
        setState(() {
          shopNameController.text = profile.shopName ?? '';
          districtController.text = profile.districtName ?? '';
          descriptionController.text = profile.shopDescription ?? '';
          addressController.text = profile.shopAddress ?? '';
          profileImageUrl = profile.profileImage != null
              ? '${ApiConfig.baseUrl}${profile.profileImage}'
              : null;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    try {
      await _vendorService.updateVendorProfile(
        shopName: shopNameController.text,
        phone: descriptionController.text,
        address: addressController.text,
        imageFile: selectedImage,
      );
      showSuccessDialog();
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle,
                  size: 80, color: Color(0xFF1976D2)),
              const SizedBox(height: 20),
              const Text('Berhasil!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              const SizedBox(height: 10),
              const Text('Profil berhasil diperbarui',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali', style: TextStyle(fontSize: 16)),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A567D),
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Usaha',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            decoration: const BoxDecoration(
                color: Color(0xFF1A567D),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Center(
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ]),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : (profileImageUrl != null
                            ? NetworkImage(profileImageUrl!)
                            : null) as ImageProvider?,
                    child: selectedImage == null && profileImageUrl == null
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF1A567D), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      spreadRadius: 1)
                                ]),
                            child: const Icon(Icons.camera_alt,
                                color: Color(0xFF1A567D), size: 24)))),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informasi Usaha',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A567D))),
                      const SizedBox(height: 20),
                      _buildProfileField(
                          'Nama Usaha', shopNameController, Icons.store),
                      _buildProfileField(
                          'Kecamatan', districtController, Icons.map),
                      _buildProfileField('Deskripsi Usaha',
                          descriptionController, Icons.description),
                      _buildProfileField(
                          'Alamat', addressController, Icons.location_on,
                          isMultiline: true),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white),
                            onPressed: showConfirmationDialog,
                            child: const Text('Simpan Perubahan',
                                style: TextStyle(fontSize: 16))),
                      ),
                    ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Konfirmasi',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            const Text('Apakah Anda yakin ingin menyimpan perubahan profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal',
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.of(context).pop(); // tutup dialog
              saveProfile(); // lanjut simpan profil
            },
            child: const Text('Ya, Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(
      String label, TextEditingController controller, IconData icon,
      {bool readOnly = false,
      bool isMultiline = false,
      bool showLock = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              if (showLock && readOnly) ...[
                const SizedBox(width: 6),
                Icon(Icons.lock, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('Tidak dapat diubah',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: readOnly ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: isMultiline ? 3 : 1,
              style: TextStyle(
                  color: readOnly ? Colors.grey.shade600 : Colors.black87),
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: const Color(0xFF1A567D)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
