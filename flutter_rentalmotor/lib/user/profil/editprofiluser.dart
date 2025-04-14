import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p; // Aliasing import
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';

class EditProfileuser extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String profileImage;

  const EditProfileuser({
    Key? key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<EditProfileuser> createState() => _EditProfileuserState();
}

class _EditProfileuserState extends State<EditProfileuser> {
  int _selectedIndex = 0;

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color accentBlue = Color(0xFF64B5F6);

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Flutter Secure Storage untuk mengambil token
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    addressController = TextEditingController(text: widget.address);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    // Ambil token dari Flutter Secure Storage
    String? token = await storage.read(key: "auth_token");

    var uri = Uri.parse("${ApiConfig.baseUrl}/customer/profile");

    // Buat multipart request dengan method PUT
    var request = http.MultipartRequest("PUT", uri);

    // Sertakan header Authorization jika token ada
    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    // Tambahkan field yang akan dikirim sebagai form data
    request.fields["name"] = nameController.text;
    request.fields["address"] = addressController.text;

    // Jika ada foto profil baru, tambahkan ke multipart request
    if (_pickedImage != null) {
      String fileName = p.basename(_pickedImage!.path);
      final mimeTypeData =
          lookupMimeType(_pickedImage!.path, headerBytes: [0xFF, 0xD8])
              ?.split('/');
      if (mimeTypeData != null && mimeTypeData.length == 2) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _pickedImage!.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
          filename: fileName,
        ));
      }
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memperbarui profil"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePageUser()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => DetailPesanan()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Akun()));
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 60,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Profile Updated Successfully",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: primaryBlue,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Your profile information has been updated successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3E8EDE), primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Center(
                        child: Text(
                          "Back to Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      {bool readOnly = false, bool isMultiline = false, IconData? icon}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: primaryBlue),
                  ),
                  SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              maxLines: isMultiline ? 3 : 1,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: readOnly ? Colors.grey[700] : Colors.black,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter ${label.toLowerCase()}",
                hintStyle: TextStyle(color: Colors.grey[400]),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: primaryBlue, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Edit Profile",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          _isLoading
              ? Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.check, color: primaryBlue, size: 20),
                  ),
                  onPressed: _updateProfile,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header with Image - Fixed height to prevent overflow
            Container(
              height: 200, // Adjusted height to prevent overflow
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBlue, Color(0xFF3E8EDE)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          // Reduced size of profile picture container
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _pickedImage != null
                                  ? Image.file(
                                      _pickedImage!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    )
                                  : (widget.profileImage.isNotEmpty
                                      ? Image.network(
                                          widget.profileImage,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              "assets/default_avatar.png",
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          "assets/default_avatar.png",
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryBlue, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: primaryBlue,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Edit Your Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tap on the camera icon to change your photo",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Form Fields
            Container(
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildProfileField("Nama", nameController, icon: Icons.person),
                  _buildProfileField("Email", emailController, readOnly: true, icon: Icons.email),
                  _buildProfileField("No. Telepon", phoneController, readOnly: true, icon: Icons.phone),
                  _buildProfileField("Alamat", addressController, isMultiline: true, icon: Icons.location_on),
                  
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3E8EDE), primaryBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _updateProfile,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white, size: 18),
                              SizedBox(width: 10),
                              Text(
                                _isLoading ? "Saving..." : "Save Changes",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add padding at the bottom to prevent content from being hidden by the navigation bar
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Beranda"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: "Pesanan"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Akun"),
            ],
          ),
        ),
      ),
    );
  }
}
