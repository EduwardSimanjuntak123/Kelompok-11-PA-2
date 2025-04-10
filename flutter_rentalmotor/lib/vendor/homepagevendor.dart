import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/vendor/motor_detail_screen.dart';
import 'package:flutter_rentalmotor/vendor/lupakatasandiv.dart';
import 'package:flutter_rentalmotor/vendor/editprofilvendor.dart';
import 'package:flutter_rentalmotor/vendor/chatvendor.dart';
import 'package:flutter_rentalmotor/vendor/notifikasivendor.dart';
import 'package:flutter_rentalmotor/vendor/ulasanvendor.dart';
import 'package:flutter_rentalmotor/vendor/daftar_pesanan_screen.dart';
import 'package:flutter_rentalmotor/vendor/CreateMotorScreen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageVendor extends StatefulWidget {
  const HomepageVendor({super.key});

  @override
  State<HomepageVendor> createState() => _DashboardState();
}

class _DashboardState extends State<HomepageVendor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  int? vendorId;
  String? businessName;
  String? vendorAddress;
  String? vendorImagePath;
  List<dynamic> motorList = [];

  @override
  void initState() {
    super.initState();
    loadVendorData();
  }

  Future<void> loadVendorData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    final String baseUrl = ApiConfig.baseUrl;

    final response = await http.get(
      Uri.parse('$baseUrl/vendor/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final user = data['user'];
      final vendor = user['vendor'];

      setState(() {
        vendorId = vendor['id'];
        businessName = vendor['shop_name'];
        vendorAddress = vendor['shop_address'];
        vendorImagePath = user['profile_image'];
      });

      prefs.setInt('vendorId', vendorId!);
      prefs.setString('businessName', businessName!);
      prefs.setString('vendorAddress', vendorAddress!);

      fetchMotorList(token);
    } else {
      print("❌ Gagal ambil data vendor");
    }
  }

  Future<void> fetchMotorList(String? token) async {
    final String baseUrl = ApiConfig.baseUrl;

    final response = await http.get(
      Uri.parse('$baseUrl/motor/vendor'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        motorList = data['data'];
      });
    } else {
      print("❌ Gagal ambil motor: ${response.statusCode}");
    }
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
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text("Konfirmasi", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tidak"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Iya", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = ApiConfig.baseUrl;
    final String fullImageUrl =
        vendorImagePath != null ? '$baseUrl$vendorImagePath' : '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A567D),
      drawer: _buildDrawer(fullImageUrl),
      body: RefreshIndicator(
        onRefresh: () async {
          final prefs = await SharedPreferences.getInstance();
          String? token = prefs.getString('auth_token');
          await fetchMotorList(token);
        },
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 30),
                        onPressed: () =>
                            _scaffoldKey.currentState!.openDrawer(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessName ?? "Hallo, Vendor",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              vendorAddress ?? "Alamat belum tersedia",
                              style: const TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            if (vendorId != null)
                              Text(
                                "ID: $vendorId",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotifikasiPagev()),
                            ),
                          ),
                          IconButton(
                            icon: Image.asset("assets/images/chat.png",
                                width: 24, height: 24),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen()),
                            ),
                          ),
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
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(Icons.motorcycle, "Tambah Motor",
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const CreateMotorScreen()),
                          );
                        }),
                        _buildActionButton(Icons.list, "Pesanan", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DaftarPesananVendorScreen()),
                          );
                        }),
                        _buildActionButton(Icons.rate_review, "Ulasan", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UlasanVendorScreen()),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Daftar Motor Anda",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...motorList
                        .map((motor) => _buildMotorCard(motor))
                        .toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(String fullImageUrl) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(color: Color(0xFF1A567D)),
            padding:
                const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
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
                const SizedBox(height: 15),
                Text(businessName ?? 'Nama Bisnis',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text("ID Vendor: ${vendorId ?? '-'}",
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white70)),
                Text(vendorAddress ?? 'Alamat belum tersedia',
                    style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfile()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Lupa Kata Sandi"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LupaKataSandivScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context),
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
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF1A567D)),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorCard(dynamic motorData) {
    final String imageUrl = "${ApiConfig.baseUrl}${motorData['image']}";

    // Konversi data ke model
    final motor = MotorModel.fromJson(motorData);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MotorDetailScreen(motor: motor),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.motorcycle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(motor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(motor.type, style: const TextStyle(color: Colors.grey)),
                  Text("${motor.year}",
                      style: const TextStyle(color: Colors.grey)),
                  Text("Rp ${motor.price}/hari",
                      style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
