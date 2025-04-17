import 'dart:convert'; // Untuk JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/detailmotor.dart';
import 'package:flutter_rentalmotor/user/notifikasi/notifikasi.dart';
import 'package:flutter_rentalmotor/user/chat/chat_room_list_page.dart';

import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/MotorListPage.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/VendorListPage.dart';

import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/datavendor.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/homepage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';

const Color primaryBlue = Color(0xFF2196F3);

class HomePageUser extends StatefulWidget {
  const HomePageUser({Key? key}) : super(key: key);

  @override
  _HomePageUserState createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _selectedIndex = 0;
  String _userName = "Pengguna";
  int? _userId;
  bool _isLoading = true;

  List<Map<String, dynamic>> _motorList = [];
  List<Map<String, dynamic>> _vendorList = [];
  List<Map<String, dynamic>> _kecamatanList = [];
  String _selectedKecamatan = "Semua"; // Default: tampilkan semua
  final String baseUrl = ApiConfig.baseUrl;

  WebSocketChannel? _channel;
  // List notifikasi
  List<Map<String, dynamic>> _notifications = [];
  int get _unreadCount {
    return _notifications.where((notif) => notif['read'] == false).length;
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchKecamatan();
    _requestNotificationPermission();
    _initializeLocalNotifications();
  }

