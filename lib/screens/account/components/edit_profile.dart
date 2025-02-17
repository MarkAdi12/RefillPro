import 'package:customer_frontend/screens/init_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

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
  bool _isEditing = false; // Track if the user is editing
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  double? selectedLat;
  double? selectedLng;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
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
  Future<void> _saveProfile() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      print("No access token found");
      return;
    }

    final updatedData = {
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "email": _emailController.text,
      "phone_number": _phoneNumberController.text,
      "address": _addressController.text,
      "lat": selectedLat ?? 0.0,
      "long": selectedLng ?? 0.0,
    };

    final response = await _authService.editUser(accessToken, updatedData);
    if (response != null) {
      setState(() {
        _isEditing = false;
      });
      print('Profile updated successfully');
    } else {
      print('Failed to update profile');
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => InitScreen()));
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
              },
            ),
        ],
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
                    _buildAddressCard(), // Google Places for Address
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
          child: Text(_isEditing ? "Save Profile" : "Edit Profile"),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          _isEditing
              ? GooglePlaceAutoCompleteTextField(
                  textEditingController: _addressController,
                  googleAPIKey: "AIzaSyAy1hLcI4XMz-UV-JgZJswU5nXcQHcL6mk",
                  inputDecoration: InputDecoration(
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
                )
              : Text(
                  _addressController.text.isNotEmpty
                      ? _addressController.text
                      : "N/A",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
        ],
      ),
    );
  }
}
