import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/user/booking_motor/sewamotor.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/datavendor.dart';

const String baseUrl = ApiConfig.baseUrl;

class DetailMotorPage extends StatefulWidget {
  final Map<String, dynamic> motor;
  final bool isGuest;

  const DetailMotorPage({
    Key? key,
    required this.motor,
    this.isGuest = false,
  }) : super(key: key);

  @override
  _DetailMotorPageState createState() => _DetailMotorPageState();
}

class _DetailMotorPageState extends State<DetailMotorPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final Color primaryBlue = Color(0xFF2C567E);
  final Color accentColor = Color(0xFFFF9800);
  bool _isFavorite = false;

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    print("🔍 MOTOR DATA: ${widget.motor}");

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePageUser()),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DetailPesanan()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Akun()),
      );
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? "Added to favorites" : "Removed from favorites"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _isFavorite ? Colors.green : Colors.grey[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? imagePath = widget.motor["image"];
    String imageUrl;

    if (imagePath == null || imagePath.isEmpty) {
      imageUrl = "assets/images/default_motor.png";
    } else if (imagePath.startsWith("http")) {
      imageUrl = imagePath;
    } else {
      imageUrl = "$baseUrl$imagePath";
    }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
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
                child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                    size: 20),
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar motor
                Container(
                  height: 350, // Increased from 300 to 350
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: "motor-${widget.motor["id"] ?? "unknown"}",
                          child: imageUrl.startsWith("http")
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey[600]),
                                  ),
                                )
                              : Image.asset(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
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
                              stops: [0.6, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.motor["type"] ?? "Tidak Diketahui",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                        widget.motor["status"] ?? "unknown"),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusText(
                                        widget.motor["status"] ?? "unknown"),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              widget.motor["name"] ?? "Nama Tidak Diketahui",
                              style: TextStyle(
                                fontSize: 28,
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
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "${widget.motor["rating"] ?? "0.0"}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.monetization_on,
                                    color: Colors.green, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  "Rp ${widget.motor["price"] ?? "Tidak Diketahui"}/hari",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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

                // Konten
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("Deskripsi"),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          (widget.motor["description"]
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                              ? widget.motor["description"]
                              : "Tidak ada deskripsi.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSectionTitle("Informasi Motor"),
                      SizedBox(height: 16),
                      _buildInfoRow(),
                      SizedBox(height: 20),
                      _buildSectionTitle("Informasi Vendor"),
                      SizedBox(height: 16),
                      _buildVendorInfo(),
                      SizedBox(height: 30),
                      _buildBookButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isGuest: widget.isGuest,
      ),
    );
  }

  Color _getStatusColor(String status) {
    String statusLower = status.toLowerCase();
    if (statusLower == "booked") {
      return Colors.red;
    } else if (statusLower == "available" || statusLower == "tersedia") {
      return Colors.green;
    } else if (statusLower == "unavailable" ||
        statusLower == "tidak tersedia") {
      return Colors.grey;
    } else {
      return Colors.black;
    }
  }

  String _getStatusText(String status) {
    String statusLower = status.toLowerCase();
    if (statusLower == "booked") {
      return "Booked";
    } else if (statusLower == "available" || statusLower == "tersedia") {
      return "Available";
    } else if (statusLower == "unavailable" ||
        statusLower == "tidak tersedia") {
      return "Unavailable";
    } else {
      return status;
    }
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

  Widget _buildInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12, // jarak horizontal antar box
        runSpacing: 12, // jarak vertikal antar baris box
        alignment: WrapAlignment.spaceBetween, // rata kanan-kiri
        children: [
          _buildInfoBox(Icons.star, "${widget.motor["rating"] ?? "0.0"}",
              "Rating", Colors.amber),
          _buildInfoBox(
              Icons.attach_money,
              "Rp ${widget.motor["price"] ?? "Tidak Diketahui"}",
              "Harga",
              Colors.green),
          _buildInfoBox(Icons.motorcycle,
              widget.motor["type"] ?? "Tidak Diketahui", "Tipe", Colors.blue),
          _buildInfoBox(
              Icons.color_lens,
              widget.motor["color"] ?? "Tidak Diketahui",
              "Warna",
              Colors.purple),
          _buildInfoBox(Icons.branding_watermark,
              widget.motor["brand"] ?? "Tidak Diketahui", "Brand", Colors.teal),
          _buildInfoBox(
              Icons.confirmation_number,
              widget.motor["model"] ?? "Tidak Diketahui",
              "Model",
              Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String value, String label, Color color) {
    return Container(
      width: 90, // kecil agar muat banyak
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVendorInfo() {
    final vendor = widget.motor["vendor"];
    if (vendor == null) {
      return Text("Informasi vendor tidak tersedia.");
    }

    String namaKecamatan = vendor["kecamatan"]?["nama_kecamatan"]
            ?.toString()
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .trim() ??
        "Tidak Diketahui";

    return GestureDetector(
      onTap: () {
        // Redirect to vendor page when clicked
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataVendor(vendorId: vendor["id"]),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(15),
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
          border: Border.all(color: primaryBlue.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle Avatar untuk gambar vendor
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: (vendor["user"]?["profile_image"] != null &&
                          vendor["user"]["profile_image"].toString().isNotEmpty)
                      ? NetworkImage(
                          "$baseUrl${vendor["user"]["profile_image"]}")
                      : AssetImage("assets/images/default_profile.png")
                          as ImageProvider,
                ),
                SizedBox(width: 12),
                // Info Vendor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor["shop_name"] ?? "Nama Toko Tidak Diketahui",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text("Alamat: ${vendor["shop_address"] ?? "-"}",
                          style: TextStyle(fontSize: 14)),
                      Text("Kecamatan: $namaKecamatan",
                          style: TextStyle(fontSize: 14)),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          SizedBox(width: 4),
                          Text("${vendor["rating"] ?? "0"} / 5",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator for clickable
                Icon(
                  Icons.arrow_forward_ios,
                  color: primaryBlue,
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  "Tap untuk melihat detail vendor",
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton() {
    return Center(
      child: !widget.isGuest
          ? Container(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SewaMotorPage(
                          motor: widget.motor,
                          isGuest: widget.isGuest,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.motorcycle, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Book Now",
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
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "Silakan login untuk memesan.",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
