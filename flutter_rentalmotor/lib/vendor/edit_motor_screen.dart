// lib/screens/edit_motor_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/services/vendor_motor_api.dart'; // Import VendorMotorApi

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
  late String motorImage; // Image URL
  late double motorRating;
  File? _image; // Variable to hold the selected image

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing motor data
    motorName = widget.motor.name;
    motorYear = widget.motor.year;
    motorPrice = widget.motor.price;
    motorColor = widget.motor.color;
    motorStatus = widget.motor.status;
    motorType = widget.motor.type;
    motorDescription = widget.motor.description;
    motorImage = widget.motor.image ?? ''; // Set image if available
    motorRating = widget.motor.rating;
  }

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image =
            File(pickedFile.path); // Save picked image to the file variable
        print(
            "Image selected: ${_image!.path}"); // Debugging: Print selected image path
      });
    } else {
      print("No image selected!"); // Debugging: If no image is selected
    }
  }

  // Function to submit form data and update motor with image upload
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a MotorModel object with updated data
      MotorModel updatedMotor = MotorModel(
        id: widget.motor.id,
        name: motorName,
        brand: widget.motor.brand, // Keeping original brand
        year: motorYear,
        price: motorPrice,
        color: motorColor,
        status: motorStatus,
        type: motorType,
        description: motorDescription,
        image: motorImage,
        rating: motorRating,
      );

      // Debugging: Log the data being passed to the updateMotor function
      print("Updated motor data: ${updatedMotor.toJson()}");

      // Call the VendorMotorApi to update motor data with image
      try {
        VendorMotorApi vendorMotorApi = VendorMotorApi();

        // Log before calling the updateMotor function
        print("Calling updateMotor API...");

        // Call the updateMotor function with the updated data and selected image
        await vendorMotorApi.updateMotor(updatedMotor, _image);

        // After the update, return to the previous screen without showing success snackbar
        Navigator.pop(context); // Go back to the previous screen
      } catch (e) {
        // Handle error if API call fails
        print("Error updating motor: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Motor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: motorName,
                decoration: const InputDecoration(labelText: 'Motor Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor name';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorName = value!;
                },
              ),
              TextFormField(
                initialValue: motorYear.toString(),
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor year';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorYear = int.parse(value!);
                },
              ),
              TextFormField(
                initialValue: motorPrice.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor price';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorPrice = double.parse(value!);
                },
              ),
              TextFormField(
                initialValue: motorColor,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor color';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorColor = value!;
                },
              ),
              TextFormField(
                initialValue: motorStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor status';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorStatus = value!;
                },
              ),
              TextFormField(
                initialValue: motorType,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter motor type';
                  }
                  return null;
                },
                onSaved: (value) {
                  motorType = value!;
                },
              ),
              TextFormField(
                initialValue: motorDescription,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                onSaved: (value) {
                  motorDescription = value!;
                },
              ),
              // Image Picker
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(_image == null ? 'Pick Image' : 'Change Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Motor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
