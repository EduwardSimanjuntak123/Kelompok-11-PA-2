import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/signin.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isGuest; // Tambahkan ini

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isGuest, // Tambahkan ini
  }) : super(key: key);

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock, color: Color(0xFF2196F3)),
            SizedBox(width: 10),
            Text("Login Diperlukan"),
          ],
        ),
        content: const Text(
            "Anda harus login terlebih dahulu untuk mengakses fitur ini."),
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
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF2C567E),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (isGuest && (index == 1 || index == 2)) {
          _showLoginAlert(context);
        } else {
          onTap(index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
      ],
    );
  }
}
