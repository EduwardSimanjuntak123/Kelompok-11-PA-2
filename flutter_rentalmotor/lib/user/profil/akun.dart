import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/profil/editprofiluser.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/profil/lupakatasandi.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/services/customer/profile_api.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Akun extends StatefulWidget {
  final bool isGuest;
  const Akun({Key? key, this.isGuest = false}) : super(key: key);

  @override
  State<Akun> createState() => _AkunState();
}

class _AkunState extends State<Akun> {
  int _selectedIndex = 2;
  final Color primaryBlue = const Color(0xFF2C567E);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color accentBlue = const Color(0xFF64B5F6);

  String _userName = "Pengguna";
  String _userEmail = "user@example.com";
  String _userPhone = "08123456789";
  String _userAddress = "Alamat belum diatur";
  String _profileImageUrl = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: "auth_token");

    final response = await ProfileAPI().getCustomerProfile(token: token);
    setState(() {
      _isLoading = false;
    });

    if (response["success"]) {
      final user = response["data"];
      setState(() {
        _userName = user["name"] ?? _userName;
        _userEmail = user["email"] ?? _userEmail;
        _userPhone = user["phone"] ?? _userPhone;
        _userAddress = user["address"] ?? _userAddress;
        _profileImageUrl = user["profile_image"] ?? "";
      });
    } else {
      _showSessionExpiredDialog(context);
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailPesanan()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Akun(isGuest: widget.isGuest)),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    const storage = FlutterSecureStorage();
    await prefs.clear();
    await storage.deleteAll();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePageUser()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Konfirmasi Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: () async {
              Navigator.pop(context);
              _logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sesi Berakhir'),
        content: const Text('Sesi telah habis, silakan login kembali.'),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              const storage = FlutterSecureStorage();
              await storage.deleteAll();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingButton(
      IconData icon, String text, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          color: primaryBlue,
          displacement: 40.0,
          edgeOffset: 20.0,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: !_isLoading
              ? CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primaryBlue, const Color(0xFF1976D2)],
                            stops: [0.3, 1.0],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profil Saya',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.refresh,
                                        color: Colors.white, size: 24),
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(),
                                    onPressed: _fetchProfile,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        "Kelola informasi profil Anda",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 54,
                              backgroundColor: primaryBlue,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: _profileImageUrl.isNotEmpty
                                    ? NetworkImage(_profileImageUrl)
                                    : const AssetImage(
                                            "assets/default_avatar.png")
                                        as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
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
                                    color: primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.info_outline,
                                      color: primaryBlue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Informasi Pribadi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildInfoTile(Icons.email, 'Email', _userEmail),
                            _buildInfoTile(
                                Icons.phone, 'No Telepon', _userPhone),
                            _buildInfoTile(
                                Icons.location_on, 'Alamat', _userAddress),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
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
                                    color: primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.settings,
                                      color: primaryBlue, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Pengaturan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSettingButton(
                              Icons.edit,
                              'Edit Profil',
                              primaryBlue,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileuser(
                                      name: _userName,
                                      email: _userEmail,
                                      phone: _userPhone,
                                      address: _userAddress,
                                      profileImage: _profileImageUrl,
                                    ),
                                  ),
                                ).then((_) => _fetchProfile());
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildSettingButton(
                              Icons.lock,
                              'Lupa Kata Sandi',
                              accentBlue,
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LupaKataSandiScreen(
                                      email: _userEmail,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildSettingButton(
                              Icons.logout,
                              'Keluar',
                              Colors.red,
                              () {
                                _showLogoutDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(child: CircularProgressIndicator(color: primaryBlue)),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: widget.isGuest,
      ),
    );
  }
}