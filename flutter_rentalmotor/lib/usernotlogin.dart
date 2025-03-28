import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/datav.dart';
import 'package:flutter_rentalmotor/datav1.dart';
import 'package:flutter_rentalmotor/datav2.dart';
import 'package:flutter_rentalmotor/detailm.dart';
import 'package:flutter_rentalmotor/detailm1.dart';
import 'package:flutter_rentalmotor/detailm2.dart';
import 'package:flutter_rentalmotor/home.dart';


class Usernotlogin extends StatefulWidget {
  const Usernotlogin({Key? key}) : super(key: key);
  @override
  _UsernotloginState createState() => _UsernotloginState();
}

class _UsernotloginState extends State<Usernotlogin> {
  int _selectedIndex = 0;
  String selectedLocation = "Cari Lokasi";

  // Fungsi untuk menampilkan alert ketika belum terautentifikasi
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
              backgroundColor: Colors.blue, // Warna utama
              foregroundColor: Colors.white, // Warna teks agar lebih kontras
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
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


  void _onItemTapped(int index) {
    // Jika index 1 (Pesanan) atau 2 (Akun), tampilkan alert
    if (index == 1 || index == 2) {
      _showAuthAlert();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToVendorPage(String location) {
    if (location == "Balige, Kab. Toba") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DataV()));
    } else if (location == "Laguboti, Kab. Toba") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DataV1()));
    } else if (location == "Porsea, Kab. Toba") {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DataV2()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                color: Color(0xFF2C567E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selamat Datang",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.notifications_none, color: Colors.white),
                        // Tampilkan alert bila belum terautentifikasi
                        onPressed: _showAuthAlert,
                      ),
                      IconButton(
                        icon: Image.asset("assets/images/chat.png",
                            width: 24, height: 24),
                        // Tampilkan alert bila belum terautentifikasi
                        onPressed: _showAuthAlert,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            // VENDOR SECTION DIPINDAH KE ATAS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text("Vendor", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Icon(Icons.location_on, color: Colors.black54, size: 18),
                  SizedBox(width: 5),
                  DropdownButton<String>(
                    value: selectedLocation,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLocation = newValue!;
                      });
                      _navigateToVendorPage(selectedLocation);
                    },
                    items: <String>["Cari Lokasi", "Balige, Kab. Toba", "Laguboti, Kab. Toba", "Porsea, Kab. Toba"]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 14, color: Colors.black54)),
                      );
                    }).toList(),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                    underline: SizedBox(),
                  ),
                ],
              ),
            ),

            // Vendor List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
                children: [
                  _buildVendorCard("GAOL Rental", "Balige, Kab Toba", "5.0",
                      "assets/images/m4.png", context),
                  _buildVendorCard("Mak Cik Motor", "Laguboti, Kab Toba", "4.8",
                      "assets/images/m5.png", context),
                  _buildVendorCard("Bezanda", "Porsea, Kab Toba", "4.9",
                      "assets/images/m6.png", context),
                ],
              ),
            ),

            SizedBox(height: 20),

            // REKOMENDASI MOTOR SECTION DIPINDAH KE BAWAH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Rekomendasi Motor",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 20),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildMotorCard(context, "Honda Beat", "110cc", "150K/hari",
                      "assets/images/m1.png", detailm()),
                  SizedBox(width: 10),
                  _buildMotorCard(context, "Honda ADV160", "125cc", "150K/hari",
                      "assets/images/m10.png", detailm1()),
                  SizedBox(width: 10),
                  _buildMotorCard(context, "Yamaha Aerox", "125cc", "150K/hari",
                      "assets/images/m11.png", detailm2()),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: [
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
    );
  }

  Widget _buildMotorCard(BuildContext context, String title, String cc,
      String price, String imagePath, Widget detailPage) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => detailPage),
        );
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath,
                height: 80, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 5),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(cc, style: TextStyle(fontSize: 12, color: Colors.black54)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF2C567E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(Icons.arrow_forward_ios,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(String title, String location, String rating,
      String imagePath, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == "GAOL Rental") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DataV()),
          );
        } else if (title == "Mak Cik Motor") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DataV1()),
          );
        } else if (title == "Bezanda") {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DataV2()),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath,
                height: 100, width: double.infinity, fit: BoxFit.cover),
            SizedBox(height: 5),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(location,
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow, size: 16),
                SizedBox(width: 5),
                Text(rating,
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}