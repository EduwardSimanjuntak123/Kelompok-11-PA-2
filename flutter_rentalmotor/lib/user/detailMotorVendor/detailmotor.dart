import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/widgets/custom_bottom_navbar.dart';
import 'package:flutter_rentalmotor/user/booking_motor/sewamotor.dart';
import 'package:flutter_rentalmotor/user/pesanan/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/user/detailMotorVendor/datavendor.dart';
import 'package:flutter_rentalmotor/services/customer/detail_motor_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = ApiConfig.baseUrl;

class DetailMotorPage extends StatefulWidget {
  final int motorId;
  final bool isGuest;
  final String baseUrl = ApiConfig.baseUrl;

  const DetailMotorPage({
    Key? key,
    required this.motorId,
    this.isGuest = false,
  }) : super(key: key);

  @override
  _DetailMotorPageState createState() => _DetailMotorPageState();
}

Future<List<Map<String, dynamic>>> fetchReviewsForMotor(int motorId) async {
  final response = await http.get(Uri.parse('$baseUrl/reviews/motor/$motorId'));

  if (response.statusCode == 200) {
    // Successfully fetched the reviews
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    // Handle error response
    throw Exception('Failed to load reviews');
  }
}

class _DetailMotorPageState extends State<DetailMotorPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? motor;
  bool _isLoadingMotor = true;
  int _selectedIndex = 0;
  final Color primaryBlue = Color(0xFF2C567E);
  final Color accentColor = Color(0xFFFF9800);
  
  // Removed _isFavorite variable

  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Map<String, dynamic>> _reviewList = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    fetchMotorDetail();
    _initAnimation();
  }

  void _initAnimation() {
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

    _animationController.forward();
  }

  Future<void> fetchMotorDetail() async {
    try {
      final result = await DetailMotorApi.fetchMotorById(widget.motorId);
      if (result != null) {
        setState(() {
          motor = result;
        });
        await fetchMotorReviews(); // fetch reviews setelah motor berhasil
      }
    } catch (e) {
      print('Error fetching motor detail: $e');
      // Tambahkan penanganan error yang lebih baik
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail motor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMotor = false;
        });
      }
    }
  }

  Future<void> fetchMotorReviews() async {
    try {
      if (motor != null && motor!["id"] != null) {
        final motorId = motor!["id"];
        // Pastikan motorId adalah int
        final int motorIdInt =
            motorId is int ? motorId : int.tryParse(motorId.toString()) ?? 0;

        if (motorIdInt > 0) {
          final reviews = await fetchReviewsForMotor(motorIdInt);
          if (mounted) {
            setState(() {
              _reviewList = reviews;
              _isLoadingReviews = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingReviews = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingReviews = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
      print("Error fetching reviews: $e");
    }
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

  // Removed _toggleFavorite function

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading indicator jika data masih dimuat
    if (_isLoadingMotor) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryBlue,
          elevation: 0,
          title: Text("Detail Motor"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryBlue),
              SizedBox(height: 16),
              Text(
                "Memuat detail motor...",
                style:
                    TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    String? imagePath = motor?["image"] ?? "";
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
<<<<<<< HEAD
        // Removed favorite button from actions
=======
>>>>>>> 8e7df6ab8f86bcd16a78884eec6413fae465dcbd
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
                  height: 350, 
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: "motor-${motor?["id"] ?? ""}",
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
                                    motor?["type"] ?? "Tidak Diketahui",
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
                                        motor?["color"] ?? "Tidak Diketahui"),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusText(
                                        motor?["color"] ?? "Tidak Diketahui"),
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
                              motor?["name"] ?? "Tidak Diketahui",
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
                                  "${motor != null ? (motor!["rating"] != null ? motor!["rating"].toString() : "0") : "0"}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 16),
                                
                                SizedBox(width: 4),
                                Text(
                                  "Rp ${_formatCurrency(motor != null ? (motor!["price"] ?? 0) : 0)}/hari",
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
                          (motor?["description"]
                                      ?.toString()
                                      .trim()
                                      .isNotEmpty ??
                                  false)
                              ? motor!["description"]
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

                      // Ulasan Motor - Dipindahkan sebelum tombol Book Now
                      _buildSectionTitle("Ulasan"),
                      SizedBox(height: 16),
                      _isLoadingReviews
                          ? Center(child: CircularProgressIndicator())
                          : _reviewList.isEmpty
                              ? Center(child: Text("Belum ada ulasan"))
                              : Column(
                                  children: _reviewList.map((review) {
                                    return _buildReviewCard(review);
                                  }).toList(),
                                ),
                      SizedBox(height: 20), 

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

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama dan Rating Pengguna
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: review['customer'] != null &&
                          review['customer']['profile_image'] != null
                      ? NetworkImage(
                          '${ApiConfig.baseUrl}${review['customer']['profile_image']}')
                      : null,
                  child: review['customer'] == null ||
                          review['customer']['profile_image'] == null
                      ? Icon(Icons.person, size: 24, color: Colors.white)
                      : null,
                  radius: 20,
                ),
                SizedBox(width: 12),
                Text(
                  review['customer'] != null
                      ? (review['customer']['name'] ?? "Nama Tidak Diketahui")
                      : "Nama Tidak Diketahui",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Bintang Rating
            Row(
              children: [
                () {
                  double rating = 0;
                  if (review['rating'] == null) {
                    rating = 0;
                  } else if (review['rating'] is int) {
                    rating = (review['rating'] as int).toDouble();
                  } else if (review['rating'] is String) {
                    rating = double.tryParse(review['rating'] as String) ?? 0.0;
                  } else if (review['rating'] is double) {
                    rating = review['rating'];
                  }
                  return Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  );
                }(),
              ],
            ),
            SizedBox(height: 10),

            // Isi Ulasan dengan Kutipan
            Text(
              '"${review['review'] ?? "Tidak ada ulasan"}"',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 8),

            // Balasan Vendor (jika ada)
            if (review['vendor_reply'] != null)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Balasan Vendor: ${review['vendor_reply']}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[800],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
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

  Color getMotorColor(String colorName) {
  switch (colorName.toLowerCase()) {
    case "putih":
      return Colors.black;
    case "hitam":
      return Colors.white;
    case "merah":
      return Colors.red;
    case "biru":
      return Colors.blue;
    case "kuning":
      return Colors.amber;
    case "abu":
    case "abu-abu":
      return Colors.grey;
    default:
      return Colors.purple; // fallback jika warna tidak dikenali
  }
}

Widget _buildInfoRow() {
  final String motorColor = motor != null
      ? (motor!["color"]?.toString() ?? "Tidak Diketahui")
      : "Tidak Diketahui";

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _buildInfoBox(
            Icons.star,
            "${motor != null ? (motor!["rating"] != null ? motor!["rating"].toString() : "0") : "0"}",
            "Rating",
            Colors.amber),
        _buildInfoBox(
          FontAwesomeIcons.rupiahSign,
          "Rp ${_formatCurrency(motor != null ? (motor!["price"] ?? 0) : 0)}",
          "Harga",
          Colors.green,
        ),
        _buildInfoBox(
            Icons.motorcycle,
            motor != null
                ? (motor!["type"]?.toString() ?? "Tidak Diketahui")
                : "Tidak Diketahui",
            "Tipe",
            Colors.blue),
        _buildInfoBox(
            Icons.color_lens,
            motorColor,
            "Warna",
            getMotorColor(motorColor)),
        _buildInfoBox(
            Icons.branding_watermark,
            motor != null
                ? (motor!["brand"]?.toString() ?? "Tidak Diketahui")
                : "Tidak Diketahui",
            "Brand",
            Colors.teal),
        _buildInfoBox(
            Icons.confirmation_number,
            motor != null
                ? (motor!["year"]?.toString() ?? "Tidak Diketahui")
                : "Tidak Diketahui",
            "Tahun",
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
    final vendor = motor?["vendor"];
    if (vendor == null) {
      return Text("Informasi vendor tidak tersedia.");
    }

    String namaKecamatan = vendor["kecamatan"] != null &&
            vendor["kecamatan"]["nama_kecamatan"] != null
        ? vendor["kecamatan"]["nama_kecamatan"]
            .toString()
            .replaceAll('\r', '')
            .replaceAll('\n', '')
            .trim()
        : "Tidak Diketahui";

    return GestureDetector(
      onTap: () {
        // Redirect to vendor page when clicked
        if (vendor["id"] != null) {
          // Pastikan vendor id adalah int
          final vendorId = vendor["id"] is int
              ? vendor["id"]
              : int.tryParse(vendor["id"].toString()) ?? 0;

          if (vendorId > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DataVendor(vendorId: vendorId),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("ID vendor tidak valid"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
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
                  backgroundImage: (vendor["user"] != null &&
                          vendor["user"]["profile_image"] != null &&
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
                    if (motor != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SewaMotorPage(
                            motor: motor!,
                            isGuest: widget.isGuest,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Data motor tidak tersedia"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

String _formatCurrency(dynamic amount) {
  if (amount == null) return "0";

  // Pastikan amount adalah numeric
  int value;
  if (amount is String) {
    value = int.tryParse(amount) ?? 0;
  } else if (amount is int) {
    value = amount;
  } else if (amount is double) {
    value = amount.toInt();
  } else {
    value = 0;
  }

  // Format dengan pemisah ribuan
  String result = value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => "${m[1]}.",
      );

  return result;
}