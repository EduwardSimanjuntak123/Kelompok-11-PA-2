import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateMotorScreen extends StatefulWidget {
  const CreateMotorScreen({super.key});

  @override
  State<CreateMotorScreen> createState() => _CreateMotorScreenState();
}

class _CreateMotorScreenState extends State<CreateMotorScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final picker = ImagePicker();

  // Form fields
  String? _name, _brand, _color, _description;
  int? _year;
  double? _price;
  String _status = 'available';
  String _type = 'matic';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Kirim ke backend atau lakukan POST
      print("🚀 Kirim Data Motor:");
      print("Name: $_name, Brand: $_brand,  Year: $_year");
      print("Price: $_price, Color: $_color, Type: $_type, Status: $_status");
      print("Image: ${_imageFile?.path}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Motor"),
        backgroundColor: const Color(0xFF1A567D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text("Pilih Gambar"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nama Motor'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                onSaved: (val) => _name = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Brand'),
                onSaved: (val) => _brand = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tahun'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _year = int.tryParse(val ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Harga / hari'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _price = double.tryParse(val ?? ''),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Warna'),
                onSaved: (val) => _color = val,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'booked', child: Text('Dipesan')),
                  DropdownMenuItem(
                      value: 'unavailable', child: Text('Tidak tersedia')),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipe Motor'),
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'matic', child: Text('Matic')),
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'kopling', child: Text('Kopling')),
                  DropdownMenuItem(value: 'vespa', child: Text('Vespa')),
                ],
                onChanged: (val) => setState(() => _type = val!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                onSaved: (val) => _description = val,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A567D),
                ),
                child: const Text("Simpan Motor",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
