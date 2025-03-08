import 'dart:convert';
import 'package:customer_frontend/screens/sign_up/components/sign_up_success.dart';
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
  final _passwordKey = GlobalKey<FormFieldState<String>>();
  final _userKey = GlobalKey<FormFieldState<String>>();
  final _confirmPasswordKey = GlobalKey<FormFieldState<String>>();
  final RegistrationService _registrationService = RegistrationService();
  final FocusNode _addressFocusNode = FocusNode();
  GoogleMapController? _mapController;
  List<dynamic> _predictions = [];
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

  Future<void> _getPlacePredictions(String input) async {
    final double latitude = 14.7168117;
    final double longitude = 120.95534;
    final int radius = 3000;

    String baseUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";

    String request =
        "$baseUrl?input=$input&key=$apiKey&location=$latitude,$longitude"
        "&radius=$radius&strictbounds&types=geocode&components=country:PH";

    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _predictions = data["predictions"];
      });
    } else {
      print("Failed to fetch places: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == "OK") {
          return data["result"];
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return null;
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
    VoidCallback? onEditingComplete,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    Key? key,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        key: key,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        validator: validator,
        onEditingComplete: onEditingComplete,
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
            key: _userKey,
            controller: _usernameController,
            labelText: "Username",
            hintText: "Enter your username",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              } else if (value.length < 4) {
                return 'Username must be at least 4 characters long';
              }
              return null;
            },
            onEditingComplete: () {
              _userKey.currentState?.validate();
            },
          ),
          _buildTextField(
            key: _passwordKey,
            controller: _passwordController,
            labelText: "Password",
            hintText: "Enter your password",
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters long';
              } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                return 'Password must contain at least 1 capital letter';
              } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Password must contain at least 1 number';
              }
              return null;
            },
            onEditingComplete: () {
              _passwordKey.currentState?.validate();
            },
          ),
          _buildTextField(
            key:
                _confirmPasswordKey, // Use the GlobalKey for the confirm password field
            controller: _confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            onEditingComplete: () {
              // Validate only the confirm password field
              _confirmPasswordKey.currentState?.validate();
            },
          ),
          _buildTextField(
            controller: _emailController,
            labelText: "Email",
            hintText: "Enter your email",
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              } else if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                return 'Phone number must be exactly 11 digits';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Address",
              hintText: "Enter your address",
              suffixIcon: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  setState(() {
                    if (_addressController.text.trim().isNotEmpty) {
                      _predictions.clear();
                      _isEditing = false;
                    }
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
              if (value.trim().isNotEmpty) {
                _getPlacePredictions(value);
              } else {
                setState(() {
                  _predictions.clear();
                });
              }
            },
          ),
          const SizedBox(height: 8),
          if (_predictions.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_predictions[index]["description"]),
                    onTap: () async {
                      final placeId = _predictions[index]["place_id"];
                      final placeDetails = await getPlaceDetails(placeId);

                      if (placeDetails != null) {
                        final lat = placeDetails["geometry"]["location"]["lat"];
                        final lng = placeDetails["geometry"]["location"]["lng"];

                        setState(() {
                          selectedLat = lat;
                          selectedLng = lng;
                          _addressController.text =
                              _predictions[index]["description"];
                          _predictions.clear();
                        });

                        if (_mapController != null) {
                          _mapController!.animateCamera(
                            CameraUpdate.newLatLng(LatLng(lat, lng)),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
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
                bottom: 50,
                left: 5,
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
                      SnackBar(content: Center(child: Text(response['error']))),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpSuccess()),
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
