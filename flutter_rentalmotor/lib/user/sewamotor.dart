import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SewaMotorPage extends StatefulWidget {
  final Map<String, dynamic> motor;

  SewaMotorPage({required this.motor});

  @override
  _SewaMotorPageState createState() => _SewaMotorPageState();
}

class _SewaMotorPageState extends State<SewaMotorPage> {
  // Controller untuk input tanggal dan waktu (dipisah)
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();

  // Controller untuk input lainnya
  TextEditingController _durationController = TextEditingController();
  TextEditingController _pickupLocationController = TextEditingController();
  TextEditingController _dropoffLocationController = TextEditingController();

  File? _photoId;
  File? _ktpId;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  // Memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
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

  // Memilih waktu
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Pilih Jam',
    );
    if (pickedTime != null) {
      setState(() {
        // Format waktu: HH:mm (misalnya 23:00)
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  // Menggabungkan tanggal & waktu lalu konversi ke ISO8601 (UTC)
  String _convertToISO8601(String dateStr, String timeStr) {
    // Misal: dateStr = "15/04/2025", timeStr = "23:00"
    DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
    // Parsing waktu: ambil jam dan menit. (Jika format waktu lokal, misalnya "11:00 PM", gunakan DateFormat.jm() untuk parsing)
    // Di sini asumsikan format 24 jam "HH:mm". Jika tidak, Anda bisa menyesuaikan parsing waktu.
    List<String> timeParts = timeStr.split(':');
    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
    DateTime combined = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
    return combined.toUtc().toIso8601String();
  }

  // Tampilan input gambar yang menyerupai field
  Widget _buildImageInput(
      {required String label, required File? file, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.image, color: Colors.grey),
            SizedBox(width: 12),
            Text(
              file == null ? "$label *" : "Gambar telah dipilih",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
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
    // Validasi input wajib
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

    try {
      var uri = Uri.parse("http://localhost:8080/customer/bookings");
      var request = http.MultipartRequest("POST", uri);

      request.fields['motor_id'] = widget.motor['id'].toString();
      request.fields['start_date'] =
          _convertToISO8601(_dateController.text, _timeController.text);
      request.fields['duration'] = _durationController.text;
      request.fields['pickup_location'] = _pickupLocationController.text;
      if (_dropoffLocationController.text.isNotEmpty) {
        request.fields['dropoff_location'] = _dropoffLocationController.text;
      }

      request.files
          .add(await http.MultipartFile.fromPath('photo_id', _photoId!.path));
      request.files
          .add(await http.MultipartFile.fromPath('ktp_id', _ktpId!.path));

      var response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pemesanan berhasil!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal melakukan pemesanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sewa Motor - ${widget.motor["name"]}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Input Tanggal
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Tanggal *",
                hintText: "Pilih tanggal",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),
            // Input Jam
            TextField(
              controller: _timeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Jam *",
                hintText: "Pilih jam",
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: () => _selectTime(context),
            ),
            SizedBox(height: 16),
            // Input Duration (hari)
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Duration (hari) *",
                hintText: "Masukkan durasi dalam hari",
              ),
            ),
            SizedBox(height: 16),
            // Input Pickup Location
            TextField(
              controller: _pickupLocationController,
              decoration: InputDecoration(
                labelText: "Pickup Location *",
                hintText: "Masukkan lokasi pengambilan",
              ),
            ),
            SizedBox(height: 16),
            // Input Dropoff Location (opsional)
            TextField(
              controller: _dropoffLocationController,
              decoration: InputDecoration(
                labelText: "Dropoff Location",
                hintText: "Masukkan lokasi pengembalian (opsional)",
              ),
            ),
            SizedBox(height: 16),
            // Input Gambar: Foto ID
            _buildImageInput(
              label: "Pilih Foto ID",
              file: _photoId,
              onTap: () => _pickImage(false),
            ),
            // Input Gambar: KTP
            _buildImageInput(
              label: "Pilih KTP",
              file: _ktpId,
              onTap: () => _pickImage(true),
            ),
            SizedBox(height: 32),
            // Tombol Submit
            SizedBox(
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
}
