import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/detailmotor.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/user/chat/chat_page.dart';
import 'package:flutter_rentalmotor/services/vendor_service.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/services/chat_services.dart';

class DataVendor extends StatefulWidget {
  final int vendorId;
  final bool isGuest; // Tambahkan ini

  const DataVendor({
    Key? key,
    required this.vendorId,
    this.isGuest = false, // Default false
  }) : super(key: key);

  @override
  _DataVendorState createState() => _DataVendorState();
}

class _DataVendorState extends State<DataVendor>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  Map<String, dynamic>? _vendorData;
  List<Map<String, dynamic>> _motorList = [];
  List<Map<String, dynamic>> _reviewList = [];
  bool _isLoading = true;
  int? _userId; // Menyimpan user ID
  String _errorMessage = '';
  final VendorService _vendorService = VendorService();
  late TabController _tabController;

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color accentBlue = Color(0xFF64B5F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserId(); // Ambil user ID dari penyimpanan
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
    Future<List<Map<String, dynamic>>> fetchReviewsByMotor(int vendorId) async {
    final response = await http
        .get(Uri.parse('http://localhost:8080/reviews/motor/$vendorId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<void> _fetchReviewData() async {
    try {
      final reviews = await _vendorService.fetchReviewsByMotor(widget.vendorId);
      setState(() => _reviewList = reviews);
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    }
  }

  /// Mengambil user ID dari SharedPreferences
  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id'); // Ambil ID pengguna
    });
  }



  Future<void> _fetchData() async {
    try {
      final vendor = await _vendorService.fetchVendorById(widget.vendorId);
      setState(() {
        _vendorData = vendor;
      });
    } catch (e) {
      setState(() => _errorMessage = "Error: $e");
    }
    await _fetchMotorData();
    await _fetchReviewData();

    setState(() => _isLoading = false);
  }

  Future<void> _fetchMotorData() async {
    try {
      final motorList =
          await _vendorService.fetchMotorsByVendor(widget.vendorId);
      setState(() => _motorList = motorList);
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
    String? vendorImage = _vendorData?['user']?['profile_image'];
    String fullVendorImageUrl =
        vendorImage != null && !vendorImage.startsWith("http")
            ? "${ApiConfig.baseUrl}$vendorImage"
            : vendorImage ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: primaryBlue, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline,
                            size: 60, color: Colors.red),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Oops! Something went wrong",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: 150,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3E8EDE), primaryBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _fetchData,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Try Again",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Vendor Header with Image
                    Container(
                      height: 300,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          // Vendor Image
                          Positioned.fill(
                            child: fullVendorImageUrl.isNotEmpty
                                ? Image.network(
                                    fullVendorImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.store,
                                        size: 60,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.store,
                                      size: 60,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                          ),
                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Vendor Info
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Vendor",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _vendorData?['shop_name'] ??
                                      "Nama Tidak Diketahui",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _vendorData?['shop_address'] ??
                                            "Alamat Tidak Diketahui",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    ...List.generate(5, (index) {
                                      double rating = double.tryParse(
                                              _vendorData?['rating']
                                                      ?.toString() ??
                                                  "0") ??
                                          0;
                                      return Icon(
                                        index < rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      );
                                    }),
                                    SizedBox(width: 8),
                                    Text(
                                      "${_vendorData?['rating'] ?? '0.0'}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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

                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: primaryBlue,
                        labelColor: primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: "About"),
                          Tab(text: "Motors"),
                          Tab(text: "Ulasan"),
                        ],
                      ),
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // About Tab
                          SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("Tentang Vendor"),
                                SizedBox(height: 16),
                                Text(
                                  _vendorData?['shop_description'] ??
                                      "Deskripsi tidak tersedia",
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 24),
                                _buildSectionTitle("Informasi Kontak"),
                                SizedBox(height: 16),
                                _buildContactItem(Icons.phone, "Phone",
                                    _vendorData?['phone'] ?? "Tidak tersedia"),
                                _buildContactItem(Icons.email, "Email",
                                    _vendorData?['email'] ?? "Tidak tersedia"),
                                _buildContactItem(Icons.access_time,
                                    "Jam Operasional", "08:00 - 20:00"),
                                SizedBox(height: 24),
                                _buildSectionTitle("Lokasi"),

                                SizedBox(height: 16),
                                // Changed location display to match contact information style
                                _buildContactItem(
                                    Icons.location_on,
                                    "Alamat",
                                    _vendorData?['shop_address'] ??
                                        "Alamat tidak tersedia"),
                                SizedBox(height: 20),
                                _buildContactButton(),
                                SizedBox(height: 20),
                                ChatVendorButton(
                                  vendorId: _vendorData?['user_id'] ??
                                      _vendorData?['id'] ??
                                      0,
                                  vendorData:
                                      _vendorData, // Kirim vendorData ke ChatVendorButton
                                ),
                              ],
                            ),
                          ),

                          // Motors Tab
                          _motorList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.motorcycle_outlined,
                                          size: 60,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        "Tidak ada motor tersedia",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Vendor ini belum menambahkan motor",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  itemCount: _motorList.length,
                                  itemBuilder: (context, index) {
                                    return _buildMotorCard(_motorList[index]);
                                  },
                                ),
                          _reviewList.isEmpty
                              ? Center(
                                  child: Text("Tidak ada ulasan tersedia"),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  itemCount: _reviewList.length,
                                  itemBuilder: (context, index) {
                                    return _buildReviewCard(_reviewList[index]);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: widget.isGuest,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
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
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review['customer']['name'] ?? "Nama Tidak Diketahui",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Rating: ${review['rating']}"),
            SizedBox(height: 8),
            Text(review['review'] ?? "Tidak ada ulasan"),
            SizedBox(height: 8),
            Text(
                "Dibalas oleh vendor: ${review['vendor_reply'] ?? "Tidak ada balasan"}"),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E8EDE), primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Contacting vendor..."),
                behavior: SnackBarBehavior.floating,
                backgroundColor: primaryBlue,
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Contact Vendor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotorCard(Map<String, dynamic> motor) {
    String? imageUrl = motor["image"];
    String fullImageUrl = imageUrl != null && !imageUrl.startsWith("http")
        ? "${ApiConfig.baseUrl}$imageUrl"
        : imageUrl ?? "";

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailMotorPage(
                motor: motor,
                isGuest: _userId == null, // Jika _userId null, berarti guest
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motor Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 30,
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image_not_supported,
                        size: 30,
                        color: Colors.grey[500],
                      ),
                    ),
            ),

            // Motor Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motor["name"] ?? "Nama Tidak Ada",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.monetization_on,
                            size: 16, color: Colors.green[700]),
                        SizedBox(width: 6),
                        Text(
                          "${formatRupiah(int.parse(motor["price"].toString()))}/hari",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          "${motor["rating"] ?? "0.0"}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3E8EDE), primaryBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "View Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatVendorButton extends StatelessWidget {
  final int vendorId; // This should be passed from the parent widget
  final Map<String, dynamic>? vendorData; // Tambahkan parameter ini

  const ChatVendorButton({
    Key? key,
    required this.vendorId, // Make it required
    required this.vendorData, // Tambahkan ini
  }) : super(key: key);

  Future<void> _startChat(BuildContext context) async {
    try {
      final chatRoom = await ChatService.getOrCreateChatRoom(
        vendorId: vendorId, // Use the vendorId passed to the widget
      );

      if (chatRoom != null) {
        final prefs = await SharedPreferences.getInstance();
        final customerId = prefs.getInt('user_id');

        if (customerId != null) {
          // Ambil receiverId dari vendorData
          final receiverId = vendorData?['user_id'] ?? vendorData?['id'] ?? 0;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                chatRoomId: chatRoom['id'],
                // senderId: customerId,
                receiverId: receiverId, // Kirim receiverId yang benar
                receiverName: vendorData?['shop_name'] ?? 'Nama Penerima',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Silakan login untuk mulai chat')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai chat')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E8EDE), Color(0xFF2C567E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2C567E).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startChat(context),
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Chat Vendor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
