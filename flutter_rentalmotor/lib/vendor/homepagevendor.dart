import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/home.dart';
import 'package:flutter_rentalmotor/vendor/lupakatasandiv.dart';
import 'package:flutter_rentalmotor/vendor/editprofilvendor.dart';
import 'package:flutter_rentalmotor/vendor/chatvendor.dart';
import 'package:flutter_rentalmotor/vendor/notifikasivendor.dart';
import 'package:flutter_rentalmotor/vendor/ulasanvendor.dart';

class HomepageVendor extends StatefulWidget {
  const HomepageVendor({super.key});

  @override
  State<HomepageVendor> createState() => _DashboardState();
}

class _DashboardState extends State<HomepageVendor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                "Konfirmasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar?",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: const Text("Iya", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    key: _scaffoldKey,
    backgroundColor: const Color(0xFF1A567D),
    drawer: _buildDrawer(),
    body: Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian kiri: Icon menu + teks
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              _scaffoldKey.currentState!.openDrawer();
                            },
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Hallo, Gaol Rental",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Balige, Kabupaten Toba",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Bagian kanan: Icon notifikasi & chat
                     Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotifikasiPagev()));
                        },
                      ),
                      IconButton(
                        icon: Image.asset("assets/images/chat.png", width: 24, height: 24),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen()));}
                          ),
                        ],
                      ), // <- Tambahkan koma di sini
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        Positioned(
          top: 160,
          left: 0,
          right: 0,
          child: Container(
            height: MediaQuery.of(context).size.height - 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(Icons.motorcycle, "Tambah Motor", () {
                          // Navigasi ke halaman Pesanan jika ada
                        }),

                        _buildActionButton(Icons.list, "Pesanan", () {
                          // Navigasi ke halaman Pesanan jika ada
                        }),
                        _buildActionButton(Icons.rate_review, "Ulasan", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UlasanVendorScreen()),
   
                          );
                        }),
                      ],
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Daftar Motor Anda",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildMotorCard("Honda Vario 125", "125 cc", "Automatic",
                      "150K/hari", "assets/images/m1.png"),
                  _buildMotorCard("Honda Beat Pop", "125 cc", "Automatic",
                      "125K/hari", "assets/images/m2.png"),
                  _buildMotorCard("Kawasaki KLX 150", "150 cc", "Kopling",
                      "125K/hari", "assets/images/m10.png"),
                  _buildMotorCard("Honda Vario 125", "125 cc", "Automatic",
                      "150K/hari", "assets/images/m11.png"),
                  _buildMotorCard("Honda Beat Pop", "125 cc", "Automatic",
                      "125K/hari", "assets/images/m1.png"),
                  _buildMotorCard("Kawasaki KLX 150", "150 cc", "Kopling",
                      "125K/hari", "assets/images/m2.png"),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  // Drawer (Menu Samping) dengan No HP
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFF1A567D)),
            padding:
                const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
              children: [
                const CircleAvatar(
                  radius: 40, // Membuat avatar sedikit lebih besar
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: Color(0xFF1A567D)),
                ),
                const SizedBox(height: 15), // Jarak antara avatar dan teks
                const Text(
                  "Gaol Rental",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize:
                          22, // Ukuran teks diperbesar agar lebih proporsional
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "gaolrental@gmail.com",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16, // Ukuran teks email diperbesar
                      color: Colors.white70),
                ),
                const SizedBox(height: 4),
                const Text(
                  "+62 812-3456-7890",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16, // Ukuran teks nomor HP juga diperbesar
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Jl. Gereja, Balige ,Kabupaten Toba",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16, // Ukuran teks nomor HP juga diperbesar
                      color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15), // Jarak antara header dan menu
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black54),
            title: const Text("Edit Profile", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.black54),
            title: const Text("Lupa Kata Sandi", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LupaKataSandivScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Logout", style: TextStyle(fontFamily: 'Montserrat', fontSize: 16, color: Colors.red)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1A567D)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

  Widget _buildMotorCard(
      String title, String cc, String type, String price, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(imagePath,
                  width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(cc,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey)),
                  Text(type,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(price,
                      style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

