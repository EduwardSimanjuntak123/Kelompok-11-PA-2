// detail-pesanan.tsx - Updated to sort bookings by latest order

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart' as home;
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/pesanan/pesanan.dart';
import 'package:shimmer/shimmer.dart';

class DetailPesanan extends StatefulWidget {
  @override
  _DetailPesananState createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan>
    with SingleTickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  int _selectedIndex = 1;
  List<dynamic> bookings = [];
  bool isLoading = true;

  // Blue theme colors - updated to match homepage
  final Color primaryBlue = Color(0xFF2C567E);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color accentBlue = Color(0xFF64B5F6);

  // Animation controller for staggered animations
  late AnimationController _animationController;

  // Status filter
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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    fetchBookings();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          // Sort bookings by created_at date in descending order (newest first)
          bookings.sort((a, b) {
            DateTime dateA = DateTime.parse(a['created_at'] ?? DateTime.now().toString());
            DateTime dateB = DateTime.parse(b['created_at'] ?? DateTime.now().toString());
            return dateB.compareTo(dateA); // Descending order (newest first)
          });
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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom header that matches homepage style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlue, const Color(0xFF1976D2)],
                stops: [0.3, 1.0],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.refresh, color: Colors.white, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: fetchBookings,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Description container
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long,
                              color: Colors.white.withOpacity(0.9), size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Daftar Pesanan Anda",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rest of the content
          Expanded(
            child: isLoading
                ? _buildLoadingSkeleton()
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
                              label: Text('Sewa Motor Sekarang',
                                  style: TextStyle(fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          home.HomePageUser()),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          // Improved status filter - now as a grid instead of horizontal scroll
                          Container(
                            padding: EdgeInsets.all(16),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.filter_list,
                                          size: 18,
                                          color: primaryBlue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Filter Status',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (selectedStatus != 'Semua')
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedStatus = 'Semua';
                                          });
                                        },
                                        child: Text(
                                          'Reset',
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontSize: 12,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          minimumSize: Size(0, 0),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),

                                // Replace the GridView.builder with this dropdown button
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedStatus,
                                      isExpanded: true,
                                      icon: Icon(Icons.keyboard_arrow_down,
                                          color: primaryBlue),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedStatus = newValue;
                                          });
                                        }
                                      },
                                      items: statuses
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        Color statusColor = value == 'Semua'
                                            ? primaryBlue
                                            : getStatusColor(value);
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              if (value != 'Semua')
                                                Icon(
                                                  getStatusIcon(value),
                                                  size: 14,
                                                  color: statusColor,
                                                ),
                                              if (value != 'Semua')
                                                SizedBox(width: 8),
                                              Text(
                                                value[0].toUpperCase() +
                                                    value.substring(1),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: statusColor,
                                                  fontWeight:
                                                      value == selectedStatus
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Active filter display
                          if (selectedStatus != 'Semua')
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              color: getStatusColor(selectedStatus)
                                  .withOpacity(0.05),
                              child: Row(
                                children: [
                                  Icon(
                                    getStatusIcon(selectedStatus),
                                    size: 16,
                                    color: getStatusColor(selectedStatus),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Menampilkan pesanan dengan status: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    selectedStatus[0].toUpperCase() +
                                        selectedStatus.substring(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: getStatusColor(selectedStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Daftar pesanan
                          Expanded(
                            child: filteredBookings.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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

                                        // Create staggered animation for each item
                                        final itemAnimation =
                                            Tween<double>(begin: 0.0, end: 1.0)
                                                .animate(
                                          CurvedAnimation(
                                            parent: _animationController,
                                            curve: Interval(
                                              (index /
                                                      filteredBookings.length) *
                                                  0.5,
                                              ((index + 1) /
                                                          filteredBookings
                                                              .length) *
                                                      0.5 +
                                                  0.5,
                                              curve: Curves.easeOut,
                                            ),
                                          ),
                                        );

                                        final startDate =
                                            DateTime.parse(item['start_date']);
                                        final endDate =
                                            DateTime.parse(item['end_date']);
                                        final durationDays = endDate
                                                .difference(startDate)
                                                .inDays +
                                            1;

                                        final dateFormat =
                                            DateFormat('dd MMM yyyy');
                                        final formattedStart =
                                            dateFormat.format(startDate);
                                        final formattedEnd =
                                            dateFormat.format(endDate);

                                        final String? originalImage =
                                            item['motor']['image'];
                                        String imageUrl = originalImage ??
                                            'https://via.placeholder.com/100';
                                        if (imageUrl.startsWith('/')) {
                                          imageUrl =
                                              "${ApiConfig.baseUrl}$imageUrl";
                                        }

                                        // Check if this is a new booking (pending status)
                                        bool isNewBooking = status == 'pending';

                                        return FadeTransition(
                                          opacity: itemAnimation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: Offset(0, 0.2),
                                              end: Offset.zero,
                                            ).animate(itemAnimation),
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 5,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                border: isNewBooking
                                                    ? Border.all(
                                                        color: Colors.orange,
                                                        width: 1.5,
                                                      )
                                                    : null,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
// Status Banner
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal:
                                                            12), // Adjusted padding
                                                    decoration: BoxDecoration(
                                                      color: getStatusColor(
                                                              status)
                                                          .withOpacity(
                                                              0.1), // Background color
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(12),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start, // Align items to the start
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              getStatusIcon(
                                                                  status),
                                                              color:
                                                                  getStatusColor(
                                                                      status),
                                                              size: 16,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              status[0]
                                                                      .toUpperCase() +
                                                                  status
                                                                      .substring(
                                                                          1),
                                                              style: TextStyle(
                                                                color:
                                                                    getStatusColor(
                                                                        status),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Badge "New" for pending orders
                                                        if (isNewBooking)
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top:
                                                                    4), // Margin for spacing
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.orange,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: Text(
                                                              'Baru',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Motor Info and Details
                                                  Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Motor Image
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.network(
                                                            imageUrl,
                                                            width: 80,
                                                            height: 80,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Container(
                                                              width: 80,
                                                              height: 80,
                                                              color: Colors
                                                                  .grey[300],
                                                              child: Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                  color: Colors
                                                                          .grey[
                                                                      500],
                                                                  size: 20),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 12),

                                                        // Details
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                item['motor'][
                                                                        'name'] ??
                                                                    'Nama tidak ada',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      primaryBlue,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .date_range,
                                                                      size: 14,
                                                                      color: Colors
                                                                              .grey[
                                                                          600]),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '$formattedStart - $formattedEnd',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .grey[700],
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .access_time,
                                                                      size: 14,
                                                                      color: Colors
                                                                              .grey[
                                                                          600]),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: primaryBlue
                                                                          .withOpacity(
                                                                              0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child: Text(
                                                                      '$durationDays hari',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            primaryBlue,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Row(
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      size: 14,
                                                                      color: Colors
                                                                              .grey[
                                                                          600]),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Expanded(
                                                                    child: Text(
                                                                      item['pickup_location'] ??
                                                                          'Lokasi tidak ada',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 4),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "Rp ${item['motor']['price_per_day']} / hari",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.green[700],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PesananPage(booking: item),
                                                                        ),
                                                                      );
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                          primaryBlue,
                                                                      foregroundColor:
                                                                          Colors
                                                                              .white,
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              6),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(6),
                                                                      ),
                                                                      minimumSize:
                                                                          Size(
                                                                              70,
                                                                              30),
                                                                    ),
                                                                    child: Text(
                                                                        'Detail',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12)),
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
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
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

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        // Filter skeleton
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // List skeleton
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}