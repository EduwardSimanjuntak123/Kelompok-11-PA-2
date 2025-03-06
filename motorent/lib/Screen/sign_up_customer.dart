import 'package:flutter/material.dart';
import 'package:motorent2/Screen/sign_in.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import tambahan

class SignUpCustomer extends StatefulWidget {
  const SignUpCustomer({Key? key}) : super(key: key);

  @override
  _SignUpCustomerState createState() => _SignUpCustomerState();
}

class _SignUpCustomerState extends State<SignUpCustomer> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _joinDateController = TextEditingController();
  bool _isLoading = false; // Tambahkan state untuk loading

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
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
                style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 200.0),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                color: Colors.white,
              ),
              height: double.infinity,
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTextField('Full Name', false),
                      _buildTextField('Address', false),
                      _buildTextField('Phone Number', false, TextInputType.phone),
                      _buildTextField('Email', false, TextInputType.emailAddress),
                      _buildDatePickerField('Date of Birth', _dateOfBirthController),
                      _buildTextField('Image', false),
                      _buildDatePickerField('Join Date', _joinDateController),
                      _buildPasswordField('Password', _obscurePassword, (value) {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      }),
                      _buildPasswordField('Confirm Password', _obscureConfirmPassword, (value) {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      }),
                      const SizedBox(height: 40),
                      _buildRegisterButton(),
                      const SizedBox(height: 30),
                      _buildSignInOption(),
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

  Widget _buildTextField(String label, bool isPassword, [TextInputType? keyboardType]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF1B4E75), fontWeight: FontWeight.bold),
        ),
        keyboardType: keyboardType,
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
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
          labelStyle: const TextStyle(color: Color(0xFF1B4E75), fontWeight: FontWeight.bold),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, bool obscure, Function onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF1B4E75), fontWeight: FontWeight.bold),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => onToggle(obscure),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });
          // Simulate a delay for loading
          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _isLoading = false;
            });
            // Handle form submission here
          });
        }
      },
      child: Container(
        height: 55,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(colors: [Color(0xFF1B4E75), Color(0xFF102A43)]),
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

  Widget _buildSignInOption() {
    return Column(
      children: [
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
