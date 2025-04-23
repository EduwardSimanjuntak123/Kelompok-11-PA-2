// lib/screens/edit_motor_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/services/vendor/vendor_motor_api.dart';

class EditMotorScreen extends StatefulWidget {
  final MotorModel motor;

  const EditMotorScreen({super.key, required this.motor});

  @override
  _EditMotorScreenState createState() => _EditMotorScreenState();
}

class _EditMotorScreenState extends State<EditMotorScreen> {
  final _formKey = GlobalKey<FormState>();
  late String motorName;
  late int motorYear;
  late double motorPrice;
  late String motorColor;
  late String motorStatus;
  late String motorType;
  late String motorDescription;
  late String motorImage;
  late double motorRating;
  File? _image;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    motorName = widget.motor.name;
    motorYear = widget.motor.year;
    motorPrice = widget.motor.price;
    motorColor = widget.motor.color;
    motorStatus = widget.motor.status;
    motorType = widget.motor.type;
    motorDescription = widget.motor.description;
    motorImage = widget.motor.image ?? '';
    motorRating = widget.motor.rating;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      MotorModel updatedMotor = MotorModel(
        id: widget.motor.id,
        name: motorName,
        brand: widget.motor.brand,
        year: motorYear,
        price: motorPrice,
        color: motorColor,
        status: motorStatus,
        type: motorType,
        description: motorDescription,
        image: motorImage,
        rating: motorRating,
      );

      try {
        VendorMotorApi vendorMotorApi = VendorMotorApi();
        await vendorMotorApi.updateMotor(updatedMotor, _image);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmUpdate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Update'),
        content:
            const Text('Apakah Anda yakin ingin memperbarui data motor ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // tutup dialog
            },
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.black), // warna hitam
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(); // tutup dialog
              _submitForm(); // lanjutkan update
            },
            child: const Text(
              'Ya, Update',
              style: TextStyle(color: Colors.black), // warna hitam
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Motor',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A567D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: 'Motor Name',
                initialValue: motorName,
                onSaved: (val) => motorName = val!,
              ),
              _buildTextField(
                label: 'Year',
                initialValue: motorYear.toString(),
                keyboardType: TextInputType.number,
                onSaved: (val) => motorYear = int.parse(val!),
              ),
              _buildTextField(
                label: 'Price',
                initialValue: motorPrice.toString(),
                keyboardType: TextInputType.number,
                onSaved: (val) => motorPrice = double.parse(val!),
              ),
              _buildTextField(
                label: 'Color',
                initialValue: motorColor,
                onSaved: (val) => motorColor = val!,
              ),
              _buildTextField(
                label: 'Status',
                initialValue: motorStatus,
                onSaved: (val) => motorStatus = val!,
              ),
              _buildTextField(
                label: 'Type',
                initialValue: motorType,
                onSaved: (val) => motorType = val!,
              ),
              TextFormField(
                initialValue: motorDescription,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                onSaved: (val) => motorDescription = val!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _image == null ? 'Pick Image' : 'Change Image',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _confirmUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Update Motor',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter ${label.toLowerCase()}';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
