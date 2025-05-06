import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/view/user/homepageuser.dart' as home;
import 'package:flutter_rentalmotor/view/user/profil/akun.dart';
import 'package:flutter_rentalmotor/services/vendor/daftar_pesanan_service.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/pesanan_header.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/status_filter.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/active_filter_display.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/empty_state.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/booking_item.dart';
import 'package:flutter_rentalmotor/view/user/pesanan/daftar_pesanan/components/loading_skeleton.dart';

class DetailPesanan extends StatefulWidget {
  @override
  _DetailPesananState createState() => _DetailPesananState();
}

class _DetailPesananState extends State<DetailPesanan>
    with SingleTickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  final DaftarPesananService _pesananService = DaftarPesananService();
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
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _pesananService.fetchBookings();
      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
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
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom header
          PesananHeader(
            primaryBlue: primaryBlue,
            onRefresh: fetchBookings,
          ),

          // Rest of the content
          Expanded(
            child: isLoading
                ? LoadingSkeleton()
                : bookings.isEmpty
                    ? EmptyState(
                        primaryBlue: primaryBlue,
                        onActionPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => home.HomePageUser()),
                          );
                        },
                      )
                    : Column(
                        children: [
                          // Status filter
                          StatusFilter(
                            selectedStatus: selectedStatus,
                            onStatusChanged: (value) {
                              setState(() {
                                selectedStatus = value;
                              });
                            },
                            primaryBlue: primaryBlue,
                          ),

                          // Active filter display
                          ActiveFilterDisplay(selectedStatus: selectedStatus),

                          // Daftar pesanan
                          Expanded(
                            child: filteredBookings.isEmpty
                                ? EmptyState(
                                    primaryBlue: primaryBlue,
                                    onActionPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                home.HomePageUser()),
                                      );
                                    },
                                    isFilteredEmpty: true,
                                  )
                                : RefreshIndicator(
                                    onRefresh: fetchBookings,
                                    color: primaryBlue,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(12),
                                      itemCount: filteredBookings.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredBookings[index];

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

                                        return BookingItem(
                                          item: item,
                                          animation: itemAnimation,
                                          primaryBlue: primaryBlue,
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
}
