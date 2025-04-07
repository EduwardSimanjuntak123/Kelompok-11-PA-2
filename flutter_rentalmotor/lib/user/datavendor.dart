import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/detailmotor.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/services/vendor_service.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

class DataVendor extends StatefulWidget {
  final int vendorId;
  const DataVendor({Key? key, required this.vendorId}) : super(key: key);

  @override
  _DataVendorState createState() => _DataVendorState();
}

class _DataVendorState extends State<DataVendor> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _vendorData;
  List<Map<String, dynamic>> _motorList = [];
  bool _isLoading = true;
  int? _userId; // Menyimpan user ID
  String _errorMessage = '';
  final VendorService _vendorService = VendorService();

  @override
  void initState() {
    super.initState();
    _getUserId(); // Ambil user ID dari penyimpanan
    _fetchData();
  }

  /// Mengambil user ID dari SharedPreferences
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id'); // Ambil ID pengguna
    });
  }

  Future<void> _fetchData() async {
    try {
      final vendor = await _vendorService.fetchVendorById(widget.vendorId);
      setState(() {
        _vendorData = vendor;
      });
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    }
    await _fetchMotorData();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMotorData() async {
    try {
      final motorList =
          await _vendorService.fetchMotorsByVendor(widget.vendorId);
      setState(() => _motorList = motorList);
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 1) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DetailPesanan()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    String? vendorImage = _vendorData?['user']?['profile_image'];
    String fullVendorImageUrl =
        vendorImage != null && !vendorImage.startsWith("http")
            ? "${ApiConfig.baseUrl}$vendorImage"
            : vendorImage ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor"),
        backgroundColor: const Color(0xFF2C567E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fullVendorImageUrl.isNotEmpty
                          ? Image.network(fullVendorImageUrl,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover)
                          : Container(height: 200, color: Colors.grey),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _vendorData?['shop_name'] ??
                                    "Nama Tidak Diketahui",
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 5),
                            Text(
                                _vendorData?['shop_address'] ??
                                    "Alamat Tidak Diketahui",
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 5),
                            Row(
                              children: List.generate(5, (index) {
                                double rating = double.tryParse(
                                        _vendorData?['rating']?.toString() ??
                                            "0") ??
                                    0;
                                return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber);
                              }),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                _vendorData?['shop_description'] ??
                                    "Deskripsi tidak tersedia",
                                style: const TextStyle(color: Colors.black87)),
                            const SizedBox(height: 20),
                            const Text("Motor Tersedia",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _motorList.isEmpty
                                ? const Center(
                                    child: Text("Tidak ada motor tersedia"))
                                : Column(
                                    children: _motorList
                                        .map((motor) =>
                                            _motorListWidget(context, motor))
                                        .toList()),
                          ],
                        ),
                      ),
                    ],
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
              icon: Icon(Icons.receipt_long), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan daftar motor
  Widget _motorListWidget(BuildContext context, Map<String, dynamic> motor) {
    String? imageUrl = motor["image"];
    String fullImageUrl = imageUrl != null && !imageUrl.startsWith("http")
        ? "${ApiConfig.baseUrl}$imageUrl"
        : imageUrl ?? "";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: fullImageUrl.isNotEmpty
            ? Image.network(fullImageUrl,
                width: 80, height: 80, fit: BoxFit.cover)
            : Container(width: 80, height: 80, color: Colors.grey),
        title: Text(motor["name"] ?? "Nama Tidak Ada",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text("${formatRupiah(int.parse(motor["price"].toString()))}/hari"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMotorPage(
                motor: motor,
                isGuest: _userId == null, // Jika _userId null, berarti guest
              ),
            ),
          );
        },
      ),
    );
  }
}
