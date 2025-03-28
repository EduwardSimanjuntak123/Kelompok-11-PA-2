import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/editprofiluser.dart';
import 'package:flutter_rentalmotor/home.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart'; 
import 'package:flutter_rentalmotor/lupakatasandi.dart'; 
import 'package:flutter_rentalmotor/user/detailpesanan.dart';

class Akun extends StatefulWidget {
  const Akun({super.key});

  @override
  State<Akun> createState() => _AkunState();
}

class _AkunState extends State<Akun> {
  int _selectedIndex = 2; 

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
        MaterialPageRoute(builder: (context) => Akun()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: Color(0xFF2C567E),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'My Profile',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                bottom: -50,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildInfoTile(Icons.person, 'Kelompok 11'),
                _buildInfoTile(Icons.email, 'Kelompok11@gmail.com'),
                _buildInfoTile(Icons.phone, '0813-6543-8970'),
                _buildInfoTile(Icons.location_on, 'Dusun III Sidaji, Kec. Simarmata,\nKab. Simanindo, Sumatera Utara'),
                const SizedBox(height: 16),
                const Text('Setting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSettingButton(Icons.edit, 'Edit Profile', Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileuser()));
                }),
                _buildSettingButton(Icons.lock, 'Lupa Kata Sandi', Colors.blue, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LupaKataSandiScreen()));
                }),
                _buildSettingButton(Icons.logout, 'Logout', Colors.red, () {
                  _showLogoutDialog(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(text, textAlign: TextAlign.right),
      ),
    );
  }

  Widget _buildSettingButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            Spacer(), // Ini yang tadinya kurang titik koma
            Text(text, textAlign: TextAlign.end, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text(
                "Konfirmasi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin keluar?",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Tidak", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
              child: Text("Iya", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
