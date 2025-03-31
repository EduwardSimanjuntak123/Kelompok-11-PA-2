import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/user/detailmotor.dart';
import 'package:flutter_rentalmotor/user/ulasanpengguna.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:intl/intl.dart';

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
  final String baseUrl = "http://192.168.189.159:8080";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchVendorData();
    await _fetchMotorData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchVendorData() async {
    final String apiUrl = "$baseUrl/vendor/${widget.vendorId}";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _vendorData = jsonResponse['data'];
        });
      } else {
        throw Exception(
            "Gagal mengambil data vendor (Status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching vendor data: $e";
      });
    }
  }

  Future<void> _fetchMotorData() async {
    final String apiUrl = "$baseUrl/customer/motors/vendor/1";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _motorList = List<Map<String, dynamic>>.from(jsonResponse['data']);
        });
      } else {
        throw Exception(
            "Gagal mengambil data motor (Status: ${response.statusCode})");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching motor data: $e";
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => DetailPesanan()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  String formatRupiah(int amount) {
    return NumberFormat.decimalPattern('id').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Vendor - ID: ${widget.vendorId}"),
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
                            Text(
                              _vendorData?['shop_name'] ??
                                  'Nama Tidak Diketahui',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              _vendorData?['shop_address'] ??
                                  'Alamat Tidak Diketahui',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 10),
                            _motorList.isEmpty
                                ? Center(
                                    child: Text("Tidak ada motor tersedia."))
                                : Column(
                                    children: _motorList
                                        .map((motor) =>
                                            _motorListWidget(context, motor))
                                        .toList(),
                                  ),
                            SizedBox(height: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                minimumSize: Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UlasanPenggunaVendorScreen()));
                              },
                              child: Text('Ulasan Pengguna',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
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
      margin: EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(motor['name'] ?? 'Nama Tidak Ada',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${formatRupiah(motor['price'])} IDR/hari'),
        trailing: Text('Rating: ${motor['rating'] ?? '-'}'),
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
