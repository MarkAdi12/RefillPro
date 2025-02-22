import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import '../../../services/location_service.dart';
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
  GoogleMapController? _mapController;
  final _secureStorage = const FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final String apiKey = "AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk";
  double? selectedLat;
  double? selectedLng;
  bool _isEditing = true;

  Future<void> _getCurrentLocation() async {
    setState(() {});

    LatLng? location = await LocationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        selectedLat = location.latitude;
        selectedLng = location.longitude;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(selectedLat!, selectedLng!)),
        );
      }

      String? address = await getAddressFromLatLng(selectedLat!, selectedLng!);
      if (address != null) {
        setState(() {
          _addressController.text = address;
        });
      }
    }

    setState(() {});
  }

  void _onMarkerDragEnd(LatLng newPosition) async {
    setState(() {
      selectedLat = newPosition.latitude;
      selectedLng = newPosition.longitude;
    });

    // Get new address from the dragged marker's position
    String? address = await getAddressFromLatLng(selectedLat!, selectedLng!);
    if (address != null) {
      setState(() {
        _addressController.text = address;
      });
    }
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(newPosition),
      );
    }
  }

  Future<String?> getAddressFromLatLng(double lat, double lng) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          return data["results"][0]["formatted_address"];
        }
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
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
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a username' : null,
          ),
          _buildTextField(
            controller: _passwordController,
            labelText: "Password",
            hintText: "Enter your password",
            obscureText: true,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a password' : null,
          ),
          _buildTextField(
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            obscureText: true,
            validator: (value) => value != _passwordController.text
                ? 'Passwords do not match'
                : null,
          ),
          _buildTextField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter an email' : null,
          ),
          _buildTextField(
            controller: _firstNameController,
            labelText: "First Name",
            hintText: "Enter your first name",
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your first name' : null,
          ),
          _buildTextField(
            controller: _lastNameController,
            labelText: "Last Name",
            hintText: "Enter your last name",
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter your last name' : null,
          ),
          _buildTextField(
            controller: _phoneNumberController,
            labelText: "Phone Number",
            hintText: "Enter your phone number",
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Please enter a phone number' : null,
          ),
          SizedBox(height: 10),
          if (_isEditing)
            GooglePlaceAutoCompleteTextField(
              textEditingController: _addressController,
              googleAPIKey: "AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk",
              inputDecoration: InputDecoration(
                labelText: "Address",
                hintText: "Enter Address",
                suffixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                    Future.delayed(Duration(milliseconds: 1), () {
                      setState(() {
                        _isEditing = true;
                      });
                    });
                  },
                ),
              ),
              debounceTime: 400,
              countries: ["PH"],
              isLatLngRequired: true,
              isCrossBtnShown: false,
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
            )
          else
            Text(''),
          Stack(
            children: [
              GestureDetector(
                onVerticalDragUpdate: (_) {},
                child: SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        _mapController = controller;
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(selectedLat ?? 0.0, selectedLng ?? 0.0),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                          markerId: const MarkerId("customer_location"),
                          position:
                              LatLng(selectedLat ?? 0.0, selectedLng ?? 0.0),
                          onDragEnd: _onMarkerDragEnd,
                          draggable: true),
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 10,
                child: FloatingActionButton(
                  onPressed: _getCurrentLocation,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              onPressed: () async {
                String? fcmToken = await _secureStorage.read(key: 'fcm_token');
                if (fcmToken == null) {
                  print("No FCM token found");
                } else {
                  print("FCM token found: $fcmToken");
                }
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
