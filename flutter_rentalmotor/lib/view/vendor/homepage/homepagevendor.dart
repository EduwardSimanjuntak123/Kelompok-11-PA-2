import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/view/vendor/notifikasivendor.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/view/vendor/chat_room_list_page.dart';

import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Import services
import 'package:flutter_rentalmotor/services/vendor/vendor_api_service.dart';
import 'package:flutter_rentalmotor/services/vendor/DashboardVendorService.dart';

// Import models
import 'package:flutter_rentalmotor/models/DashboardData.dart';
import 'package:flutter_rentalmotor/services/web_socket_channel/websocket_service.dart';
// Import components
import 'package:flutter_rentalmotor/view/vendor/homepage/components/overview_cards.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/components/status_section.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/components/revenue_chart.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/components/booking_list.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/components/transaction_list.dart';
import 'package:flutter_rentalmotor/view/vendor/homepage/components/vendor_drawer.dart';

class HomepageVendor extends StatefulWidget {
  const HomepageVendor({super.key});

  @override
  State<HomepageVendor> createState() => _DashboardState();
}

class _DashboardState extends State<HomepageVendor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  int? _userId;
  // Services
  final VendorApiService _apiService = VendorApiService();
  final DashboardService _dashboardService = DashboardService();

  // WebSocket & notifikasi
  IOWebSocketChannel? _channel;
  List<Map<String, dynamic>> _notifications = [];
  int get _unreadCount =>
      _notifications.where((n) => n['read'] == false).length;

  final FlutterLocalNotificationsPlugin _localNotifPlugin =
      FlutterLocalNotificationsPlugin();

  // Vendor data
  int? vendorId;
  int? vendorUserId;
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
    
    _initLocalNotifications();
    _loadData();
    _loadNotifications();
    // WebSocket akan dikoneksikan setelah vendorId tersedia
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifPlugin.initialize(initSettings);
  }

  void _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'vendor_channel',
      'Vendor Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifPlugin.show(
      DateTime.now().millisecond, // unique ID
      title,
      body,
      notificationDetails,
    );
  }

  List<Map<String, dynamic>> _chatRooms = [];

  Future<void> _fetchChatRooms() async {
    if (_userId == null) return;

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/chat/rooms?user_id=$_userId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _chatRooms = List<Map<String, dynamic>>.from(data['chat_rooms']);
        });
      } else {
        print('Gagal mengambil chat rooms: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat rooms: $e');
    }
  }

  void _connectWebSocket(int userId) {
    // Tutup koneksi yang ada jika ada
    _channel?.sink.close();

    final wsUrl = "${ApiConfig.wsUrl}/ws/notifikasi?user_id=$userId";
    debugPrint("user id untuk notifiaksi: $userId");
    debugPrint("http untuk notifiaksi: $wsUrl");

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen((data) async {
      debugPrint("WS notifikasi: $data");
      try {
        final outer = json.decode(data);
        final inner = json.decode(outer['message']);
        final bookingId = inner['booking_id'];
        final message = inner['message'];

        final newNotification = {
          'text': "Booking #$bookingId: $message",
          'read': false,
          'timestamp': DateTime.now().toIso8601String(),
        };

        setState(() => _notifications.insert(0, newNotification));
        await _saveNotifications();

        _showLocalNotification("Booking #$bookingId", message);
      } catch (e) {
        debugPrint("Error parsing notification: $e");
        final fallbackNotification = {
          'text': data.toString(),
          'read': false,
          'timestamp': DateTime.now().toIso8601String(),
        };
        setState(() => _notifications.insert(0, fallbackNotification));
        await _saveNotifications();
      }
    }, onError: (e) {
      debugPrint("WebSocket error: $e");
      // Coba koneksi ulang setelah beberapa detik
      Future.delayed(const Duration(seconds: 5), () {
        if (vendorUserId != null) _connectWebSocket(vendorUserId!);
      });
    }, onDone: () {
      debugPrint("WebSocket connection closed");
      // Coba koneksi ulang setelah beberapa detik
      Future.delayed(const Duration(seconds: 5), () {
        if (vendorUserId != null) _connectWebSocket(vendorUserId!);
      });
    });
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('vendor_notifications', json.encode(_notifications));
    } catch (e) {
      debugPrint("Error saving notifications: $e");
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString('vendor_notifications');
      if (notificationsString != null) {
        final List loaded = json.decode(notificationsString);
        setState(
            () => _notifications = List<Map<String, dynamic>>.from(loaded));
      }
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    }
  }

  Widget _buildNotifikasiButton() {
    return Stack(
      children: [
        _buildHeaderButton(
          icon: Icons.notifications_none,
          onTap: () async {
            // Tandai semua notifikasi sebagai dibaca
            setState(() {
              for (var notification in _notifications) {
                notification['read'] = true;
              }
            });
            await _saveNotifications();

            // Navigasi ke halaman notifikasi
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotifikasiPagev(userId: vendorUserId!),
              ),
            );
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Center(
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Load data vendor
      final vendorData = await _apiService.getVendorProfile();

      // Load data dashboard
      final dashboardDataResponse = await _dashboardService.getDashboardData();

      // Pengecekan tipe sebelum menetapkan
      dashboardData = dashboardDataResponse;
    
      setState(() {
        // Set data vendor dengan pengecekan null
        vendorId = vendorData['vendorId'];
        vendorUserId = vendorData['vendorUserId'];
        businessName = vendorData['businessName'] ?? 'Nama Bisnis Tidak Ada';
        vendorAddress = vendorData['vendorAddress'] ?? 'Alamat Tidak Ada';
        vendorImagePath = vendorData['vendorImagePath'] ?? 'default_image_path';
        vendorEmail = vendorData['vendorEmail'] ?? 'Email Tidak Ada';
      });

      // Koneksi WebSocket setelah vendorId tersedia
      if (vendorUserId != null) {
        _connectWebSocket(vendorUserId!);
      }
    } catch (e) {
      print("Error memuat data: $e");
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
                              key: Key('homepageTitle'),
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
                          ],
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          _buildNotifikasiButton(),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Image.asset(
                              "assets/images/chat.png",
                              width: 24,
                              height: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const ChatRoomListPage()))
                                  .then((_) {
                                // Refresh chat rooms setelah kembali dari halaman chat
                                _fetchChatRooms();
                              });
                            },
                          ),
                        ],
                      )
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
            activeBookings: dashboardData.statusCounts['in use']! +
                dashboardData.statusCounts['in transit']!,
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
