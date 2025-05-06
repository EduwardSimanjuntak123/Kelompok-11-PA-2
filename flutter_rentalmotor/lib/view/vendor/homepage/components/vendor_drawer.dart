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

class VendorDrawer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A567D),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            padding:
                const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: vendorImagePath != null
                            ? NetworkImage(fullImageUrl)
                            : null,
                        backgroundColor: Colors.white,
                        child: vendorImagePath == null
                            ? const Icon(Icons.person,
                                size: 55, color: Color(0xFF1A567D))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName ?? 'Nama Bisnis',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vendorEmail ?? 'Email belum tersedia',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "ID: ${vendorId ?? '-'}",
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vendorAddress ?? 'Alamat belum tersedia',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: "Dashboard",
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: "Edit Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    ).then((_) => onProfileUpdated());
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: "Edit Informasi Toko",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Edittokovendor()),
                    ).then((_) => onProfileUpdated());
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.motorcycle,
                  title: "Kelola Motor",
                  onTap: () {
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
                  onTap: () {
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
                  icon: Icons.list_alt,
                  title: "Daftar Transaksi",
                  onTap: () {
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UlasanVendorScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.chat,
                  title: "Chat",
                  onTap: () {
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
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotifikasiPagev(userId: vendorId!),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.lock,
                  title: "Lupa Kata Sandi",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LupaKataSandivScreen(email: vendorEmail ?? '')),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.exit_to_app,
                  title: "Logout",
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              "© 2025 Rental Motor Kel 11",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
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
    return ListTile(
      leading:
          Icon(icon, color: isActive ? const Color(0xFF1A567D) : iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF1A567D) : textColor,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? const Color(0xFFE3F2FD) : null,
      onTap: onTap,
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
            children: const [
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

                onLogout();
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
