import 'package:flutter/material.dart';
import 'package:flutter_rentalmotor/signin.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_rentalmotor/user/welcome_signup_customer.dart';
import 'package:flutter_rentalmotor/services/auth_service.dart';

class SignUpCustomer extends StatefulWidget {
  const SignUpCustomer({Key? key}) : super(key: key);

  @override
  _SignUpCustomerState createState() => _SignUpCustomerState();
}

class _SignUpCustomerState extends State<SignUpCustomer> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isFormValid = false;

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  void _checkFormValidity() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _checkFormValidity();
      });
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
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 60.0, left: 22),
              child: Text(
                'Create Your\nAccount',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40)),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField('Full Name', _fullNameController, false),
                      _buildTextField('Address', _addressController, false),
                      _buildTextField('Phone Number', _phoneController, false,
                          TextInputType.phone),
                      _buildTextField('Email', _emailController, false,
                          TextInputType.emailAddress),
                      _buildDatePickerField(
                          'Date of Birth', _dateOfBirthController),
                      _buildPasswordField(
                          'Password', _passwordController, _obscurePassword,
                          () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      }),
                      _buildPasswordField(
                          'Confirm Password',
                          _confirmPasswordController,
                          _obscureConfirmPassword, () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      }),
                      const SizedBox(height: 40),
                      _buildRegisterButton(),
                      const SizedBox(height: 30),
                      _buildSignInOption(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool isPassword,
      [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
        onChanged: (value) {
          setState(() {
            _checkFormValidity();
          });
        },
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.blueGrey),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool obscure, Function onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.blueGrey),
            onPressed: () {
              onToggle();
              setState(() {});
            },
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
        onChanged: (value) {
          setState(() {
            _checkFormValidity();
          });
        },
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isFormValid
          ? () async {
              setState(() {
                _isLoading = true;
              });

              AuthService authService = AuthService();
              final response = await authService.registerCustomer(
                name: _fullNameController.text,
                email: _emailController.text,
                password: _passwordController.text,
                phone: _phoneController.text,
                address: _addressController.text,
                birthDate: _dateOfBirthController.text,
              );

              setState(() {
                _isLoading = false;
              });

              if (response["success"]) {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const WelcomeSignupCustomerPage()),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response["message"])),
                );
              }
            }
          : null,
      child: Container(
        height: 55,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: _isFormValid ? const Color(0xFF225378) : Colors.grey,
        ),
        child: Center(
          child: _isLoading
              ? const SpinKitFadingCircle(color: Colors.white, size: 50.0)
              : const Text('SIGN UP',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSignInOption(BuildContext context) {
    return Column(
      children: [
        const Text("Already have an account?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: const Text("Sign in",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF1B4E75))),
        ),
      ],
    );
  }
}
