import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/user/detailmotor.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchVendorData();
    await _fetchMotorData();
    setState(() => _isLoading = false);
  }

  Future<void> _fetchVendorData() async {
    final String apiUrl = "${ApiConfig.baseUrl}/vendor/${widget.vendorId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() => _vendorData = jsonResponse['data']);
      } else {
        throw Exception("Gagal mengambil data vendor");
      }
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    }
  }

  Future<void> _fetchMotorData() async {
    final String apiUrl =
        "${ApiConfig.baseUrl}/customer/motors/vendor/${widget.vendorId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() =>
            _motorList = List<Map<String, dynamic>>.from(jsonResponse['data']));
      } else {
        throw Exception("Gagal mengambil data motor");
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor"),
        backgroundColor: Color(0xFF2C567E),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Vendor
                      _vendorData?["image"] != null
                          ? Image.network(_vendorData!["image"],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover)
                          : Container(height: 200, color: Colors.grey),
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                _vendorData?["shop_name"] ??
                                    "Nama Tidak Diketahui",
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(
                                _vendorData?["shop_address"] ??
                                    "Alamat Tidak Diketahui",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 5),
                            Row(
                              children: List.generate(5, (index) {
                                double rating = double.tryParse(
                                        _vendorData?["rating"]?.toString() ??
                                            "0") ??
                                    0;
                                return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber);
                              }),
                            ),
                            SizedBox(height: 10),
                            Text(
                                _vendorData?["shop_description"] ??
                                    "Deskripsi tidak tersedia",
                                style: TextStyle(color: Colors.black87)),
                            SizedBox(height: 20),
                            Text("Motor Tersedia",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            _motorList.isEmpty
                                ? Center(
                                    child: Text("Tidak ada motor tersedia"))
                                : Column(
                                    children: _motorList
                                        .map((motor) =>
                                            _motorListWidget(context, motor))
                                        .toList(),
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
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  Widget _motorListWidget(BuildContext context, Map<String, dynamic> motor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: motor["image"] != null
            ? Image.network(motor["image"],
                width: 80, height: 80, fit: BoxFit.cover)
            : Container(width: 80, height: 80, color: Colors.grey),
        title: Text(motor["name"] ?? "Nama Tidak Ada",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
            Text("${formatRupiah(int.parse(motor["price"].toString()))}/hari"),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailMotorPage(motor: motor)));
        },
      ),
    );
  }
}
