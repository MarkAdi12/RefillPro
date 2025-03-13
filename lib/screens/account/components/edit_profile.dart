import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../services/location_service.dart';
import '../../../services/order_list_service.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _secureStorage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  final OrderListService _orderListService = OrderListService();

  Map<String, dynamic>? userData;
  bool _MapIsLoading = false;
  List<dynamic> _predictions = [];
  bool _isEditing = true;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  double? selectedLat;
  double? selectedLng;
  GoogleMapController? _mapController;
  final String apiKey = "AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _addressFocusNode.addListener(() {
      if (!_addressFocusNode.hasFocus) {
        FocusScope.of(context).unfocus(); // Force unfocus to remove suggestions
        setState(() {}); // Trigger UI refresh
      }
    });
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

  Future<void> _getCurrentLocation() async {
    setState(() {
      _MapIsLoading = true;
    });

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

    setState(() {
      _MapIsLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      print("No access token found");
      return;
    }

    final userInfo = await _authService.getUser(accessToken);
    if (userInfo != null) {
      setState(() {
        userData = userInfo;
        _firstNameController.text = userData?["first_name"] ?? "";
        _lastNameController.text = userData?["last_name"] ?? "";
        _emailController.text = userData?["email"] ?? "";
        _phoneNumberController.text = userData?["phone_number"] ?? "";
        _addressController.text = userData?["address"] ?? "";
        selectedLat = double.tryParse(userData?['lat']?.toString() ?? '0.0');
        selectedLng = double.tryParse(userData?['long']?.toString() ?? '0.0');
      });
    }

    // Fetch orders to check if there's a pending order (status == 0)
    final orders = await _orderListService.fetchOrders(accessToken);
    if (orders.any((order) => order['status'] == 0)) {
      setState(() {
        _isEditing = false; // Disable editing if there's a pending order
      });
      _showPendingOrderDialog();
    }
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

  Future<void> _saveProfile() async {
    // Check if all required fields are filled
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _addressController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Missing Information"),
            content:
                const Text("Please fill in all required fields before saving."),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    // Retrieve access token
    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      print("No access token found");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No access token found. Please log in again.")),
      );
      return;
    }

    // Retrieve FCM token
    String? fcmToken = await _secureStorage.read(key: 'fcm_token');
    if (fcmToken == null) {
      print("No FCM token found");
    } else {
      print("FCM token found: $fcmToken");
    }

    // Prepare updated data
    final updatedData = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "email": _emailController.text,
      "phone_number": _phoneNumberController.text,
      "address": _addressController.text,
      "lat": selectedLat ?? userData?['lat'] ?? 0.0,
      "long": selectedLng ?? userData?['long'] ?? 0.0,
      "firebase_tokens": fcmToken,
    };

    try {
      // Call API to update user data
      final response = await _authService.editUser(accessToken, updatedData);
      if (response != null) {
        // Update UI state
        setState(() {
          _isEditing = false;
        });

        // Save updated data to secure storage
        await _secureStorage.write(
            key: 'user_data', value: jsonEncode(updatedData));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );

        print('Profile updated successfully');
        print('Updated user data: $updatedData');
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      print('Failed to update profile: $e');
    }
  }

  void _showPendingOrderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editing Disabled", style: TextStyle(fontSize: 16)),
          content: const Text(
            "You cannot edit your profile because you have a pending order. Please complete or cancel the order before making changes to your profile.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => InitScreen()));
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getPlacePredictions(String input) async {
    final double latitude = 14.7168117;
    final double longitude = 120.95534;
    final int radius = 5000;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: userData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(
                        title: "Username",
                        value: userData?["username"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildEditableCard(
                      title: "First Name",
                      controller: _firstNameController,
                      value: userData?["first_name"] ?? "N/A",
                    ),
                    const SizedBox(height: 16),
                    _buildEditableCard(
                      title: "Last Name",
                      controller: _lastNameController,
                      value: userData?["last_name"] ?? "N/A",
                    ),
                    const SizedBox(height: 16),
                    _buildEditableCard(
                        title: "Email",
                        controller: _emailController,
                        value: userData?["email"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildEditableCard(
                        title: "Mobile Number",
                        controller: _phoneNumberController,
                        value: userData?["phone_number"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildAddressCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isEditing
              ? _saveProfile
              : () {
                  setState(() {
                    _isEditing = true;
                  });
                },
          child: Text(_isEditing ? "Save Profile" : "Save Profile"),
        ),
      ),
    );
  }

  Widget _buildProfileCard({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(
      {required String title,
      required TextEditingController controller,
      required String value}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                )
              : Text(
                  value.isNotEmpty ? value : "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Address",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          if (selectedLat != null && selectedLng != null)
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
                          draggable: _isEditing,
                          onDragEnd: _onMarkerDragEnd,
                        ),
                      },
                      gestureRecognizers: <Factory<
                          OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 50,
                    left: 5,
                    child: FloatingActionButton(
                      onPressed: _MapIsLoading ? null : _getCurrentLocation,
                      backgroundColor: Colors.blue,
                      child: _MapIsLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter your address",
              suffixIcon: IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  setState(() {
                    _predictions.clear();
                    _isEditing = false;
                  });
                  Future.delayed(Duration(milliseconds: 1), () {
                    setState(() {
                      _predictions.clear();
                      _isEditing = true;
                    });
                  });
                },
              ),
            ),
            onChanged: (value) {
              setState(() {
                if (value.trim().isNotEmpty) {
                  _getPlacePredictions(value);
                } else {
                  _predictions.clear();
                }
              });
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
                    onTap: () {
                      _addressController.text =
                          _predictions[index]["description"];
                      setState(() {
                        _predictions.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
