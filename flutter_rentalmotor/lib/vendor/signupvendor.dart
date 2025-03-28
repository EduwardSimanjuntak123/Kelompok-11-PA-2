import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rentalmotor/vendor/welcome_signup_vendor.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _currentPage = 0;
  DateTime? _selectedDob;
  DateTime? _selectedJoinDate;
  bool _isLoading = false;
  bool _isFormFilled = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController vendorAddressController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addListeners(); 
  }

  @override
  void dispose() {
    fullNameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    imageUrlController.dispose();
    districtController.dispose();
    vendorNameController.dispose();
    vendorAddressController.dispose();
    descriptionController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void _checkFormFilled() {
    setState(() {
      _isFormFilled = fullNameController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          _selectedDob != null &&
          passwordController.text.isNotEmpty &&
          _selectedJoinDate != null &&
          imageUrlController.text.isNotEmpty &&
          districtController.text.isNotEmpty &&
          vendorNameController.text.isNotEmpty &&
          vendorAddressController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          statusController.text.isNotEmpty;
    });
  }

  void _addListeners() {
    List<TextEditingController> controllers = [
      fullNameController,
      addressController,
      phoneController,
      emailController,
      passwordController,
      imageUrlController,
      districtController,
      vendorNameController,
      vendorAddressController,
      descriptionController,
      statusController
    ];

    for (var controller in controllers) {
      controller.addListener(_checkFormFilled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B4E75), Color(0xFF102A43)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 180.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFF1B4E75)
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 15),
                  // PageView for Forms
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildFirstPage(),
                        _buildSecondPage(),
                      ],
                    ),
                  ),
                  // Navigation Icons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentPage == 0
                            ? const SizedBox(width: 50) 
                            : IconButton(
                                icon: const Icon(Icons.arrow_back, size: 30),
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                        _currentPage == 1
                            ? const SizedBox(width: 50) 
                            : IconButton(
                                icon: const Icon(Icons.arrow_forward, size: 30),
                                onPressed: () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField("Full Name", fullNameController),
            _buildTextField("Address", addressController),
            _buildTextField("Phone", phoneController),
            _buildTextField("Email", emailController),
            _buildDatePicker("Date of Birth", _selectedDob, (date) {
              setState(() {
                _selectedDob = date;
              });
            }),
            _buildTextField("Password", passwordController, obscureText: true),
            _buildDatePicker("Join Date", _selectedJoinDate, (date) {
              setState(() {
                _selectedJoinDate = date;
              });
            }),
            _buildTextField("Image (URL)", imageUrlController),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        children: [
          _buildTextField("District", districtController),
          _buildTextField("Vendor Name", vendorNameController),
          _buildTextField("Address", vendorAddressController),
          _buildTextField("Description", descriptionController),
          _buildTextField("Status", statusController),
          const SizedBox(height: 30),
          _buildRegisterButton(),
          _buildSignUpOption(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: controller.text.isNotEmpty ? Colors.green : Color(0xFF1B4E75), 
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: controller.text.isNotEmpty ? Colors.green : Color(0xFF1B4E75), 
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2), 
          ),
        ),
        style: const TextStyle(color: Color(0xFF1B4E75)), 
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Enter $label';
          }
          return null;
        },
        onChanged: (value) {
          _checkFormFilled(); 
        },
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    TextEditingController controller = TextEditingController(
      text: selectedDate == null
          ? ""
          : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        readOnly: true,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: controller.text.isNotEmpty ? Colors.green : Color(0xFF1B4E75), 
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: controller.text.isNotEmpty ? Colors.green : Color(0xFF1B4E75), 
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2), 
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: controller.text.isNotEmpty ? Colors.green : Color(0xFF1B4E75), 
          ),
        ),
        style: const TextStyle(color: Color(0xFF1B4E75)), 
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            onDateSelected(pickedDate);
            setState(() {
              controller.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        },
      ),
    );
  }

 Widget _buildRegisterButton() {
  return GestureDetector(
    onTap: _isFormFilled
        ? () {
            setState(() {
              _isLoading = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _isLoading = false;
              });
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeSignupVendorPage()),
                );
              }
            });
          }
        : null, // Pastikan tombol hanya bisa ditekan jika form valid
    child: Container(
      height: 55,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: _isFormFilled ? const Color(0xFF225378) : Colors.grey, // Warna biru jika form valid
      ),
      child: Center(
        child: _isLoading
            ? const SpinKitFadingCircle(
                color: Colors.white,
                size: 50.0,
              )
            : const Text(
                'SIGN UP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
      ),
    ),
  );
}



  Widget _buildSignUpOption() {
    return Column(
      children: [
        const SizedBox(height: 15),
        const Text("Already have an account?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: const Text("Sign in", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1B4E75))),
        ),
      ],
    );
  }
}