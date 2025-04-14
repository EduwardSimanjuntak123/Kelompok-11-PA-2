import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/home.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';

class detailm extends StatefulWidget {
  @override
  _detailmState createState() => _detailmState();
}

class _detailmState extends State<detailm> {
  int _selectedIndex = 0;
  bool isLoggedIn = false; // Gantilah dengan cara validasi login yang benar

  void _onItemTapped(int index) {
    if (!isLoggedIn && (index == 1 || index == 2)) {
      _showAuthAlert(context);
      return;
    }

    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DetailPesanan()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Akun()),
      );
    }
  }

  void _showAuthAlert(BuildContext context) {
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
                Navigator.pop(context);
                // Arahkan ke halaman login (gantilah HomeScreen dengan halaman login yang benar)
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Ya, Login"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Detail",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Gambar Motor
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    "assets/images/m7.png",
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Nama Motor
            Text(
              "HONDA BEAT POP",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Automatic/Manual",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            SizedBox(height: 20),

            // Deskripsi
            Text(
              "Deskripsi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Lorem Ipsum is simply dummy text of the printing and typesetting industry...",
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),

            SizedBox(height: 15),

            // Informasi Harga dan Rating
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoBox(Icons.star, "5.0", "Rating", Colors.yellow),
                  _buildInfoBox(Icons.attach_money, "Rp 150.000", "Price", Colors.green),
                  _buildInfoBox(Icons.category, "1 Variant", "Variants", Colors.blue),
                ],
              ),
            ),

            Spacer(),

            // Tombol "Book Now"
            Center(
  child: ElevatedButton(
    onPressed: () {
      if (!isLoggedIn) {
        _showAuthAlert(context);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF2C567E),
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(
      "Book Now",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  ),
),


            SizedBox(height: 20),
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

  Widget _buildInfoBox(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(width: 5),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
