import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rentalmotor/user/detailMotorVendor/detailmotor.dart';

import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter_rentalmotor/services/customer/create_booking_api.dart';

class SewaMotorPage extends StatefulWidget {
  final Map<String, dynamic> motor;
  final bool isGuest;

  SewaMotorPage({required this.motor, required this.isGuest});

  @override
  _SewaMotorPageState createState() => _SewaMotorPageState();
}

class _SewaMotorPageState extends State<SewaMotorPage> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _pickupLocationController = TextEditingController();
  TextEditingController _dropoffLocationController = TextEditingController();
  List<DateTime> _disabledDates = [];
  File? _photoId;
  File? _ktpId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBookedDates(); // Tambahkan ini
  }

  // Theme colors - Only blue theme
  final Color primaryBlue = Color(0xFF2C567E);
  final Color lightBlue = Color(0xFFE3F2FD);
  final Color accentBlue = Color(0xFF64B5F6);
  final Color darkBlue = Color(0xFF1A3A5A);
  final Color mediumBlue = Color(0xFF4A7AAF);

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookedDates() async {
    try {
      final motorId = widget.motor['id'];
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bookings/motor/$motorId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> bookings = json.decode(response.body);

        List<DateTime> disabled = [];

        for (var booking in bookings) {
          DateTime startDate = DateTime.parse(booking['start_date']).toLocal();
          DateTime endDate = DateTime.parse(booking['end_date']).toLocal();

          for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
            disabled.add(startDate.add(Duration(days: i)));
          }
        }

        setState(() {
          _disabledDates = disabled;
        });
      }
    } catch (e) {
      print('❗ Error fetching booked dates: $e');
    }
  }

  DateTime _getInitialAvailableDate() {
    DateTime today = DateTime.now();

    // Cek mulai dari hari ini sampai ke depan
    for (int i = 0; i < 365; i++) {
      DateTime checkDate = today.add(Duration(days: i));
      bool isDisabled = _disabledDates.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);
      if (!isDisabled) {
        return checkDate;
      }
    }
    // Kalau semua tanggal ke-disable (tidak mungkin sih), fallback
    return today;
  }

  void _selectDate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime selectedDay = _getInitialAvailableDate();

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Pilih Tanggal',
              style:
                  TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  locale: 'id_ID',
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  focusedDay: selectedDay,
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDay, day);
                  },
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Bulan',
                  },
                  onDaySelected: (selected, focused) {
                    bool isDisabled = _disabledDates.any((d) =>
                        d.year == selected.year &&
                        d.month == selected.month &&
                        d.day == selected.day);

                    if (!isDisabled) {
                      setState(() {
                        _dateController.text =
                            DateFormat('dd/MM/yyyy').format(selected);
                      });
                      Navigator.pop(context);
                    }
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      bool isDisabled = _disabledDates.any((d) =>
                          d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day);

                      if (isDisabled) {
                        return Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                        );
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      bool isDisabled = _disabledDates.any((d) =>
                          d.year == day.year &&
                          d.month == day.month &&
                          d.day == day.day);

                      if (isDisabled) {
                        return Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ],
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "* Tanggal dicoret merah berarti sudah dibooking",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      String formattedTime =
          "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }

  String _convertToISO8601(String dateStr, String timeStr) {
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
    List<String> timeParts = timeStr.split(':');

    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;

    DateTime combined = DateTime.utc(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );

    return combined.toIso8601String();
  }

  Future<void> _pickImage(bool isKtp) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isKtp) {
          _ktpId = File(pickedFile.path);
        } else {
          _photoId = File(pickedFile.path);
        }
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Gagal', style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, dynamic motorData, bool isGuest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Berhasil', style: TextStyle(color: Colors.green)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailMotorPage(
                    motorId: motorData["id"],
                    isGuest: isGuest,
                  ),
                ),
              );
            },
            child: Text('Lanjut', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRental() async {
    if (_dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _pickupLocationController.text.isEmpty ||
        _photoId == null ||
        _ktpId == null) {
      _showErrorDialog('Harap isi semua kolom yang bertanda *');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final startDate =
        _convertToISO8601(_dateController.text, _timeController.text);
    final duration = _durationController.text;
    final pickupLocation = _pickupLocationController.text;
    final dropoffLocation = _dropoffLocationController.text;
    final photoId = _photoId!;
    final ktpId = _ktpId!;

    try {
      final result = await BookingService.createBooking(
        context: context,
        motorId: widget.motor['id'],
        startDate: startDate,
        duration: duration,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        photoId: photoId,
        ktpId: ktpId,
        motorData: widget.motor,
        isGuest: widget.isGuest,
      );

      if (result['success']) {
        _showSuccessDialog(
            result['message'], result['motorData'], result['isGuest']);
      } else {
        _showErrorDialog(result['message']);
      }
    } catch (e) {
      _showErrorDialog(
          'Terjadi kesalahan: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        widget.motor["image"] ?? "assets/images/default_motor.png";
    if (imageUrl.startsWith("/")) {
      final String baseUrl = ApiConfig.baseUrl;
      imageUrl = "$baseUrl$imageUrl";
    }

    // Calculate price
    String formattedPrice = "Harga tidak tersedia";
    if (widget.motor["price"] != null) {
      try {
        int price = int.parse(widget.motor["price"].toString());
        formattedPrice = NumberFormat.currency(
          locale: 'id',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(price);
      } catch (e) {
        // Use default value if parsing fails
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        title: Text(
          'Sewa Motor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motor Image and Info
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryBlue, mediumBlue],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl.startsWith("http")
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey[500],
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.motor["name"] ?? "Nama Motor Tidak Tersedia",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.motorcycle,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "$formattedPrice / hari",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: accentBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryBlue, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Silakan isi informasi pemesanan dengan lengkap untuk melanjutkan proses sewa motor",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event_note,
                                color: primaryBlue, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Informasi Pemesanan",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 25, thickness: 1),

                        // Date and Time Fields
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildTextField(
                                _dateController,
                                "Tanggal *",
                                "Pilih tanggal",
                                Icons.calendar_today,
                                () => _selectDate(context),
                                accentColor: accentBlue,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _buildTextField(
                                _timeController,
                                "Jam *",
                                "Pilih jam",
                                Icons.access_time,
                                () => _selectTime(context),
                                accentColor: accentBlue,
                              ),
                            ),
                          ],
                        ),

                        _buildTextField(
                          _durationController,
                          "Durasi (hari) *",
                          "Masukkan durasi dalam hari",
                          Icons.timelapse,
                          null,
                          keyboardType: TextInputType.number,
                          accentColor: primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: mediumBlue, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Informasi Lokasi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mediumBlue,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 25, thickness: 1),
                        _buildTextField(
                          _pickupLocationController,
                          "Lokasi Pengambilan *",
                          "Masukkan lokasi pengambilan",
                          Icons.location_on,
                          null,
                          accentColor: mediumBlue,
                        ),
                        _buildTextField(
                          _dropoffLocationController,
                          "Lokasi Pengembalian",
                          "Masukkan lokasi pengembalian (opsional)",
                          Icons.location_off,
                          null,
                          accentColor: mediumBlue,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
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
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.badge, color: darkBlue, size: 22),
                            SizedBox(width: 10),
                            Text(
                              "Dokumen Identitas",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 25, thickness: 1),

                        // Photo ID Section
                        Text(
                          "Foto Diri *",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildImageInput(
                          "Pilih Foto Diri",
                          _photoId,
                          () => _pickImage(false),
                          Icons.person,
                          darkBlue,
                        ),
                        if (_photoId != null)
                          Container(
                            height: 150,
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 8, bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: darkBlue.withOpacity(0.5), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _photoId!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // KTP Section
                        // KTP Section
                        Text(
                          "Foto KTP *",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildImageInput(
                          "Pilih Foto KTP",
                          _ktpId,
                          () => _pickImage(true),
                          Icons.credit_card,
                          darkBlue,
                        ),
                        if (_ktpId != null)
                          Container(
                            height: 150,
                            width: double.infinity,
                            margin: EdgeInsets.only(top: 8, bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: darkBlue.withOpacity(0.5), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _ktpId!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "* KTP asli tetap diberikan kepada pemilik rental saat penjemputan motor sebagai jaminan.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [mediumBlue, primaryBlue],
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
                        onTap: _isLoading ? null : _submitRental,
                        borderRadius: BorderRadius.circular(15),
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 3,
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Submit Pemesanan",
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
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData? icon,
    Function()? onTap, {
    TextInputType keyboardType = TextInputType.text,
    Color accentColor = Colors.blue,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: accentColor,
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          prefixIcon: icon != null ? Icon(icon, color: accentColor) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImageInput(String label, File? file, Function() onTap,
      IconData icon, Color accentColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file == null ? Colors.grey.shade300 : accentColor,
            width: file == null ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                file == null ? label : "Gambar telah dipilih",
                style: TextStyle(
                  color: file == null ? Colors.grey[600] : accentColor,
                  fontSize: 14,
                  fontWeight:
                      file == null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.add_photo_alternate,
              color: accentColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
