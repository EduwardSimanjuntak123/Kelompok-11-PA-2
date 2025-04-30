import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter_rentalmotor/user/homepageuser.dart';
import 'package:flutter_rentalmotor/user/profil/akun.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:flutter_rentalmotor/services/customer/cancelBooking_api.dart';
import 'package:flutter_rentalmotor/user/ulasan/reviewpage.dart'; // Import ReviewPage
import 'package:flutter_rentalmotor/user/chat/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_rentalmotor/services/customer/chat_services.dart';

class PesananPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const PesananPage({Key? key, required this.booking}) : super(key: key);

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  int _selectedIndex = 1;
  bool _isCancelling = false;
  bool _hasReviewed = false;
  List<dynamic> _extensions = [];
  bool _loadingExt = true;
  @override
  void initState() {
    super.initState();
    debugBooking();
    _fetchExtensions();
  }

  void debugBooking() {
    debugPrint("=== DEBUG BOOKING DATA ===");
    widget.booking.forEach((key, value) {
      debugPrint("$key: $value");
    });
    debugPrint("===========================");
  }

  // Blue theme colors
  final Color primaryBlue = Color(0xFF2C567E);

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePageUser()));
    } else if (index == 2) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Akun()));
    }
  }

  Future<List<DateTime>> getUnavailableDates(int motorId) async {
    try {
      final token = await BatalkanPesananAPI.storage.read(key: "auth_token");
      final url = Uri.parse("${ApiConfig.baseUrl}/bookings/motor/$motorId");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<DateTime> dates = [];

        for (var booking in data) {
          DateTime start = DateTime.parse(booking['start_date']).toLocal();
          DateTime end = DateTime.parse(booking['end_date']).toLocal();

          // Debugging: Menampilkan tanggal mulai dan selesai yang diterima dari API
          debugPrint('Start Date: $start');
          debugPrint('End Date: $end');

          // Normalisasi untuk mengambil hanya tanggal
          start = DateTime(start.year, start.month, start.day);
          end = DateTime(end.year, end.month, end.day);

          // Debugging: Menampilkan tanggal yang telah dinormalisasi
          debugPrint('Normalized Start Date: $start');
          debugPrint('Normalized End Date: $end');

          // Menambahkan semua tanggal antara tanggal mulai dan selesai ke daftar
          for (int i = 0; i <= end.difference(start).inDays; i++) {
            final day = start.add(Duration(days: i));
            dates.add(day);
            // Debugging: Menampilkan setiap tanggal yang ditambahkan
            debugPrint('Unavailable Date: $day');
          }
        }

        return dates;
      } else {
        throw Exception("Gagal mengambil data pemesanan");
      }
    } catch (e) {
      debugPrint("Error fetching unavailable dates: $e");
      return [];
    }
  }

  Widget _buildExtensionList() {
    if (_loadingExt) return Center(child: CircularProgressIndicator());
    if (_extensions.isEmpty) {
      return Text('Belum ada permintaan perpanjangan');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _extensions.map((ext) {
        final status = ext['status'];
        final Color bgColor = status == 'pending'
            ? Colors.yellow.shade100
            : status == 'approved'
                ? Colors.green.shade100
                : Colors.red.shade100;

        return Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.update, size: 20, color: primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    "Permintaan Perpanjangan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildExtensionDetail('Tanggal Permintaan',
                  ext['requested_at']?.split('T')[0] ?? '-'),
              _buildExtensionDetail('Tanggal Selesai Baru',
                  ext['requested_end_date']?.split('T')[0] ?? '-'),
              _buildExtensionDetail(
                  'Harga Tambahan', 'Rp ${ext['additional_price'] ?? 0}'),
              _buildExtensionDetail('Status', _capitalizeStatus(status)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExtensionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Future<void> _fetchExtensions() async {
    final bookingId = widget.booking['id'];
    final token = await BatalkanPesananAPI.storage.read(key: 'auth_token');

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/customer/bookings/$bookingId/extensions');

    // Debugging: Menampilkan URL dan token yang digunakan
    debugPrint('Request URL: $url');
    debugPrint('Authorization Header: Bearer $token');

    final resp =
        await http.get(url, headers: {'Authorization': 'Bearer $token'});

    // Debugging: Menampilkan status code dan response body
    debugPrint('Response Status Code: ${resp.statusCode}');
    debugPrint('Response Body: ${resp.body}');

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      setState(() {
        _extensions = data['extensions'] ?? [];
        _loadingExt = false;
      });
    } else {
      setState(() => _loadingExt = false);
    }
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return "Menunggu Konfirmasi";
      case 'confirmed':
        return "Dikonfirmasi, motor sedang disiapkan";
      case 'in use':
        return "Sedang saat ini digunakan";
      case 'rejected':
        return "Pesanan Ditolak";
      case 'in transit':
        return "Motor sedang diantar ke lokasi";
      case 'completed':
        return "Pesanan Selesai";
      case 'awaiting return':
        return "Menunggu Pengembalian";
      case 'canceled':
        return "Pesanan Dibatalkan";
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
        return Colors.green;
      case 'in use':
      case 'in transit':
      case 'awaiting return':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'rejected':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

// Fungsi untuk membangun lingkaran yang menandai tanggal pada kalender
  Widget _buildCalendarCircle(int day, Color color) {
    return Center(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Future<void> showCancelConfirmation(int bookingId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
            SizedBox(width: 8),
            Text("Konfirmasi", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Ya, Batalkan",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await cancelBooking(bookingId);
    }
  }

  Future<void> showExtendRequestDialog(int bookingId) async {
    final motor = widget.booking['motor'];
    final int motorId = motor['id'];
    final bookingEndDate = DateTime.parse(widget.booking['end_date']);
    final startDate = DateTime.parse(widget.booking['start_date']);

    final unavailableDates = await getUnavailableDates(motorId);

    // Menambahkan jumlah hari tambahan yang diminta
    int additionalDays = 3; // Misalnya, user ingin menambah 3 hari

    // Menentukan tanggal akhir perpanjangan yang diinginkan
    DateTime requestedEndDate =
        bookingEndDate.add(Duration(days: additionalDays));

    // Debugging: Menampilkan tanggal perpanjangan yang diminta
    debugPrint("Requested End Date (after extension): $requestedEndDate");

    // Mengecek apakah ada pemesanan lain yang berbenturan dengan tanggal perpanjangan yang diminta
    bool cannotExtend = false;

    // Memeriksa seluruh rentang tanggal yang sudah dibooking dan apakah ada bentrok
    for (DateTime date in unavailableDates) {
      // Ambil semua tanggal dalam rentang permintaan perpanjangan
      for (int i = 1; i <= additionalDays; i++) {
        DateTime extendDate = bookingEndDate.add(Duration(days: i));
        if (date == extendDate) {
          debugPrint("Cannot extend because booking exists on: $date");
          cannotExtend = true;
          break;
        }
      }
      if (cannotExtend) break;
    }
    // Jika tidak ada bentrok, lanjutkan untuk menampilkan form perpanjangan
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(16),
          title: Text(
            'Ajukan Perpanjangan',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bagian TableCalendar di dalam showExtendRequestDialog
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    availableGestures: AvailableGestures.none,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        final dayPure = DateTime(day.year, day.month, day.day);

                        // Cek apakah tanggal berada dalam rentang booking
                        final startDate =
                            DateTime.parse(widget.booking['start_date']);
                        final endDate =
                            DateTime.parse(widget.booking['end_date']);

                        // Normalisasi untuk membandingkan tanggal tanpa waktu
                        final normalizedStartDate = DateTime(
                            startDate.year, startDate.month, startDate.day);
                        final normalizedEndDate =
                            DateTime(endDate.year, endDate.month, endDate.day);

                        // Menandai tanggal yang dibooking dengan warna oranye
                        if (!dayPure.isBefore(normalizedStartDate) &&
                            !dayPure.isAfter(normalizedEndDate)) {
                          return _buildCalendarCircle(
                              day.day,
                              Colors.orange[
                                  200]!); // Tanggal yang dipesan oleh pengguna
                        }

                        // Cek apakah tanggal tersebut sudah dipesan orang lain
                        if (unavailableDates.contains(dayPure)) {
                          return Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Colors.red,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        return null; // Jika tidak ada penandaan
                      },
                    ),
                  ),
                ),

                SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    _buildLegendItem(Colors.orange[200]!, "Booking Anda"),
                    SizedBox(height: 6),
                    _buildLegendItem(
                        Colors.red[100]!, "Tanggal yang sudah di Booking"),
                  ],
                ),
                SizedBox(height: 16),
                if (cannotExtend) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tidak bisa perpanjang karena tanggal yang diminta sudah berbenturan dengan booking lain.',
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                if (!cannotExtend) ...[
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Hari Tambahan',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      additionalDays = int.tryParse(value) ?? 1;
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup', style: TextStyle(color: Colors.grey)),
            ),
            if (!cannotExtend) ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final rootContext =
                      context; // simpan context utama sebelum async
                  Navigator.of(rootContext).pop(); // tutup dialog input

                  final result =
                      await requestExtensionDays(bookingId, additionalDays);
                  final success = result['success'];
                  final message = result['message'];

                  // gunakan rootContext yang masih valid
                  await showDialog(
                    context: rootContext,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          Icon(
                            success
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: success ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(success ? 'Berhasil' : 'Gagal'),
                        ],
                      ),
                      content: Text(message),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Tutup'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Kirim', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<Map<String, dynamic>> requestExtensionDays(
      int bookingId, int additionalDays) async {
    try {
      final token = await BatalkanPesananAPI.storage.read(key: "auth_token");
      final url =
          Uri.parse("${ApiConfig.baseUrl}/customer/bookings/$bookingId/extend");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'additional_days': additionalDays}),
      );

      debugPrint("=== RESPONSE EXTEND BOOKING ===");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Body: ${response.body}");
      debugPrint("===============================");

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ??
            responseData['error'] ??
            'Terjadi kesalahan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<bool> requestExtension(int bookingId, DateTime newEndDate) async {
    try {
      final response = await BatalkanPesananAPI.postRequestExtend(
        bookingId,
        newEndDate.toIso8601String().split('T')[0],
      );

      if (response['success'] == true) {
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(response['message'] ?? 'Gagal mengajukan perpanjangan.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return false;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    setState(() => _isCancelling = true);

    final success = await BatalkanPesananAPI.cancelBooking(bookingId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pesanan berhasil dibatalkan."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      setState(() {
        widget.booking['status'] = 'canceled';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal membatalkan pesanan."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    setState(() => _isCancelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final motor = booking['motor'] ?? {};
    final status = booking['status'] ?? '';
    String imageUrl = motor['image'] ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = "${ApiConfig.baseUrl}$imageUrl";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "Detail Pesanan",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image with Gradient Overlay
            Stack(
              children: [
                // Motor Image
                Container(
                  height: 240,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey[600]),
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 240,
                  width: double.infinity,
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
                // Motor Name
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${motor['name'] ?? ''}".toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
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
                      SizedBox(height: 4),
                      Text(
                        "${motor['brand'] ?? ''} ${motor['model'] ?? ''}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Status Banner
            Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: getStatusColor(status).withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: getStatusColor(status).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: getStatusColor(status),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status Pesanan",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          getStatusText(status),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Booking Details Card
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: primaryBlue,
                            size: 18,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Detail Pesanan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),

                  // Booking Details
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildDetailItem(
                          Icons.location_on,
                          "Lokasi Pengantaran",
                          booking['pickup_location'] ?? '-',
                        ),
                        _buildDetailItem(
                          Icons.location_off,
                          "Lokasi Pengembalian",
                          booking['dropoff_location']?.isNotEmpty == true
                              ? booking['dropoff_location']
                              : "-",
                        ),
                        _buildDetailItem(
                          Icons.calendar_today,
                          "Tanggal Mulai",
                          (booking['start_date'] ?? '')
                              .toString()
                              .split('T')[0],
                        ),
                        _buildDetailItem(
                          Icons.event_available,
                          "Tanggal Selesai",
                          (booking['end_date'] ?? '').toString().split('T')[0],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
// Tambahkan di bawah Booking Details Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Permintaan Perpanjangan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildExtensionList(), // Ini menampilkan daftar perpanjangan
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  if (status == 'pending') ...[
                    buildButton(
                      "Batalkan Pesanan",
                      Colors.red,
                      Colors.white,
                      () {
                        showCancelConfirmation(booking['id']);
                      },
                      Icons.cancel,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (status == 'in use') ...[
                    buildButton(
                      "Ajukan Perpanjangan",
                      primaryBlue,
                      Colors.white,
                      () {
                        showExtendRequestDialog(booking['id']);
                      },
                      Icons.date_range,
                    ),
                    SizedBox(height: 8),
                  ],
                  if (status == 'completed' && !_hasReviewed) ...[
                    buildButton(
                      "Berikan Ulasan",
                      Colors.blue,
                      Colors.white,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewPage(bookingId: booking['id']),
                          ),
                        );
                      },
                      Icons.star,
                    ),
                    SizedBox(height: 8),
                  ],
                  ChatVendorButton(
                    vendorId: booking['vendor_Id'] ?? 0,
                    vendorData: {
                      'user_id': booking['vendor_Id'],
                      'shop_name': booking['shop_name'],
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Beranda"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: "Pesanan"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Akun"),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle;
      case 'in use':
        return Icons.directions_bike;
      case 'rejected':
        return Icons.cancel;
      case 'in transit':
        return Icons.local_shipping;
      case 'completed':
        return Icons.task_alt;
      case 'awaiting return':
        return Icons.assignment_return;
      case 'canceled':
        return Icons.highlight_off;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 18),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
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

  Widget buildButton(String text, Color bgColor, Color textColor,
      VoidCallback? onPressed, IconData icon) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed == null
              ? [Colors.grey, Colors.grey]
              : (bgColor == Colors.red
                  ? [Colors.redAccent, Colors.red.shade700]
                  : [Color(0xFF3E8EDE), primaryBlue]),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 18),
                SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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

class ChatVendorButton extends StatelessWidget {
  final int vendorId;
  final Map<String, dynamic>? vendorData;

  const ChatVendorButton({
    Key? key,
    required this.vendorId,
    required this.vendorData,
  }) : super(key: key);

  Future<void> _startChat(BuildContext context) async {
    try {
      // Debug output untuk vendorId dan vendorData
      debugPrint("Vendor ID: $vendorId");
      debugPrint("Vendor Data: $vendorData");

      final chatRoom =
          await ChatService.getOrCreateChatRoom(vendorId: vendorId);

      if (chatRoom != null) {
        final prefs = await SharedPreferences.getInstance();
        final customerId = prefs.getInt('user_id');

        // Debug output untuk customerId
        debugPrint("Customer ID: $customerId");

        if (customerId != null) {
          final receiverId = vendorData?['user_id'] ??
              0; // Menggunakan vendorData untuk receiverId

          // Debug output untuk receiverId
          debugPrint("Receiver ID: $receiverId");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                chatRoomId: chatRoom['id'],
                receiverId: receiverId,
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
      // Debug output untuk error
      debugPrint("Error starting chat: $e");
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
