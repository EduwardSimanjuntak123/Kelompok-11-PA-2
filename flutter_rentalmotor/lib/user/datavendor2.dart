import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/detailmotor2.dart';
import 'package:flutter_rentalmotor/user/ulasanpengguna.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';

class DataVendor2 extends StatefulWidget {
  @override
  _DataVendor2State createState() => _DataVendor2State();
}

class _DataVendor2State extends State<DataVendor2> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
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
                  'assets/images/m5.png',
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
                            'Bezanda',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Porsea, Toba Samosir', style: TextStyle(color: Colors.grey)),
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
            MaterialPageRoute(builder: (context) => DetailMotorPage2()),
          );
        },
      ),
    );
  }
}
