import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_api_service.dart';
import 'package:flutter_rentalmotor/view/vendor/lupakatasandiv.dart';
import 'package:flutter_rentalmotor/view/vendor/editprofilvendor.dart';
import 'package:flutter_rentalmotor/view/vendor/edittokovendor.dart';
import 'package:flutter_rentalmotor/view/vendor/chatvendor.dart';
import 'package:flutter_rentalmotor/view/vendor/kelolaMotor.dart';
import 'package:flutter_rentalmotor/view/vendor/data_transaksi.dart';
import 'package:flutter_rentalmotor/view/vendor/notifikasivendor.dart';
import 'package:flutter_rentalmotor/view/vendor/ulasanvendor.dart';
import 'package:flutter_rentalmotor/view/vendor/daftar_pesanan_screen.dart';

class VendorDrawer extends StatefulWidget {
  final String fullImageUrl;
  final int? vendorId;
  final String? businessName;
  final String? vendorAddress;
  final String? vendorEmail;
  final String? vendorImagePath;
  final VoidCallback onLogout;
  final VoidCallback onProfileUpdated;

  const VendorDrawer({
    Key? key,
    required this.fullImageUrl,
    required this.vendorId,
    required this.businessName,
    required this.vendorAddress,
    required this.vendorEmail,
    required this.vendorImagePath,
    required this.onLogout,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _VendorDrawerState createState() => _VendorDrawerState();
}

class _VendorDrawerState extends State<VendorDrawer>
    with SingleTickerProviderStateMixin {
  // Theme colors
  final Color primaryColor = const Color(0xFF225378);
  final Color accentColor = const Color(0xFF1695A3);
  final Color lightColor = const Color(0xFFACF0F2);
  final Color backgroundColor = const Color(0xFFF3FFE2);

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Currently selected menu item
  String _selectedMenu = 'Dashboard';

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              backgroundColor.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header section with profile info
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                  top: 50, bottom: 25, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Profile image with animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: widget.vendorImagePath != null
                                ? NetworkImage(widget.fullImageUrl)
                                : null,
                            backgroundColor: Colors.white,
                            child: widget.vendorImagePath == null
                                ? Icon(Icons.person,
                                    size: 55, color: primaryColor)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.businessName ?? 'Nama Bisnis',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vendorEmail ?? 'Email belum tersedia',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      size: 14, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text(
                                    "ID: ${widget.vendorId ?? '-'}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.vendorAddress ?? 'Alamat belum tersedia',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),

                  // Dashboard section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'DASHBOARD',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: "Dashboard",
                    isActive: _selectedMenu == 'Dashboard',
                    onTap: () {
                      setState(() => _selectedMenu = 'Dashboard');
                      Navigator.pop(context);
                    },
                  ),

                  // Profile section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'PROFIL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: "Edit Profile",
                    isActive: _selectedMenu == 'Edit Profile',
                    onTap: () {
                      setState(() => _selectedMenu = 'Edit Profile');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      ).then((_) => widget.onProfileUpdated());
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.store,
                    title: "Edit Informasi Toko",
                    isActive: _selectedMenu == 'Edit Informasi Toko',
                    onTap: () {
                      setState(() => _selectedMenu = 'Edit Informasi Toko');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Edittokovendor()),
                      ).then((_) => widget.onProfileUpdated());
                    },
                  ),

                  // Business section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'BISNIS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.motorcycle,
                    title: "Kelola Motor",
                    isActive: _selectedMenu == 'Kelola Motor',
                    onTap: () {
                      setState(() => _selectedMenu = 'Kelola Motor');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KelolaMotorScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.list_alt,
                    title: "Daftar Pesanan",
                    isActive: _selectedMenu == 'Daftar Pesanan',
                    onTap: () {
                      setState(() => _selectedMenu = 'Daftar Pesanan');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DaftarPesananVendorScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.receipt_long,
                    title: "Daftar Transaksi",
                    isActive: _selectedMenu == 'Daftar Transaksi',
                    onTap: () {
                      setState(() => _selectedMenu = 'Daftar Transaksi');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransactionReportScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star,
                    title: "Ulasan Pelanggan",
                    isActive: _selectedMenu == 'Ulasan Pelanggan',
                    onTap: () {
                      setState(() => _selectedMenu = 'Ulasan Pelanggan');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UlasanVendorScreen()),
                      );
                    },
                  ),

                  // Communication section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'KOMUNIKASI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.chat,
                    title: "Chat",
                    isActive: _selectedMenu == 'Chat',
                    onTap: () {
                      setState(() => _selectedMenu = 'Chat');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications,
                    title: "Notifikasi",
                    isActive: _selectedMenu == 'Notifikasi',
                    onTap: () {
                      setState(() => _selectedMenu = 'Notifikasi');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotifikasiPagev(userId: widget.vendorId!),
                        ),
                      );
                    },
                  ),

                  // Account section
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'AKUN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.lock,
                    title: "Lupa Kata Sandi",
                    isActive: _selectedMenu == 'Lupa Kata Sandi',
                    onTap: () {
                      setState(() => _selectedMenu = 'Lupa Kata Sandi');
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LupaKataSandiScreen(
                                email: widget.vendorEmail ?? '')),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.exit_to_app,
                    title: "Logout",
                    textColor: Colors.red,
                    iconColor: Colors.red,
                    isActive: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copyright, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    "2025 Rental Motor Kel 11",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    Color textColor = Colors.black87,
    Color iconColor = Colors.black87,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? primaryColor : iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? primaryColor : textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isActive ? primaryColor.withOpacity(0.05) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Konfirmasi Logout",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final apiService = VendorApiService();
                await apiService.logout();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );

                widget.onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