  /// Inisialisasi Local Notification
  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (details) {
      debugPrint("Notification clicked with payload: ${details.payload}");
    });
  }

  /// Tampilkan notifikasi lokal
  Future<void> _showLocalNotification(String title, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id', // ID channel unik
      'Notifikasi Masuk',
      channelDescription: 'Channel untuk notifikasi dari vendor',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
      payload: 'data',
    );
  }

  /// Cek status login dan ambil user_name dari SharedPreferences
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userName = prefs.getString('user_name');

    setState(() {
      _userId = userId;
      _userName = userName ?? "Pengguna";
    });

    _fetchVendors();
    _fetchMotors();

    // Kalau user_id tersedia, buat koneksi WebSocket
    if (_userId != null) {
      _connectWebSocket(_userId!);
    }
  }

  /// Membuat koneksi WebSocket
  void _connectWebSocket(int userId) {
    print({
      {userId}
    });
    String wsUrl = "ws://192.168.95.159:8080/ws/notifikasi?user_id=$userId";
    _channel = IOWebSocketChannel.connect(wsUrl);

    // Log untuk memverifikasi jika WebSocket terhubung
    _channel?.stream.listen((data) async {
      debugPrint(
          "WebSocket connected: $wsUrl"); // Log untuk memastikan WebSocket berhasil terhubung
      debugPrint(
          "Received data: $data"); // Log untuk melihat data yang diterima

      try {
        final Map<String, dynamic> outer = json.decode(data);
        final Map<String, dynamic> inner = json.decode(outer['message']);
        final int bookingId = inner['booking_id'];
        final String message = inner['message'];

        final newNotification = {
          'text': "Booking #$bookingId: $message",
          'read': false,
          'timestamp': DateTime.now().toIso8601String(),
        };

        setState(() {
          _notifications.add(newNotification);
        });
        await _saveNotificationToPrefs();

        _showNotificationPopup("Booking #$bookingId: $message");
        _showLocalNotification("Booking #$bookingId", message);
      } catch (e) {
        final fallbackNotification = {
          'text': data.toString(),
          'read': false,
          'timestamp': DateTime.now().toIso8601String(),
        };

        setState(() {
          _notifications.add(fallbackNotification);
        });
        await _saveNotificationToPrefs();
        _showNotificationPopup(data.toString());
      }
    }, onError: (error) {
      debugPrint(
          "WebSocket error: $error"); // Log untuk menampilkan error jika ada masalah dengan WebSocket
    });
  }

  Future<void> _saveNotificationToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notification_list', json.encode(_notifications));
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

          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorMessage("Gagal mengambil data motor!");
      setState(() => _isLoading = false);
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

  Future<void> _fetchKecamatan() async {
    try {
      List<Map<String, dynamic>> kecamatan =
          await HomePageApi().fetchKecamatan();
      if (mounted) {
        setState(() {
          _kecamatanList = kecamatan;
        });
      }
    } catch (e) {
      _showErrorMessage("Gagal mengambil data kecamatan!");
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showNotificationPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifikasi Baru"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Akun()));
      _loadUserData();
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DetailPesanan()));
      setState(() {
        _selectedIndex = 0;
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Helper widget untuk menampilkan rating
  Widget _buildRatingDisplay(String rating) {
    double ratingValue = double.tryParse(rating) ?? 0.0;
    return Row(
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < ratingValue ? Icons.star : Icons.star_border,
            size: 14,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 5),
        Text(
          rating,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
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
          // Baris pertama: jika guest tampilkan tombol login, jika tidak tampilkan notifikasi dan chat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_userId == null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    elevation: 3,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.login, size: 20),
                  label: const Text("Login",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              else ...[
                // Notifikasi dengan badge yang menampilkan jumlah pesan belum dibaca
                badges.Badge(
                  showBadge: _unreadCount > 0,
                  badgeContent: Text(
                    _unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.red,
                    elevation: 2,
                  ),
                  position: badges.BadgePosition.topEnd(top: -5, end: -5),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: () {
                        Navigator.of(context)
                            .push<List<Map<String, dynamic>>>(MaterialPageRoute(
                          builder: (context) =>
                              NotifikasiPage(notifications: _notifications),
                        ))
                            .then((updatedNotifications) {
                          if (updatedNotifications != null) {
                            setState(() {
                              _notifications = updatedNotifications;
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
                // Icon chat yang juga memiliki badge jika ada pesan yang belum dibaca
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Image.asset("assets/images/chat.png",
                        width: 24, height: 24),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const ChatRoomListPage()),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),
          // Greeting username with improved styling
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $_userName!",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.motorcycle,
                        color: Colors.white.withOpacity(0.9), size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Temukan Motor Rental Terbaik",
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
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                "Filter Kecamatan",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedKecamatan,
                icon: Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                items: _buildDropdownItems(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedKecamatan = newValue;
                    });
                  }
                },
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    List<DropdownMenuItem<String>> items = [];
    items.add(const DropdownMenuItem(
      value: "Semua",
      child: Text("Semua"),
    ));
    for (var kec in _kecamatanList) {
      String nama = kec["nama_kecamatan"]?.toString().trim() ?? "";
      if (nama.isNotEmpty) {
        items.add(DropdownMenuItem(
          value: nama,
          child: Text(nama),
        ));
      }
    }
    return items;
  }

  Widget _buildVendorSection(List<Map<String, dynamic>> vendorList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(Icons.store, color: primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Daftar Vendor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VendorListPage(isGuest: _userId == null),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward, size: 16, color: primaryBlue),
                  label: Text(
                    "Lihat Semua",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
        vendorList.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.store_outlined,
                        size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    const Text(
                      "Vendor tidak ada pada kecamatan yang dipilih",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: vendorList.length,
                  itemBuilder: (context, index) {
                    final vendor = vendorList[index];
                    String path =
                        vendor["user"]["profile_image"]?.toString().trim() ??
                            "";
                    String imageUrl = path.isNotEmpty
                        ? (path.startsWith("http") ? path : "$baseUrl$path")
                        : "assets/images/default_vendor.png";
                    String kecamatan = vendor["kecamatan"]?["nama_kecamatan"]
                            ?.toString()
                            .trim() ??
                        "Tidak Diketahui";

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DataVendor(vendorId: vendor["id"])));
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            )
                          ],
                          border: Border.all(color: Colors.blue.shade50),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 100,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                      "assets/images/default_vendor.png",
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendor["shop_name"] ??
                                        "Vendor Tidak Diketahui",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5),
                                  _buildRatingDisplay(
                                      vendor["rating"]?.toString() ?? "0"),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 12, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          kecamatan,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildMotorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(Icons.motorcycle, color: primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Rekomendasi Motor",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MotorListPage(isGuest: _userId == null),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward, size: 16, color: primaryBlue),
                  label: Text(
                    "Lihat Semua",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
        _motorList.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.motorcycle_outlined,
                        size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    const Text(
                      "Tidak ada motor tersedia",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _motorList.length,
                  itemBuilder: (context, index) {
                    final motor = _motorList[index];

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
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DetailMotorPage(
                                  motor: motor,
                                  isGuest: _userId == null,
                                )));
                      },
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(color: Colors.blue.shade50),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar motor with status badge
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/default_motor.png",
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                // Status badge
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (motor["status"] ?? "unknown") ==
                                              "available"
                                          ? Colors.green
                                          : (motor["status"] ?? "unknown") ==
                                                  "booked"
                                              ? Colors.red
                                              : Colors.grey,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      (motor["status"] ?? "unknown") == "booked"
                                          ? "in use"
                                          : (motor["status"] ?? "unknown"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Konten teks
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    motor["name"] ?? "Nama Tidak Diketahui",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.category,
                                          size: 12, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        "Type: ${motor["type"] ?? "unknown"}",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 12, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          (motor["vendor"]?["kecamatan"]
                                                      ?["nama_kecamatan"]
                                                  ?.toString()
                                                  .replaceAll('\r', '')
                                                  .replaceAll('\n', '')
                                                  .trim()) ??
                                              "Tidak Diketahui",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6),
                                  _buildRatingDisplay(
                                      motor["rating"]?.toString() ?? "0"),
                                  SizedBox(height: 6),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.green.shade200),
                                    ),
                                    child: Text(
                                      "Rp $formattedPrice/hari",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
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
          await _fetchKecamatan();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildFilterSection(),
              _buildVendorSection(_selectedKecamatan == "Semua"
                  ? _vendorList
                  : _vendorList.where((vendor) {
                      String vendorKecamatan = vendor["kecamatan"]
                                  ?["nama_kecamatan"]
                              ?.toString()
                              .trim() ??
                          "";
                      return vendorKecamatan == _selectedKecamatan;
                    }).toList()),
              _buildMotorSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: _userId == null,
      ),
    );
  }
}
