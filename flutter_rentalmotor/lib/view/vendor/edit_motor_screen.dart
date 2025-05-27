import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_rentalmotor/models/motor_model.dart';
import 'package:flutter_rentalmotor/config/api_config.dart';
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
  late String motorPlate;
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
  bool _isLoading = false;

  // Theme colors
  final Color primaryColor = const Color(0xFF1A567D);
  final Color secondaryColor = const Color(0xFF00BFA5);
  final Color accentColor = const Color(0xFFFF6D00);
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
    motorName = widget.motor.name;
    motorPlate = widget.motor.plate ?? '';
    motorYear = widget.motor.year;
    motorPrice = widget.motor.price;
    motorColor = widget.motor.color;
    motorStatus = widget.motor.status;
    motorType = _convertMotorType(widget.motor.type); // Convert type value
    motorDescription = widget.motor.description;
    motorImage = widget.motor.image ?? '';
    motorRating = widget.motor.rating;
  }

  String _convertMotorType(String backendType) {
    switch (backendType.toLowerCase()) {
      case 'automatic':
        return 'automatic';
      case 'manual':
        return 'manual';
      case 'clutch':
        return 'clutch';
      case 'vespa':
        return 'vespa';
      default:
        return 'automatic'; // fallback default
    }
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
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState!.save();

      MotorModel updatedMotor = MotorModel(
        id: widget.motor.id,
        name: motorName,
        plate: motorPlate,
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

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Motor berhasil diperbarui'),
            ]),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(10),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error: $e')),
              ],
            ),
            backgroundColor: dangerColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: EdgeInsets.all(10),
          ),
        );
      }
    }
  }

  void _confirmUpdate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Text(
              'Konfirmasi Update',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin memperbarui data motor ini?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pastikan semua data yang dimasukkan sudah benar.',
              style: TextStyle(
                color: textSecondaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: textSecondaryColor,
            ),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitForm();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Ya, Update'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Motor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Memperbarui data motor...',
                    style: TextStyle(
                      color: textSecondaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Motor Image Preview
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: screenHeight * 0.25,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _image != null
                                  ? Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    )
                                  : motorImage.isNotEmpty
                                      ? Image.network(
                                          motorImage.startsWith('http')
                                              ? motorImage
                                              : '${ApiConfig.baseUrl}$motorImage',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey[600],
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 10,
                            child: InkWell(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Fields
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
                          Text(
                            'Informasi Motor',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'Nama Motor',
                            initialValue: motorName,
                            icon: Icons.motorcycle,
                            onSaved: (val) => motorName = val!,
                          ),
                          _buildTextField(
                            label: 'Plat Motor',
                            initialValue: motorPlate,
                            icon: Icons.confirmation_number,
                            onSaved: (val) => motorPlate = val!,
                          ),
                          _buildTextField(
                            label: 'Tahun',
                            initialValue: motorYear.toString(),
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            onSaved: (val) => motorYear = int.parse(val!),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: TextFormField(
                              initialValue: motorPrice.toString(),
                              decoration: InputDecoration(
                                labelText: 'Harga (Rp)',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    'Rp',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C567E),
                                    ),
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mohon masukkan harga';
                                }
                                return null;
                              },
                              onSaved: (val) => motorPrice = double.parse(val!),
                            ),
                          ),
                          _buildTextField(
                            label: 'Warna',
                            initialValue: motorColor,
                            icon: Icons.color_lens,
                            onSaved: (val) => motorColor = val!,
                          ),
                          _buildDropdownField(
                            label: 'Status',
                            initialValue: motorStatus,
                            icon: Icons.info_outline,
                            items: const ['available', 'unavailable', 'booked'],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  motorStatus = val;
                                });
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: DropdownButtonFormField<String>(
                              decoration: _buildInputDecoration(
                                  'Tipe Motor', Icons.category),
                              value: motorType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'automatic', child: Text('Matic')),
                                DropdownMenuItem(
                                    value: 'manual', child: Text('Manual')),
                                DropdownMenuItem(
                                    value: 'clutch', child: Text('Kopling')),
                                DropdownMenuItem(
                                    value: 'vespa', child: Text('Vespa')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => motorType = val);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mohon pilih tipe motor';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: motorDescription,
                            decoration: InputDecoration(
                              hintText: 'Masukkan deskripsi motor',
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            maxLines: 4,
                            onSaved: (val) => motorDescription = val!,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: successColor.withOpacity(0.4),
                          padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 12 : 16),
                        ),
                        onPressed: _confirmUpdate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14 : 16, horizontal: 16),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Mohon masukkan ${label.toLowerCase()}';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryColor),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String initialValue,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    final statusMap = {
      'available': 'Tersedia',
      'unavailable': 'Tidak Tersedia',
      'booked': 'Sedang Digunakan'
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: isSmallScreen ? 14 : 16, horizontal: 16),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              statusMap[value] ?? value,
              style: TextStyle(
                  color: textPrimaryColor, fontSize: isSmallScreen ? 14 : 16),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Mohon pilih ${label.toLowerCase()}';
          }
          return null;
        },
        onSaved: (val) {
          if (val != null) {
            motorStatus = val;
          }
        },
      ),
    );
  }
}
