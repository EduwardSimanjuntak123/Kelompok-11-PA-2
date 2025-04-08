import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/sewamotor.dart';
import 'package:flutter_rentalmotor/user/detailpesanan.dart';
import 'package:flutter_rentalmotor/user/akun.dart';

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

class _DetailMotorPageState extends State<DetailMotorPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    final pages = [
      HomePageUser(),
      DetailPesanan(),
      Akun(),
    ];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        widget.motor["image"] ?? "assets/images/default_motor.png";
    if (imageUrl.startsWith("/")) {
      imageUrl = "http://192.168.189.159:8080$imageUrl";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroImage(imageUrl),
              SizedBox(height: 20),
              _buildMotorName(),
              SizedBox(height: 6),
              _buildMotorType(),
              SizedBox(height: 25),
              _buildSectionTitle("Deskripsi"),
              SizedBox(height: 8),
              _buildMotorDescription(),
              SizedBox(height: 25),
              _buildSectionTitle("Informasi Motor"),
              SizedBox(height: 12),
              _buildInfoRow(),
              SizedBox(height: 35),
              _buildActionButton(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF2C567E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Detail Motor",
        style: GoogleFonts.poppins(
          color: Color(0xFF2C567E),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeroImage(String imageUrl) {
    return Hero(
      tag: widget.motor["id"].toString(),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imageUrl.startsWith("http")
                  ? Image.network(imageUrl,
                      width: double.infinity, height: 220, fit: BoxFit.cover)
                  : Image.asset(imageUrl,
                      width: double.infinity, height: 220, fit: BoxFit.cover),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorName() {
    return Text(
      widget.motor["name"] ?? "Nama Tidak Diketahui",
      style: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C567E),
      ),
    );
  }

  Widget _buildMotorType() {
    return Text(
      "Tipe: ${widget.motor["type"] ?? "Tidak Diketahui"}",
      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2C567E),
      ),
    );
  }

  Widget _buildMotorDescription() {
    return Text(
      widget.motor["description"] ?? "Tidak ada deskripsi.",
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCard(Icons.star, "${widget.motor["rating"] ?? "0.0"}",
            "Rating", Colors.amber),
        _buildInfoCard(Icons.monetization_on,
            "Rp ${widget.motor["price"] ?? "-"}", "Harga", Colors.green),
        _buildInfoCard(Icons.category,
            "${widget.motor["variant"] ?? "1"} Varian", "Varian", Colors.blue),
      ],
    );
  }

  Widget _buildInfoCard(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              padding: EdgeInsets.all(10),
              child: Icon(icon, color: color, size: 26),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Center(
      child: !widget.isGuest
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Color(0xFF2C567E), Color(0xFF4682B4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Book Now",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            )
          : Text(
              "Silakan login untuk memesan.",
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Color(0xFF2C567E),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Akun",
        ),
      ],
    );
  }
}
