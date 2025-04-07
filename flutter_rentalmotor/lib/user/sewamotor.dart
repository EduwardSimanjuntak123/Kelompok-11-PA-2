import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';

import 'package:flutter_rentalmotor/services/create_booking_api.dart';

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

  File? _photoId;
  File? _ktpId;
  bool _isLoading = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      helpText: 'Pilih Tanggal',
      locale: const Locale('id', 'ID'),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam',
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

  Future<void> _submitRental() async {
    if (_dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _durationController.text.isEmpty ||
        _pickupLocationController.text.isEmpty ||
        _photoId == null ||
        _ktpId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua kolom yang bertanda *')),
      );
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
      bool success = await BookingService.createBooking(
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

      if (success) {
        // Sukses ditangani di BookingService
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal melakukan pemesanan')),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Sesi Berakhir"),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Login Ulang"),
            ),
          ],
        ),
      );
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Sewa Motor - ${widget.motor["name"]}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // 🔽 Preview Gambar Motor
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.startsWith("http")
                  ? Image.network(imageUrl, height: 200, fit: BoxFit.cover)
                  : Image.asset(imageUrl, height: 200, fit: BoxFit.cover),
            ),
            SizedBox(height: 16),

            _buildTextField(_dateController, "Tanggal *", "Pilih tanggal",
                Icons.calendar_today, () => _selectDate(context)),
            _buildTextField(_timeController, "Jam *", "Pilih jam",
                Icons.access_time, () => _selectTime(context)),
            _buildTextField(_durationController, "Durasi (hari) *",
                "Masukkan durasi dalam hari", null, null,
                keyboardType: TextInputType.number),
            _buildTextField(_pickupLocationController, "Pickup Location *",
                "Masukkan lokasi pengambilan", null, null),
            _buildTextField(_dropoffLocationController, "Dropoff Location",
                "Masukkan lokasi pengembalian (opsional)", null, null),

            _buildImageInput(
                "Pilih Foto ID", _photoId, () => _pickImage(false)),
            if (_photoId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.file(_photoId!, height: 150),
              ),

            _buildImageInput("Pilih KTP", _ktpId, () => _pickImage(true)),
            if (_ktpId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.file(_ktpId!, height: 150),
              ),

            SizedBox(height: 32),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitRental,
                      child: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData? icon, Function()? onTap,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: onTap != null,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: icon != null ? Icon(icon) : null,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImageInput(String label, File? file, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(file == null ? "$label *" : "Gambar telah dipilih"),
      ),
    );
  }
}
