import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';

class KelolaPerpanjnganSewa extends StatefulWidget {
  const KelolaPerpanjnganSewa({Key? key}) : super(key: key);

  @override
  State<KelolaPerpanjnganSewa> createState() => _KelolaPerpanjnganSewaState();
}

final String baseUrl = ApiConfig.baseUrl;
final storage = const FlutterSecureStorage();

class _KelolaPerpanjnganSewaState extends State<KelolaPerpanjnganSewa>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> extensions = [];
  Map<int, dynamic> bookings = {};
  String errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Theme colors
  final Color primaryColor = const Color(0xFF2C567E);
  final Color secondaryColor = const Color(0xFF4A89DC);
  final Color accentColor = const Color(0xFFFFA726);
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
    fetchData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final String? token = await storage.read(key: "auth_token");

      if (token == null) {
        setState(() {
          errorMessage = 'Token tidak ditemukan. Silakan masuk ulang.';
        });
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final extensionsResponse = await http.get(
        Uri.parse('$baseUrl/vendor/extensions'),
        headers: headers,
      );

      if (extensionsResponse.statusCode == 200) {
        final extensionsData = json.decode(extensionsResponse.body);
        extensions = extensionsData['extensions'] ?? [];

        if (extensions.isEmpty) {
          setState(() {
            errorMessage = 'Belum ada permintaan perpanjangan sewa.';
          });
          return;
        }

        final bookingsResponse = await http.get(
          Uri.parse('$baseUrl/vendor/bookings/'),
          headers: headers,
        );

        if (bookingsResponse.statusCode == 200) {
          final bookingsJson = json.decode(bookingsResponse.body);

          if (bookingsJson is List) {
            for (var booking in bookingsJson) {
              bookings[booking['id']] = booking;
            }
          } else {
            setState(() {
              errorMessage = 'Format data bookings tidak valid.';
            });
          }
        } else {
          setState(() {
            errorMessage =
                'Gagal memuat data bookings: ${bookingsResponse.statusCode}';
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data perpanjangan: ${extensionsResponse.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> approveExtension(int extensionId) async {
    _showActionDialog(
      title: 'Konfirmasi Persetujuan',
      message: 'Apakah Anda yakin ingin menyetujui perpanjangan ini?',
      confirmText: 'Setujui',
      confirmColor: successColor,
      onConfirm: () async {
        Navigator.of(context).pop(); // Close dialog
        _showLoadingDialog('Memproses persetujuan...');

        try {
          final String? token = await storage.read(key: "auth_token");

          if (token == null) {
            Navigator.of(context).pop(); // Close loading dialog
            _showSnackBar(
                'Token tidak ditemukan. Silakan masuk ulang.', dangerColor);
            return;
          }

          final headers = {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          };

          final response = await http.put(
            Uri.parse('$baseUrl/vendor/extensions/$extensionId/approve'),
            headers: headers,
          );

          Navigator.of(context).pop(); // Close loading dialog

          if (response.statusCode == 200) {
            _showSnackBar('Perpanjangan berhasil disetujui', successColor);
            fetchData(); // Refresh data
          } else {
            _showSnackBar(
                'Gagal menyetujui: ${response.statusCode}', dangerColor);
          }
        } catch (e) {
          Navigator.of(context).pop(); // Close loading dialog
          _showSnackBar('Error: ${e.toString()}', dangerColor);
        }
      },
    );
  }

  Future<void> rejectExtension(int extensionId) async {
    _showActionDialog(
      title: 'Konfirmasi Penolakan',
      message: 'Apakah Anda yakin ingin menolak perpanjangan ini?',
      confirmText: 'Tolak',
      confirmColor: dangerColor,
      onConfirm: () async {
        Navigator.of(context).pop(); // Close dialog
        _showLoadingDialog('Memproses penolakan...');

        try {
          final String? token = await storage.read(key: "auth_token");

          if (token == null) {
            Navigator.of(context).pop(); // Close loading dialog
            _showSnackBar(
                'Token tidak ditemukan. Silakan login ulang.', dangerColor);
            return;
          }

          final headers = {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          };

          final response = await http.put(
            Uri.parse('$baseUrl/vendor/extensions/$extensionId/reject'),
            headers: headers,
          );

          Navigator.of(context).pop(); // Close loading dialog

          if (response.statusCode == 200) {
            _showSnackBar('Perpanjangan berhasil ditolak', successColor);
            fetchData(); // Refresh data
          } else {
            _showSnackBar('Gagal menolak: ${response.statusCode}', dangerColor);
          }
        } catch (e) {
          Navigator.of(context).pop(); // Close loading dialog
          _showSnackBar('Error: ${e.toString()}', dangerColor);
        }
      },
    );
  }

  void _showActionDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required Function onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: textSecondaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: textSecondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => onConfirm(),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == successColor ? Icons.check_circle : Icons.error_outline,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      ),
    );
  }

  String formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String formatCurrency(dynamic amount) {
    if (amount == null) return "0";

    // Ensure amount is numeric
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

    final formatter = NumberFormat("#,###", "id_ID");
    return formatter.format(value);
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return successColor;
      case 'rejected':
        return dangerColor;
      default:
        return warningColor;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return 'Menunggu';
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Kelola Perpanjangan Sewa',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1A567D),
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
            onPressed: fetchData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient at the top
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: isLoading
                ? _buildLoadingShimmer()
                : errorMessage.isNotEmpty
                    ? _buildErrorView()
                    : extensions.isEmpty
                        ? _buildEmptyView()
                        : _buildExtensionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: textSecondaryColor.withOpacity(0.7),
              ),
              SizedBox(height: 16),
              // Text(
              //   'Terjadi Kesalahan',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: textPrimaryColor,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchData,
                icon: Icon(Icons.refresh),
                label: Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 80,
                color: primaryColor.withOpacity(0.7),
              ),
              SizedBox(height: 16),
              Text(
                'Tidak Ada Permintaan Perpanjangan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Belum ada pelanggan yang mengajukan perpanjangan sewa.',
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: fetchData,
                icon: Icon(Icons.refresh),
                label: Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtensionsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: fetchData,
        color: primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: extensions.length,
          itemBuilder: (context, index) {
            final extension = extensions[index];
            final booking = bookings[extension['booking_id']];
            final String motorImageUrl =
                booking != null ? '$baseUrl${booking['motor']['image']}' : '';

            // Add staggered animation for each item
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = index * 0.1;
                final start = delay;
                final end = delay + 0.4;

                final animationValue = Tween<double>(begin: 0.0, end: 1.0)
                    .animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(start, end, curve: Curves.easeOut),
                      ),
                    )
                    .value;

                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: child,
                  ),
                );
              },
              child: _buildExtensionCard(extension, booking, motorImageUrl),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExtensionCard(
      dynamic extension, dynamic booking, String motorImageUrl) {
    final statusColor = getStatusColor(extension['status']);
    final statusText = getStatusText(extension['status']);
    final statusIcon = getStatusIcon(extension['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Permintaan Perpanjangan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motor and customer info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Motor Image with gradient overlay
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: motorImageUrl.isNotEmpty
                              ? Stack(
                                  children: [
                                    Image.network(
                                      motorImageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.directions_bike,
                                            color: Colors.grey[500],
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.directions_bike,
                                    color: Colors.grey[500],
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(width: 16),

                      // Extension Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              extension['motor_name'] ?? 'Unknown Motor',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.person,
                              'Pelanggan',
                              extension['customer_name'] ?? 'Unknown',
                            ),
                            SizedBox(height: 4),
                            _buildInfoRow(
                              Icons.calendar_month,
                              'Tanggal Permintaan',
                              formatDate(extension['requested_at']),
                            ),
                            SizedBox(height: 4),
                            _buildInfoRow(
                              Icons.date_range,
                              'Perpanjangan Hingga',
                              formatDate(extension['requested_end_date']),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Divider with gradient
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.2),
                          primaryColor.withOpacity(0.3),
                          Colors.grey.withOpacity(0.2),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Additional price
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Rp',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biaya Tambahan',
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Rp ${formatCurrency(extension['additional_price'])}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Approval info if available
                  if (extension['approved_at'] != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: successColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: successColor,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Disetujui Pada',
                                style: TextStyle(
                                  color: textSecondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                formatDate(extension['approved_at']),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action Buttons
                  if (extension['status'].toLowerCase() != 'approved' &&
                      extension['status'].toLowerCase() != 'rejected') ...[
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                rejectExtension(extension['extension_id']),
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text('Tolak'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: dangerColor,
                              side: BorderSide(color: dangerColor),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                approveExtension(extension['extension_id']),
                            icon: Icon(Icons.check, color: Colors.white),
                            label: Text('Setujui'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: primaryColor.withOpacity(0.7),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondaryColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: textPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
