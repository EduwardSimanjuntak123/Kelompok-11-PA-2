import 'dart:convert'; // Untuk JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/detailmotor.dart';
import 'package:flutter_rentalmotor/user/notifikasi.dart';
import 'package:flutter_rentalmotor/user/chat.dart';
import 'package:flutter_rentalmotor/user/akun.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/datavendor.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/homepage_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:badges/badges.dart' as badges;

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
  // List untuk menyimpan pesan notifikasi yang diterima
  // Sekarang menggunakan struktur data Map agar bisa menyimpan status 'read' dan 'timestamp'
  List<Map<String, dynamic>> _notifications = [];
  int get _unreadCount {
    return _notifications.where((notif) => notif['read'] == false).length;
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchKecamatan();
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

  /// Tampilkan notifikasi lokal dengan judul dan pesan
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
      0, // ID notifikasi
      title, // Judul notifikasi
      message, // Isi pesan
      platformChannelSpecifics,
      payload: 'data', // opsional
    );
  }

  /// Mengambil data user dari SharedPreferences dan inisialisasi koneksi WebSocket
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

    // Jika user id tersedia, buat koneksi WebSocket
    if (_userId != null) {
      _connectWebSocket(_userId!);
    }
  }

  /// Membuat koneksi WebSocket dengan parameter user id dan mendengarkan pesan masuk
  void _connectWebSocket(int userId) {
    String wsUrl = "ws://192.168.132.159:8080/ws?user_id=$userId";
    _channel = IOWebSocketChannel.connect(wsUrl);
    _channel?.stream.listen((data) async {
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
      print("WebSocket error: $error");
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

  /// Menampilkan notifikasi sebagai popup dialog (opsional)
  void _showNotificationPopup(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notifikasi Baru"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    // Proteksi untuk guest
    if (_userId == null && (index == 1 || index == 2)) {
      _showLoginRequiredAlert();
      return;
    }
    if (index == 2) {
      // Akun
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const Akun()));
      _loadUserData();
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      // Pesanan
      await Navigator.of(context)
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

  void _showLoginRequiredAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: primaryBlue),
            SizedBox(width: 10),
            Text("Login Diperlukan"),
          ],
        ),
        content: const Text(
            "Anda harus login terlebih dahulu untuk mengakses fitur ini."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
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
        SizedBox(width: 5),
        Text(
          rating,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter vendor berdasarkan kecamatan yang dipilih
    List<Map<String, dynamic>> filteredVendorList = _selectedKecamatan ==
            "Semua"
        ? _vendorList
        : _vendorList.where((vendor) {
            String vendorKecamatan =
                vendor["kecamatan"]?["nama_kecamatan"]?.toString().trim() ?? "";
            return vendorKecamatan == _selectedKecamatan;
          }).toList();

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
              _buildVendorSection(filteredVendorList),
              _buildMotorSection(),
            ],
          ),
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
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: "Pesanan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, Color(0xFF3E8EDE)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              badges.Badge(
                showBadge: _unreadCount > 0,
                badgeContent: Text(
                  _unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                position: badges.BadgePosition.topEnd(top: -5, end: -5),
                child: IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {
                    // Kirim _notifications (List<Map<String, dynamic>>) ke NotifikasiPage
                    Navigator.of(context)
                        .push<List<Map<String, dynamic>>>(
                      MaterialPageRoute(
                        builder: (context) =>
                            NotifikasiPage(notifications: _notifications),
                      ),
                    )
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
              IconButton(
                icon: Image.asset("assets/images/chat.png",
                    width: 24, height: 24),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            "Temukan Motor Rental Terbaik",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: primaryBlue, size: 20),
          SizedBox(width: 10),
          Text(
            "Filter Kecamatan:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
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
          padding: EdgeInsets.fromLTRB(20, 10, 20, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
              TextButton(
                onPressed: () {
                  // View all vendors
                },
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
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
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Vendor tidak ada pada kecamatan yang dipilih",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SizedBox(
                height:
                    200, // Increased height for vendor cards to prevent overflow
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

                    return _buildVendorCard(
                      vendor["shop_name"] ?? "Vendor Tidak Diketahui",
                      vendor["rating"]?.toString() ?? "0",
                      imageUrl,
                      vendor["id"],
                      kecamatan,
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
          padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
              TextButton(
                onPressed: () {
                  // View all motors
                },
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w600,
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
                margin: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.motorcycle_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Tidak ada motor tersedia",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SizedBox(
                height: 220, // Fixed height for motor cards
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

                    return _buildMotorCard(
                      motor["name"] ?? "Nama Tidak Diketahui",
                      motor["rating"]?.toString() ?? "0",
                      "Rp $formattedPrice/hari",
                      imageUrl,
                      DetailMotorPage(
                        motor: motor,
                        isGuest: _userId == null,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildMotorCard(String title, String rating, String price,
      String imageUrl, Widget detailPage) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => detailPage));
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset("assets/images/default_motor.png",
                    height: 80, width: double.infinity, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            _buildRatingDisplay(rating),
            Text(
              price,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorCard(String shopName, String rating, String imageUrl,
      int vendorId, String kecamatan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DataVendor(vendorId: vendorId)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 80,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset("assets/images/default_vendor.png",
                    height: 80, width: double.infinity, fit: BoxFit.cover);
              },
            ),
            const SizedBox(height: 5),
            Text(
              shopName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            _buildRatingDisplay(rating),
            const SizedBox(height: 3),
            Text(
              "Kecamatan: $kecamatan",
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
