import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart' as home;
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/pesanan/pesanan.dart';

class DetailPesanan extends StatefulWidget {
  @override
  _DetailPesananState createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan> {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 1;
  List<dynamic> bookings = [];
  bool isLoading = true;

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color accentBlue = Color(0xFF64B5F6);

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

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'in transit':
        return Colors.blue;
      case 'in use':
        return Colors.purple;
      case 'awaiting return':
        return Colors.amber;
      case 'completed':
        return Colors.teal;
      case 'canceled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'in transit':
        return Icons.local_shipping;
      case 'in use':
        return Icons.directions_bike;
      case 'awaiting return':
        return Icons.assignment_return;
      case 'completed':
        return Icons.task_alt;
      case 'canceled':
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          'Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            )
          : bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Pesanan Anda akan muncul di sini',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.motorcycle, size: 16),
                        label: Text('Sewa Motor Sekarang', style: TextStyle(fontSize: 14)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => home.HomePageUser()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter status horizontal
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Container(
                        height: 46,
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
                                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? primaryBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? primaryBlue : Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  status[0].toUpperCase() + status.substring(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Tidak ada pesanan dengan status ini',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchBookings,
                              color: primaryBlue,
                              child: ListView.builder(
                                padding: EdgeInsets.all(12),
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final item = filteredBookings[index];
                                  final status = item['status'] ?? '';

                                  final startDate = DateTime.parse(item['start_date']);
                                  final endDate = DateTime.parse(item['end_date']);
                                  final durationDays = endDate.difference(startDate).inDays + 1;

                                  final dateFormat = DateFormat('dd MMM yyyy');
                                  final formattedStart = dateFormat.format(startDate);
                                  final formattedEnd = dateFormat.format(endDate);

                                  final String? originalImage = item['motor']['image'];
                                  String imageUrl = originalImage ?? 'https://via.placeholder.com/100';
                                  if (imageUrl.startsWith('/')) {
                                    imageUrl = "${ApiConfig.baseUrl}$imageUrl";
                                  }

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Status Banner
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(status).withOpacity(0.1),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                getStatusIcon(status),
                                                color: getStatusColor(status),
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                status[0].toUpperCase() + status.substring(1),
                                                style: TextStyle(
                                                  color: getStatusColor(status),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Motor Info and Details
                                        Padding(
                                          padding: EdgeInsets.all(12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Motor Image
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(6),
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    width: 80,
                                                    height: 80,
                                                    color: Colors.grey[300],
                                                    child: Icon(Icons.image_not_supported, color: Colors.grey[500], size: 20),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              
                                              // Details
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['motor']['name'] ?? 'Nama tidak ada',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: primaryBlue,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.date_range, size: 14, color: Colors.grey[600]),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            '$formattedStart - $formattedEnd',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey[700],
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                                        SizedBox(width: 4),
                                                        Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: primaryBlue.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          child: Text(
                                                            '$durationDays hari',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                              color: primaryBlue,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            item['pickup_location'] ?? 'Lokasi tidak ada',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.monetization_on, size: 14, color: Colors.green[700]),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              "${item['motor']['price_per_day']} / hari",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.green[700],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => PesananPage(booking: item),
                                                              ),
                                                            );
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: primaryBlue,
                                                            foregroundColor: Colors.white,
                                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            minimumSize: Size(70, 30),
                                                          ),
                                                          child: Text('Detail', style: TextStyle(fontSize: 12)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: primaryBlue,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Akun',
            ),
          ],
        ),
      ),
    );
  }
}