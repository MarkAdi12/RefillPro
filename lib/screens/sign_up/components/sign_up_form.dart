import 'package:flutter/material.dart';
import 'package:customer_frontend/screens/sign_in/sign_in_screen.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import '../../../services/registration_service.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
    final _formKey = GlobalKey<FormState>();
  final RegistrationService _registrationService = RegistrationService();

  final FocusNode _addressFocusNode = FocusNode();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  double? selectedLat;
  double? selectedLng;

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: Icon(icon, size: 22),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            labelText: "Username",
            hintText: "Enter your username",
            icon: Icons.person,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a username' : null,
          ),
          _buildTextField(
            controller: _passwordController,
            labelText: "Password",
            hintText: "Enter your password",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a password' : null,
          ),
          _buildTextField(
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            icon: Icons.lock,
            obscureText: true,
            validator: (value) => value != _passwordController.text
                ? 'Passwords do not match'
                : null,
          ),
          _buildTextField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter an email' : null,
          ),
          _buildTextField(
            controller: _firstNameController,
            labelText: "First Name",
            hintText: "Enter your first name",
            icon: Icons.person,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your first name' : null,
          ),
          _buildTextField(
            controller: _lastNameController,
            labelText: "Last Name",
            hintText: "Enter your last name",
            icon: Icons.person,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your last name' : null,
          ),
          _buildTextField(
            controller: _phoneNumberController,
            labelText: "Phone Number",
            hintText: "Enter your phone number",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a phone number' : null,
          ),
          SizedBox(height: 10),
          GooglePlaceAutoCompleteTextField(
            textEditingController: _addressController,
            googleAPIKey: "AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk",
            inputDecoration: InputDecoration(
              labelText: "Enter Address",
              border: OutlineInputBorder(),
            ),
            debounceTime: 400,
            countries: ["PH"],
            isLatLngRequired: true,
            focusNode: _addressFocusNode, 
            getPlaceDetailWithLatLng: (placeDetail) {
              setState(() {
                selectedLat = double.tryParse(placeDetail.lat ?? '');
                selectedLng = double.tryParse(placeDetail.lng ?? '');
                print(
                    "Selected Location:\nLatitude: $selectedLat\nLongitude: $selectedLng");
              });
              _addressFocusNode.requestFocus(); 
            },
            itemClick: (prediction) {
              _addressController.text = prediction.description!;
              _addressController.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length),
              );
              _addressFocusNode.requestFocus(); 
            },
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  final response = await _registrationService.registerUser(
                    username: _usernameController.text,
                    password: _passwordController.text,
                    confirmpassword: _confirmPasswordController.text,
                    email: _emailController.text,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    phoneNumber: _phoneNumberController.text,
                    address: _addressController.text,
                    lat: selectedLat ?? 0.0,
                    long: selectedLng ?? 0.0,
                  );
                  if (response['error'] != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['error'])),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  }
                }
              },
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
