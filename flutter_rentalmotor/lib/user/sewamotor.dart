import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SewaMotorPage extends StatefulWidget {
  @override
  _SewaMotorPageState createState() => _SewaMotorPageState();
}

class _SewaMotorPageState extends State<SewaMotorPage> {
  TextEditingController _tanggalMulaiController = TextEditingController();
  TextEditingController _tanggalPengembalianController = TextEditingController();
  TextEditingController _jamPengambilanController = TextEditingController();
  TextEditingController _lokasiPengambilanController = TextEditingController();
  TextEditingController _lokasiPengembalianController = TextEditingController(); 

  @override
  void dispose() {
    _tanggalMulaiController.dispose();
    _tanggalPengembalianController.dispose();
    _jamPengambilanController.dispose();
    _lokasiPengambilanController.dispose();
    _lokasiPengembalianController.dispose(); 
        super.dispose();
  }

  
  Future<void> _selectDate(BuildContext context, TextEditingController controller, {DateTime? firstDate}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _jamPengambilanController.text = picked.format(context);
      });
    }
  }

  void _onNextPressed() {
    if (_tanggalMulaiController.text.isEmpty ||
        _tanggalPengembalianController.text.isEmpty ||
        _jamPengambilanController.text.isEmpty ||
        _lokasiPengambilanController.text.isEmpty ||
        _lokasiPengembalianController.text.isEmpty) { 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua kolom yang bertanda *')),
      );
      return;
    }

    print('Data berhasil diinput:');
    print('Tanggal Mulai: ${_tanggalMulaiController.text}');
    print('Tanggal Pengembalian: ${_tanggalPengembalianController.text}');
    print('Jam Pengambilan: ${_jamPengambilanController.text}');
    print('Lokasi Pengambilan: ${_lokasiPengambilanController.text}');
    print('Lokasi Pengembalian: ${_lokasiPengembalianController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sewa Motor',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Form
            Text(
              'Atur Jadwal Rental Motor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),

            // Tanggal Mulai
            _buildInputField(
              label: "Tanggal Mulai *",
              controller: _tanggalMulaiController,
              icon: Icons.calendar_today,
              onTap: () => _selectDate(context, _tanggalMulaiController),
            ),

            // Tanggal Pengembalian
            _buildInputField(
              label: "Tanggal Pengembalian *",
              controller: _tanggalPengembalianController,
              icon: Icons.calendar_today,
              onTap: () {
                if (_tanggalMulaiController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pilih tanggal mulai terlebih dahulu')),
                  );
                } else {
                  _selectDate(
                    context,
                    _tanggalPengembalianController,
                    firstDate: DateFormat('dd/MM/yyyy').parse(_tanggalMulaiController.text),
                  );
                }
              },
            ),

            // Jam Pengambilan
            _buildInputField(
              label: "Jam Pengambilan *",
              controller: _jamPengambilanController,
              icon: Icons.access_time,
              onTap: () => _selectTime(context),
            ),

            _buildInputField(
              label: "Lokasi Pengembalian *",
              controller: _lokasiPengembalianController,
              hintText: "Masukkan lokasi pengembalian motor",
            ),

            SizedBox(height: 40),

            // Tombol Berikutnya
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Berikutnya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Widget reusable untuk input field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    IconData? icon,
    Function()? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: onTap != null, 
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText ?? '',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              suffixIcon: icon != null
                  ? Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(icon, color: Colors.grey[600]),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
