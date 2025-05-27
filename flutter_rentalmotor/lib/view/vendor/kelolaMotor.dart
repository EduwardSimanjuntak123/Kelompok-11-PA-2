import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/view/vendor/motor_detail_screen.dart';
import 'package:flutter_rentalmotor/view/vendor/CreateMotorScreen.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

class KelolaMotorScreen extends StatefulWidget {
  @override
  _KelolaMotorScreenState createState() => _KelolaMotorScreenState();
}

class _KelolaMotorScreenState extends State<KelolaMotorScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<MotorModel> motorList = [];
  final String baseUrl = ApiConfig.baseUrl;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  List<MotorModel> _filteredMotorList = [];

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D);
  final Color secondaryColor = const Color(0xFF00BFA5);
  final Color accentColor = const Color(0xFFFF6D00);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF263238);
  final Color textSecondaryColor = const Color(0xFF607D8B);
  final Color successColor = const Color(0xFF4CAF50);
  final Color warningColor = const Color(0xFFFFC107);
  final Color dangerColor = const Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    fetchMotorData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMotorData() async {
    setState(() {
      isLoading = true;
    });

    try {
      VendorMotorApi api = VendorMotorApi();
      List<dynamic> data = await api.fetchMotorData();
      List<MotorModel> motorData =
          data.map((motorJson) => MotorModel.fromJson(motorJson)).toList();

      setState(() {
        motorList = motorData;
        _filterMotorList();
        isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text("Error: $e")),
            ],
          ),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(10),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              fetchMotorData();
            },
            textColor: Colors.white,
          ),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterMotorList() {
    if (_searchQuery.isEmpty) {
      _filteredMotorList = List.from(motorList);
    } else {
      _filteredMotorList = motorList
          .where((motor) =>
              motor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              motor.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              motor.brand.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Future<void> _handleRefresh() async {
    await fetchMotorData();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return successColor;
      case 'booked':
        return warningColor;
      case 'unavailable':
        return dangerColor;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'booked':
        return 'Sedang Digunakan';
      case 'unavailable':
        return 'Tidak Tersedia';
      default:
        return status;
    }
  }

  String getMotorTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'automatic':
        return 'Matic';
      case 'manual':
        return 'Manual';
      case 'clutch':
        return 'Kopling';
      case 'vespa':
        return 'Vespa';
      default:
        return type; // Default label
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Kelola Motor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                Color(0xFF0D47A1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 26),
            onPressed: fetchMotorData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterMotorList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari motor...',
                  hintStyle:
                      TextStyle(color: textSecondaryColor.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: primaryColor, size: 24),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ),
            ),
          ),

          // Stats Summary
          if (!isLoading && motorList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Motor',
                    motorList.length.toString(),
                    Icons.motorcycle,
                    primaryColor,
                  ),
                  SizedBox(width: 12),
                  _buildStatCard(
                    'Tersedia',
                    motorList
                        .where((m) => m.status.toLowerCase() == 'available')
                        .length
                        .toString(),
                    Icons.check_circle,
                    successColor,
                  ),
                  SizedBox(width: 12),
                  _buildStatCard(
                    'Sedang Digunakan',
                    motorList
                        .where((m) => m.status.toLowerCase() == 'booked')
                        .length
                        .toString(),
                    Icons.bookmark,
                    warningColor,
                  ),
                ],
              ),
            ),

          // Motor List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              backgroundColor: cardColor,
              color: primaryColor,
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Memuat data motor...',
                            style: TextStyle(
                              color: textPrimaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredMotorList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.motorcycle_outlined,
                                  size: 80,
                                  color: textSecondaryColor.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Belum ada motor terdaftar'
                                    : 'Tidak ada motor yang sesuai',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Tambahkan motor baru dengan tombol + di bawah'
                                    : 'Coba kata kunci pencarian yang lain',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textSecondaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 100),
                            physics: BouncingScrollPhysics(),
                            itemCount: _filteredMotorList.length,
                            itemBuilder: (context, index) {
                              MotorModel motor = _filteredMotorList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildMotorCard(motor, index),
                              );
                            },
                          ),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateMotorScreen()),
          ).then((_) => fetchMotorData());
        },
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 25,
        ),
        label: const Text(
          'Tambah Motor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorCard(MotorModel motor, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutQuint,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MotorDetailScreen(motorId: motor.id),
              ),
            ).then((_) => fetchMotorData());
          },
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motor Image
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: motor.image != null
                        ? Hero(
                            tag: 'motor-image-${motor.id}',
                            child: Image.network(
                              '$baseUrl${motor.image}',
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: primaryColor,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 50, color: Colors.grey[500]),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 50, color: Colors.grey[500]),
                            ),
                          ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(motor.status).withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _getStatusLabel(motor.status),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Price Badge
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Rp ${motor.price.toStringAsFixed(0)}/hari',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Motor Details
              Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            motor.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 6),
                            Text(
                              '${motor.rating}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Motor specs chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(Icons.branding_watermark, motor.brand),
                        _buildInfoChip(
                            Icons.calendar_today, motor.year.toString()),
                        _buildInfoChip(
                            Icons.category, getMotorTypeLabel(motor.type)),
                        _buildInfoChip(Icons.confirmation_number, motor.plate),
                      ],
                    ),

                    SizedBox(height: 16),
                    Text(
                      motor.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: textSecondaryColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 18),

                    // Enhanced Kelola Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1A567D),
                                Color(0xFF0D3A5F),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: Color(0xFF2D6896),
                              width: 1,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MotorDetailScreen(motorId: motor.id),
                                ),
                              ).then((_) => fetchMotorData());
                            },
                            icon: Icon(Icons.settings,
                                size: 20, color: Colors.white),
                            label: Text(
                              'Kelola',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
