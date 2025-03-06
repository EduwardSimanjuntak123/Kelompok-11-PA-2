import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'welcome_signup_vendor.dart';
import 'sign_in.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  DateTime? _selectedDob;
  DateTime? _selectedJoinDate;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
                  // Page Indicator (Small Circles)
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
                            ? const SizedBox(width: 50) // Empty on page 1
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
                            ? const SizedBox(width: 50) // Empty on page 2
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
          // Loading Spinner Overlay - Full screen when active
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

  // Page 1 (User Info)
  Widget _buildFirstPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField("Full Name"),
            _buildTextField("Address"),
            _buildTextField("Phone"),
            _buildTextField("Email"),
            _buildDatePicker("Date of Birth", _selectedDob, (date) {
              setState(() {
                _selectedDob = date;
              });
            }),
            _buildTextField("Password", obscureText: true),
            _buildDatePicker("Join Date", _selectedJoinDate, (date) {
              setState(() {
                _selectedJoinDate = date;
              });
            }),
            _buildTextField("Image (URL)"),
            // Add sign up button to first page as well for direct access
            const SizedBox(height: 30),
            _buildRegisterButton(),
            _buildSignUpOption(),
          ],
        ),
      ),
    );
  }

  // Page 2 (Vendor Info)
  Widget _buildSecondPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        children: [
          _buildTextField("District"),
          _buildTextField("Vendor Name"),
          _buildTextField("Address"),
          _buildTextField("Description"),
          _buildTextField("Status"),
          const SizedBox(height: 30),
          _buildRegisterButton(),
          _buildSignUpOption(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false}) {
    return Column(
      children: [
        TextFormField(
          obscureText: obscureText,
          decoration: InputDecoration(labelText: label),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter $label';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      children: [
        TextField(
          readOnly: true,
          controller: TextEditingController(
            text: selectedDate == null
                ? ""
                : "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
          ),
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Modified Register Button - Immediately shows spinner and navigates
  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: () {
        // Skip validation for immediate navigation as requested
        // Show loading spinner immediately
        setState(() {
          _isLoading = true;
        });
        
        // Navigate to WelcomeSignUpVendor immediately
        // The loading spinner will be visible during the transition
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeSignupVendorPage()),
        );
      },
      child: Container(
        height: 55,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF1B4E75), Color(0xFF102A43)]),
        ),
        child: const Center(
          child: Text(
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn()));
          },
          child: const Text("Sign in", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1B4E75))),
        ),
      ],
    );
  }
}