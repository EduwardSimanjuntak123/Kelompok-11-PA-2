import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/vendor/motor_detail_screen.dart';
import 'package:flutter_rentalmotor/vendor/CreateMotorScreen.dart';
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
  final Color primaryColor = const Color(0xFF1A567D); // Modern indigo
  final Color secondaryColor = const Color(0xFF00BFA5); // Modern teal
  final Color accentColor = const Color(0xFFFF6D00); // Modern orange
  final Color backgroundColor = const Color(0xFFF5F7FA); // Light gray
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF263238); // Dark gray
  final Color textSecondaryColor = const Color(0xFF607D8B); // Blue gray
  final Color successColor = const Color(0xFF4CAF50); // Success green
  final Color warningColor = const Color(0xFFFFC107); // Warning amber
  final Color dangerColor = const Color(0xFFF44336); // Danger red

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

  // Fetching motor data from the API
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
              fetchMotorData(); // Retry fetching motor data
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

  // Handling the refresh action triggered by swipe-down
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
            fontSize: 22,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMotorData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Stats Summary
          if (!isLoading && motorList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Total Motor',
                    motorList.length.toString(),
                    Icons.motorcycle,
                    primaryColor,
                  ),
                  SizedBox(width: 10),
                  _buildStatCard(
                    'Tersedia',
                    motorList
                        .where((m) => m.status.toLowerCase() == 'available')
                        .length
                        .toString(),
                    Icons.check_circle,
                    successColor,
                  ),
                  SizedBox(width: 10),
                  _buildStatCard(
                    'Disewa',
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
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Memuat data motor...',
                            style: TextStyle(
                              color: textSecondaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
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
                                padding: const EdgeInsets.all(20),
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
                                  color: textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Tambahkan motor baru dengan tombol + di bawah'
                                    : 'Coba kata kunci pencarian yang lain',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textSecondaryColor.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: _filteredMotorList.length,
                            itemBuilder: (context, index) {
                              MotorModel motor = _filteredMotorList[index];
                              return _buildMotorCard(motor);
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
          ).then((_) => fetchMotorData()); // Refresh after adding a motor
        },
        icon: Icon(Icons.add),
        label: Text('Tambah Motor'),
        backgroundColor: primaryColor,
        tooltip: 'Tambah Motor',
        elevation: 4,
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorCard(MotorModel motor) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MotorDetailScreen(motorId: motor.id),
            ),
          ).then((_) => fetchMotorData()); // Refresh after returning
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motor Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  motor.image != null
                      ? Image.network(
                          '$baseUrl${motor.image}',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 180,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported,
                                size: 50, color: Colors.grey[600]),
                          ),
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey[600]),
                        ),
                  // Status Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(motor.status).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        motor.status.substring(0, 1).toUpperCase() +
                            motor.status.substring(1),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  // Price Badge
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Text(
                        'Rp ${motor.price.toStringAsFixed(0)}/hari',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Motor Details
            Padding(
              padding: EdgeInsets.all(16),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            '${motor.rating}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(Icons.branding_watermark, motor.brand),
                      SizedBox(width: 8),
                      _buildInfoChip(
                          Icons.calendar_today, motor.year.toString()),
                      SizedBox(width: 8),
                      _buildInfoChip(Icons.category, motor.type),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    motor.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MotorDetailScreen(motorId: motor.id),
                            ),
                          ).then((_) => fetchMotorData());
                        },
                        icon: Icon(Icons.edit, size: 18),
                        label: Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
