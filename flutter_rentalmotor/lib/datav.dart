import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/detailm.dart';
import 'package:flutter_rentalmotor/home.dart';
import 'package:flutter_rentalmotor/user/ulasan/ulasanpengguna.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';

class DataV extends StatefulWidget {
  @override
  _DataVendorState createState() => _DataVendorState();
}

class _DataVendorState extends State<DataV> {
  int _selectedIndex = 0;
  bool isAuthenticated = false; // Status autentikasi

  // Fungsi menampilkan peringatan autentikasi
  void _showAuthAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Peringatan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ],
          ),
          content: Text(
            "Anda belum terautentifikasi, silakan login.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                // Arahkan ke halaman login
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomeScreen()), // Ganti dengan halaman login yang benar
                );
              },
              child: Text("Ya, Login"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk navigasi navbar
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    } else if (index == 1 || index == 2) {
      if (!isAuthenticated) {
        _showAuthAlert(); // Tampilkan peringatan jika belum login
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => index == 1 ? DetailPesanan() : Akun()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/m4.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gaol Rental',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Balige, Toba Samosir', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('OPEN', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: List.generate(5, (index) => Icon(Icons.star, color: Colors.orange, size: 20)),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox('Ready', '2'),
                      _infoBox('Booked', '2'),
                      _infoBox('In-Use', '1'),
                    ],
                  ),
                  SizedBox(height: 15),
                  _motorList(context, 'Ready', 'assets/images/m1.png', Colors.green),
                  _motorList(context, 'In-Use', 'assets/images/m2.png', Colors.red),
                  _motorList(context, 'Booked', 'assets/images/m3.png', Colors.blue),
                  SizedBox(height: 15),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UlasanPenggunaVendorScreen()),
                      );
                    },
                    child: Text('Ulasan Pengguna', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _motorList(BuildContext context, String status, String imagePath, Color statusColor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.asset(imagePath, width: 70),
        title: Text('Honda Vario', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('125cc'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('95K/hari', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(status, style: TextStyle(color: statusColor)),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => detailm()),
          );
        },
      ),
    );
  }
}
