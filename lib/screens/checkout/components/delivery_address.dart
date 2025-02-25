import 'package:customer_frontend/screens/account/components/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class DeliveryAddress extends StatefulWidget {
  const DeliveryAddress({super.key});

  @override
  _DeliveryAddressState createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  final CartController cartController = Get.find();
  final _secureStorage = const FlutterSecureStorage();

  String name = 'Loading...';
  String address = 'No address available';
  String phoneNumber = 'No phone number available';
  bool isLoading = true;
  GoogleMapController? mapController;
  LatLng userLocation = const LatLng(0, 0); // Default value

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    String? userData = await _secureStorage.read(key: 'user_data');

    if (userData != null) {
      final userMap = jsonDecode(userData);
      double lat = double.tryParse(userMap['lat']?.toString() ?? '0') ?? 0.0;
      double lng = double.tryParse(userMap['long']?.toString() ?? '0') ?? 0.0;

      setState(() {
        name = "${userMap['first_name']} ${userMap['last_name']}";
        address = userMap['address'] ?? 'No address available';
        phoneNumber = userMap['phone_number'] ?? 'No phone number available';
        userLocation = LatLng(lat, lng);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("User Location: $userLocation");

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 105,
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: userLocation,
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('user-location'),
                                  position: userLocation,
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                setState(() {
                                  mapController = controller;
                                });
                              },
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                phoneNumber,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                address,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile()),
                            );
                            if (result == true) {
                              _loadUserAddress();
                            }
                          },
                          icon: const Icon(Icons.edit_location_alt_outlined,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: TextField(
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Delivery instructions',
                          labelStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryColor,
                          ),
                          hintText: 'Note to rider - e.g. landmark',
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                        ),
                        onChanged: cartController.updateRemarks,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
