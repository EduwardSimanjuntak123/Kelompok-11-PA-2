import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/signin.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isGuest;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isGuest,
  }) : super(key: key);

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Color(0xFF2196F3)),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                "Masuk Diperlukan",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const Text(
          "Anda harus masuk terlebih dahulu untuk mengakses fitur ini.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text(
              "Masuk",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width < 360 ? 20 : 24;
    double fontSize = MediaQuery.of(context).size.width < 360 ? 10 : 12;

    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2C567E),
      unselectedItemColor: Colors.grey,
      selectedFontSize: fontSize,
      unselectedFontSize: fontSize,
      onTap: (index) {
        if (isGuest && (index == 1 || index == 2)) {
          _showLoginAlert(context);
        } else {
          onTap(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: iconSize),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined, size: iconSize),
          activeIcon: Icon(Icons.receipt_long, size: iconSize),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: iconSize),
          label: "Akun",
        ),
      ],
    );
  }
}
