import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/detailmotor.dart';
import 'package:flutter_rentalmotor/user/notifikasi.dart';
import 'package:flutter_rentalmotor/user/chat.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/datavendor.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/homepage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({Key? key}) : super(key: key);

  @override
  _HomePageUserState createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  int _selectedIndex = 0;
  String _userName = "Pengguna";
  int? _userId;
  List<Map<String, dynamic>> _motorList = [];
  List<Map<String, dynamic>> _vendorList = [];
  final String baseUrl = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');

    setState(() {
      _userId = userId;
      _userName = userName ?? "Guest";
    });

    _fetchVendors();
    _fetchMotors();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('user_name');
    int? id = prefs.getInt('user_id');
    if (name != null && id != null) {
      setState(() {
        _userName = name;
        _userId = id;
      });
    }
  }

  Future<void> _fetchMotors() async {
    try {
      List<Map<String, dynamic>> motors = await HomePageApi().fetchMotors();
      if (mounted) {
        setState(() {
          _motorList = motors;
        });
      }
    } catch (e) {
      _showErrorMessage("Gagal mengambil data motor!");
    }
  }

  Future<void> _fetchVendors() async {
    try {
      List<Map<String, dynamic>> vendors = await HomePageApi().fetchVendors();
      if (mounted) {
        setState(() {
          _vendorList = vendors;
        });
      }
    } catch (e) {
      _showErrorMessage("Gagal mengambil data vendor!");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _onItemTapped(int index) async {
    // Proteksi untuk guest
    if (_userId == null && (index == 1 || index == 2)) {
      _showLoginRequiredAlert();
      return;
    }

    if (index == 2) {
      // Akun
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Akun()));
      _loadUserData();
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Pesanan (buat halaman sendiri nanti)
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const PesananPage()));
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showLoginRequiredAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Login Diperlukan"),
        content: const Text(
            "Anda harus login terlebih dahulu untuk mengakses fitur ini."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _fetchVendors();
          await _fetchMotors();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildVendorSection(),
              _buildMotorSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
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
            "Halo, $_userName (ID: ${_userId ?? '-'})",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotifikasiPage()));
                },
              ),
              IconButton(
                icon: Image.asset("assets/images/chat.png",
                    width: 24, height: 24),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatPage()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Daftar Vendor",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        _vendorList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _vendorList.map((vendor) {
                    String path =
                        vendor["user"]["profile_image"]?.toString().trim() ??
                            "";
                    String imageUrl = path.isNotEmpty
                        ? (path.startsWith("http") ? path : "$baseUrl$path")
                        : "assets/images/default_vendor.png";
                    return _buildVendorCard(
                      vendor["shop_name"] ?? "Vendor Tidak Diketahui",
                      vendor["rating"]?.toString() ?? "0",
                      imageUrl,
                      vendor["id"],
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildMotorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text("Rekomendasi Motor",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        _motorList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _motorList.map((motor) {
                    String path = motor["image"]?.toString().trim() ?? "";
                    String imageUrl = path.isNotEmpty
                        ? (path.startsWith("http") ? path : "$baseUrl$path")
                        : "assets/images/default_motor.png";
                    String formattedPrice;
                    if (motor["price"] != null) {
                      final priceValue =
                          num.tryParse(motor["price"].toString());
                      if (priceValue != null) {
                        formattedPrice = NumberFormat.decimalPattern('id')
                            .format(priceValue);
                      } else {
                        formattedPrice = "Harga Tidak Valid";
                      }
                    } else {
                      formattedPrice = "Harga Tidak Diketahui";
                    }

                    return _buildMotorCard(
                      motor["name"] ?? "Nama Tidak Diketahui",
                      motor["rating"]?.toString() ?? "Rating Tidak Diketahui",
                      "Rp $formattedPrice/hari",
                      imageUrl,
                      DetailMotorPage(
                        motor: motor,
                        isGuest: _userId == null,
                      ),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildMotorCard(String title, String rating, String price,
      String imageUrl, Widget detailPage) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => detailPage));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset("assets/images/default_motor.png",
                    height: 80, width: double.infinity, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 5),
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Rating: $rating",
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(price,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(
      String shopName, String rating, String imageUrl, int vendorId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DataVendor(vendorId: vendorId)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 2)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset("assets/images/default_vendor.png",
                    height: 80, width: double.infinity, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 5),
            Text(shopName,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("Rating: $rating",
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// Placeholder halaman Pesanan
class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pesanan Anda")),
      body:
          const Center(child: Text("Daftar pesanan akan ditampilkan di sini")),
    );
  }
}
