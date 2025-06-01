import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/vendor/kelola_booking_service.dart';
import 'package:intl/intl.dart';

class DetailBookingPage extends StatefulWidget {
  final int bookingId;
  const DetailBookingPage({super.key, required this.bookingId});

  @override
  State<DetailBookingPage> createState() => _DetailBookingPageState();
}

class _DetailBookingPageState extends State<DetailBookingPage> {
  Map<String, dynamic>? bookingData;
  final String baseUrl = ApiConfig.baseUrl;
  bool isLoading = true;
  final storage = const FlutterSecureStorage();
  final KelolaBookingService kelolaBookingService = KelolaBookingService();

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D);
  final Color secondaryColor = const Color(0xFF3E8EDE);
  final Color accentColor = const Color(0xFF64B5F6);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = const Color(0xFF2D3748);
  final Color textSecondaryColor = const Color(0xFF718096);
  final Color successColor = const Color(0xFF48BB78);
  final Color warningColor = const Color(0xFFF6AD55);
  final Color dangerColor = const Color(0xFFE53E3E);

  @override
  void initState() {
    super.initState();
    fetchBookingDetail();
  }

  Future<void> fetchBookingDetail() async {
    setState(() => isLoading = true);
    try {
      final token = await storage.read(key: 'auth_token');
      debugPrint('TOKEN: $token');

      final response = await http.get(
        Uri.parse('$baseUrl/vendor/bookings/${widget.bookingId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookingData = data['booking'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat detail booking');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy, HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _translateMotorType(String? type) {
    switch (type) {
      case 'automatic':
        return 'Matic';
      case 'manual':
        return 'Manual';
      case 'clutch':
        return 'Kopling';
      case 'vespa':
        return 'Vespa';
      default:
        return '-';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningColor;
      case 'confirmed':
        return accentColor;
      case 'in transit':
        return const Color(0xFFB794F4);
      case 'in use':
        return const Color(0xFF4299E1);
      case 'awaiting return':
        return const Color(0xFFED8936);
      case 'completed':
        return successColor;
      case 'rejected':
        return dangerColor;
      default:
        return textSecondaryColor;
    }
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'in transit':
        return 'Sedang Diantar';
      case 'in use':
        return 'Sedang Digunakan';
      case 'awaiting return':
        return 'Menunggu Pengembalian';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'in transit':
        return Icons.delivery_dining;
      case 'in use':
        return Icons.motorcycle;
      case 'awaiting return':
        return Icons.assignment_return;
      case 'completed':
        return Icons.task_alt;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Widget buildInfoRow(String label, String? value,
      {IconData? icon, bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: primaryColor.withOpacity(0.7)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted ? primaryColor : textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getStatusColor(status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(status),
            size: 16,
            color: getStatusColor(status),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              getStatusText(status),
              style: TextStyle(
                color: getStatusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showActionConfirmationDialog(String status) {
    String actionText;
    switch (status) {
      case 'pending':
        actionText = 'Konfirmasi Booking';
        break;
      case 'confirmed':
        actionText = 'Set ke Sedang Diantar';
        break;
      case 'in transit':
        actionText = 'Set ke Sedang Digunakan';
        break;
      case 'in use':
        actionText = 'Selesaikan Pesanan';
        break;
      case 'awaiting return':
        actionText = 'Motor Sudah Kembali';
        break;
      default:
        actionText = 'Unknown Action';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.help_outline, color: primaryColor),
              const SizedBox(width: 10),
              Text('Konfirmasi Aksi', style: TextStyle(color: primaryColor)),
            ],
          ),
          content: Text('Apakah Anda yakin ingin $actionText?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: textSecondaryColor,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _performAction(status);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: dangerColor),
              const SizedBox(width: 10),
              Text('Tolak Pesanan', style: TextStyle(color: dangerColor)),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin menolak pesanan ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: textSecondaryColor,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _rejectBooking();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Tolak Pesanan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performAction(String status) async {
    try {
      switch (status) {
        case 'pending':
          await kelolaBookingService
              .confirmBooking(widget.bookingId.toString());
          break;
        case 'confirmed':
          await kelolaBookingService
              .setBookingToTransit(widget.bookingId.toString());
          break;
        case 'in transit':
          await kelolaBookingService
              .setBookingToInUse(widget.bookingId.toString());
          break;
        case 'in use':
        case 'awaiting return':
          await kelolaBookingService
              .completeBooking(widget.bookingId.toString());
          break;
        default:
          break;
      }
      fetchBookingDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Status booking berhasil diperbarui!'),
            ],
          ),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _rejectBooking() async {
    try {
      await kelolaBookingService.rejectBooking(widget.bookingId.toString());
      fetchBookingDetail();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Pesanan berhasil ditolak!'),
            ],
          ),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: dangerColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget buildActionButton(String status) {
    if (status == 'completed' || status == 'rejected') {
      return Container();
    }

    Color buttonColor;
    IconData buttonIcon;
    Color textColor = Colors.white; // Warna teks tetap putih
    Color iconColor = Colors.white; // Warna icon putih

    switch (status.toLowerCase()) {
      case 'pending':
        buttonColor =
            successColor; // Warna hijau dari variabel successColor Anda
        buttonIcon = Icons.check_circle;
        break;
      case 'confirmed':
        buttonColor = accentColor;
        buttonIcon = Icons.delivery_dining;
        break;
      case 'in transit':
        buttonColor = const Color(0xFF4299E1);
        buttonIcon = Icons.motorcycle;
        break;
      case 'in use':
      case 'awaiting return':
        buttonColor = const Color(0xFF48BB78);
        buttonIcon = Icons.task_alt;
        break;
      default:
        buttonColor = primaryColor;
        buttonIcon = Icons.check_circle;
    }

    return Column(
      children: [
        // Tombol utama (Konfirmasi Pesanan/Ubah Status)
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            color: buttonColor, // Background warna solid
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showActionConfirmationDialog(status),
              borderRadius: BorderRadius.circular(15),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(buttonIcon, color: iconColor, size: 22), // Icon putih
                    const SizedBox(width: 10),
                    Text(
                      _getActionButtonText(status),
                      style: TextStyle(
                        color: textColor, // Teks putih
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Tombol Tolak Pesanan (hanya untuk status pending)
        if (status.toLowerCase() == 'pending') ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: dangerColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: dangerColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showRejectConfirmationDialog,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Tolak Pesanan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getActionButtonText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Konfirmasi Pesanan';
      case 'confirmed':
        return 'Ubah ke Sedang Diantar';
      case 'in transit':
        return 'Motor Digunakan';
      case 'in use':
        return 'Selesaikan Pesanan';
      case 'awaiting return':
        return 'Motor Sudah Kembali';
      default:
        return 'Unknown Action';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchBookingDetail,
            tooltip: 'Refresh',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : bookingData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: textSecondaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data tidak ditemukan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: fetchBookingDetail,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with booking ID and status
                      buildHeaderSection(),

                      const SizedBox(height: 16),

                      // Customer Information
                      buildCardSection(
                        title: 'Informasi Pelanggan',
                        icon: Icons.person,
                        children: [
                          buildInfoRow(
                            'Nama',
                            bookingData!['customer_name'] ?? '-',
                            icon: Icons.person_outline,
                          ),
                          buildInfoRow(
                            'Telepon',
                            bookingData!['customer']?['phone'] ??
                                'Tidak tersedia',
                            icon: Icons.phone_outlined,
                          ),
                          buildInfoRow(
                            'Alamat',
                            bookingData!['customer']?['address'] ??
                                'Tidak tersedia',
                            icon: Icons.location_on_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Di bagian Booking Information
                      buildCardSection(
                        title: 'Detail Pesanan',
                        icon: Icons.calendar_today,
                        children: [
                          buildInfoRow(
                            'Tanggal Booking',
                            formatDate(bookingData!['booking_date']),
                            icon: Icons.event_note,
                          ),
                          buildInfoRow(
                            'Mulai Sewa',
                            formatDate(bookingData!['start_date']),
                            icon: Icons.play_circle_outline,
                            isHighlighted: true,
                          ),
                          buildInfoRow(
                            'Selesai Sewa',
                            formatDate(bookingData!['end_date']),
                            icon: Icons.stop_circle_outlined,
                            isHighlighted: true,
                          ),
                          buildInfoRow(
                            'Lokasi Ambil',
                            bookingData!['pickup_location'],
                            icon: Icons.location_on,
                          ),
                          if (bookingData!['dropoff_location'] != null)
                            buildInfoRow(
                              'Lokasi Kembali',
                              bookingData!['dropoff_location'],
                              icon: Icons.location_off,
                            ),
                          buildPurposeSection(),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Motorcycle Information
                      buildCardSection(
                        title: 'Informasi Motor',
                        icon: Icons.motorcycle,
                        children: [
                          if (bookingData!['motor']?['image'] != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  '$baseUrl${bookingData!['motor']['image']}',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          buildInfoRow(
                            'Nama Motor',
                            bookingData!['motor']?['name'],
                            icon: Icons.motorcycle,
                            isHighlighted: true,
                          ),
                          buildInfoRow(
                            'Merk',
                            bookingData!['motor']?['brand'],
                            icon: Icons.branding_watermark,
                          ),
                          buildInfoRow(
                            'Tahun',
                            bookingData!['motor']?['year']?.toString(),
                            icon: Icons.date_range,
                          ),
                          buildInfoRow(
                            'Harga',
                            'Rp ${bookingData!['motor']?['price'] ?? '-'}/hari',
                            icon: Icons.attach_money,
                            isHighlighted: true,
                          ),
                          buildInfoRow(
                            'Warna',
                            bookingData!['motor']?['color'],
                            icon: Icons.color_lens,
                          ),
                          buildInfoRow(
                            'Tipe',
                            _translateMotorType(bookingData!['motor']?['type']),
                            icon: Icons.category,
                          ),
                          if (bookingData!['motor']?['description'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.description,
                                          size: 18,
                                          color: primaryColor.withOpacity(0.7)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Deskripsi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: textSecondaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Text(
                                      bookingData!['motor']?['description'] ??
                                          '-',
                                      style: TextStyle(
                                        color: textPrimaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Identity Photos
                      if (bookingData!['photo_id'] != null ||
                          bookingData!['ktp_id'] != null)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          child: buildCardSection(
                            title: 'Dokumen Identitas',
                            icon: Icons.badge,
                            children: [
                              if (bookingData!['photo_id'] != null)
                                buildPhotoSection(
                                  'Foto Diri',
                                  '$baseUrl${bookingData!['photo_id']}',
                                  Icons.person,
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Action Button
                      buildActionButton(bookingData!['status']),
                    ],
                  ),
                ),
    );
  }

  Widget buildHeaderSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        final paddingValue = isSmallScreen ? 12.0 : 16.0;
        final avatarRadius = isSmallScreen ? 16.0 : 20.0;
        final nameFontSize = isSmallScreen ? 14.0 : 16.0;
        final motorFontSize = isSmallScreen ? 12.0 : 14.0;
        final initialFontSize = isSmallScreen ? 16.0 : 18.0;
        final spacing = isSmallScreen ? 8.0 : 12.0;

        return Container(
          padding: EdgeInsets.all(paddingValue),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar + info
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: avatarRadius,
                      child: Text(
                        bookingData!['customer']?['name']
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'C',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: initialFontSize,
                        ),
                      ),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookingData!['customer']?['name'] ?? 'Customer',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: nameFontSize,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 1.0 : 2.0),
                          Text(
                            bookingData!['motor']?['name'] ?? 'Motor',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: motorFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              buildStatusBadge(bookingData!['status']),
            ],
          ),
        );
      },
    );
  }

  Widget buildPurposeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description,
                  size: 18, color: primaryColor.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text(
                'Tujuan/Keperluan',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              bookingData!['booking_purpose'] ?? 'Tidak ada informasi tujuan',
              style: TextStyle(
                color: textPrimaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardSection({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhotoSection(String title, String imageUrl, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: primaryColor.withOpacity(0.7)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
