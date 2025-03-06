import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;

  // Text controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final roleController = TextEditingController();
  final imageController = TextEditingController();
  final joinController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B4E75),
              Colors.white,
            ],
            stops: [0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 30),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: nameController,
                              label: 'Nama',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter name' : null,
                            ),
                            _buildTextField(
                              controller: addressController,
                              label: 'Alamat',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter address' : null,
                            ),
                            _buildTextField(
                              controller: phoneController,
                              label: 'No.Telepon',
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter phone number' : null,
                            ),
                            _buildTextField(
                              controller: passwordController,
                              label: 'Password',
                              obscureText: true,
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter password' : null,
                            ),
                            _buildTextField(
                              controller: roleController,
                              label: 'Role',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter role' : null,
                            ),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date Of The Day',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  selectedDate != null
                                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                      : 'Select Date',
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: imageController,
                              label: 'Image',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter image' : null,
                            ),
                            _buildTextField(
                              controller: joinController,
                              label: 'Bergabung',
                              validator: (value) =>
                                  value!.isEmpty ? 'Please enter join date' : null,
                            ),
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Handle form submission
                                    print('Form is valid');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1B4E75),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white, // Warna teks diubah menjadi putih
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }
}
