import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/vendor/chatvendor.dart';
import 'package:flutter_rentalmotor/vendor/notifikasivendor.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Import services
import 'package:flutter_rentalmotor/services/vendor/vendor_api_service.dart';
import 'package:flutter_rentalmotor/services/vendor/DashboardVendorService.dart';

// Import models
import 'package:flutter_rentalmotor/models/DashboardData.dart';

// Import components
import 'package:flutter_rentalmotor/vendor/homepage/components/overview_cards.dart';
import 'package:flutter_rentalmotor/vendor/homepage/components/status_section.dart';
import 'package:flutter_rentalmotor/vendor/homepage/components/revenue_chart.dart';
import 'package:flutter_rentalmotor/vendor/homepage/components/booking_list.dart';
import 'package:flutter_rentalmotor/vendor/homepage/components/transaction_list.dart';
import 'package:flutter_rentalmotor/vendor/homepage/components/vendor_drawer.dart';

class HomepageVendor extends StatefulWidget {
  const HomepageVendor({super.key});

  @override
  State<HomepageVendor> createState() => _DashboardState();
}

class _DashboardState extends State<HomepageVendor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Services
  final VendorApiService _apiService = VendorApiService();
  final DashboardService _dashboardService = DashboardService();

  // Vendor data
  int? vendorId;
  String? businessName;
  String? vendorAddress;
  String? vendorImagePath;
  String? vendorEmail;

  // Dashboard data
  DashboardData dashboardData = DashboardData.empty();

  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load vendor profile
      final vendorData = await _apiService.getVendorProfile();

      // Load dashboard data
      final dashboard = await _dashboardService.getDashboardData();

      setState(() {
        // Set vendor data
        vendorId = vendorData['vendorId'];
        businessName = vendorData['businessName'];
        vendorAddress = vendorData['vendorAddress'];
        vendorImagePath = vendorData['vendorImagePath'];
        vendorEmail = vendorData['vendorEmail'];

        // Set dashboard data
        dashboardData = dashboard;
      });
    } catch (e) {
      print("Error loading data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = ApiConfig.baseUrl;
    final String fullImageUrl =
        vendorImagePath != null ? '$baseUrl$vendorImagePath' : '';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1A567D),
      drawer: VendorDrawer(
        fullImageUrl: fullImageUrl,
        vendorId: vendorId,
        businessName: businessName,
        vendorAddress: vendorAddress,
        vendorEmail: vendorEmail,
        vendorImagePath: vendorImagePath,
        onLogout: () {
          // Handle logout
        },
        onProfileUpdated: _loadData,
      ),
      body: Stack(
        children: [
          // Header background
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A567D),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),

          // Main content
          Column(
            children: [
              // App bar
              SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Menu button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.white, size: 28),
                          onPressed: () =>
                              _scaffoldKey.currentState!.openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Vendor info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              businessName ?? "Vendor",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    vendorAddress ?? "Alamat belum tersedia",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            if (vendorId != null)
                              Row(
                                children: [
                                  const Icon(Icons.badge,
                                      color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    "ID: $vendorId",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          _buildHeaderButton(
                            icon: Icons.notifications_none,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotifikasiPagev()),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderButton(
                            icon: Icons.chat_bubble_outline,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Main content area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? _buildLoadingShimmer()
                      : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30)),
                          child: _buildDashboardContent(),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          isRefreshing = true;
        });
        await _loadData();
        setState(() {
          isRefreshing = false;
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dashboard title
          const Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A567D),
            ),
          ),
          const SizedBox(height: 16),

          // Overview cards
          OverviewCards(
            totalBookings: dashboardData.bookings.length,
            activeBookings: dashboardData.statusCounts['in_use']! +
                dashboardData.statusCounts['intransit']!,
            pendingBookings: dashboardData.statusCounts['pending']!,
            currentMonthRevenue: dashboardData.currentMonthRevenue,
            currencyFormatter: currencyFormatter,
          ),
          const SizedBox(height: 24),

          // Status cards
          StatusSection(statusCounts: dashboardData.statusCounts),
          const SizedBox(height: 24),

          // Revenue chart
          RevenueChart(
            monthlyRevenue: dashboardData.monthlyRevenue,
            currencyFormatter: currencyFormatter,
          ),
          const SizedBox(height: 24),

          // Recent bookings
          BookingList(
            bookings: dashboardData.bookings,
            currencyFormatter: currencyFormatter,
          ),
          const SizedBox(height: 24),

          // Recent transactions
          TransactionList(
            transactions: dashboardData.transactions,
            currencyFormatter: currencyFormatter,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard title shimmer
            Container(
              width: 150,
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(height: 20),

            // Overview cards shimmer
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status section shimmer
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                8,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart shimmer
            Container(
              width: 180,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 24),

            // Recent bookings shimmer
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
