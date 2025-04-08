import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart' as home;
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/pesanan.dart';

class DetailPesanan extends StatefulWidget {
  @override
  _DetailPesananState createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 1;
  List<dynamic> bookings = [];
  bool isLoading = true;

  List<String> statuses = [
    'Semua',
    'pending',
    'confirmed',
    'in transit',
    'in use',
    'awaiting return',
    'completed',
    'canceled',
    'rejected',
  ];

  String selectedStatus = 'Semua';

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home.HomePageUser()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DetailPesanan()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Akun()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    try {
      String? token = await storage.read(key: "auth_token");
      print("TOKEN: $token");
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/customer/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          bookings = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data pesanan');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> get filteredBookings {
    if (selectedStatus == 'Semua') return bookings;
    return bookings
        .where((booking) => booking['status'] == selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C567E),
        title: Text(
          'Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bookings.isEmpty
              ? Center(child: Text('Belum ada pesanan'))
              : Column(
                  children: [
                    // Filter status horizontal (teks + underline biru)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2), // arah shadow ke bawah
                          ),
                        ],
                      ),
                      child: Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: statuses.length,
                          itemBuilder: (context, index) {
                            final status = statuses[index];
                            final isSelected = selectedStatus == status;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = status;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      status[0].toUpperCase() +
                                          status.substring(1),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected
                                            ? Color(0xFF2C567E)
                                            : Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Container(
                                      height: 2,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color(0xFF2C567E)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Daftar pesanan
                    Expanded(
                      child: filteredBookings.isEmpty
                          ? Center(
                              child:
                                  Text('Tidak ada pesanan dengan status ini'))
                          : ListView.builder(
                              padding: EdgeInsets.all(10),
                              itemCount: filteredBookings.length,
                              itemBuilder: (context, index) {
                                final item = filteredBookings[index];

                                final startDate =
                                    DateTime.parse(item['start_date']);
                                final endDate =
                                    DateTime.parse(item['end_date']);
                                final durationDays =
                                    endDate.difference(startDate).inDays + 1;

                                final dateFormat = DateFormat('dd MMM');
                                final formattedStart =
                                    dateFormat.format(startDate);
                                final formattedEnd = dateFormat.format(endDate);

                                final String? originalImage =
                                    item['motor']['image'];
                                String imageUrl = originalImage ??
                                    'https://via.placeholder.com/100';
                                if (imageUrl.startsWith('/')) {
                                  imageUrl = "${ApiConfig.baseUrl}$imageUrl";
                                }

                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['motor']['name'] ??
                                              'Nama tidak ada',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Durasi: $durationDays hari ($formattedStart - $formattedEnd)',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          item['motor']['model'] ?? '',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(Icons.image),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['pickup_location'] ??
                                                        'Lokasi tidak ada',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    "${item['motor']['price_per_day']} / hari",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PesananPage(
                                                            booking: item),
                                                  ),
                                                );
                                              },
                                              child: Text('Detail'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2C567E),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
