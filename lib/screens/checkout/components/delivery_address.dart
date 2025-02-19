import 'package:customer_frontend/screens/account/components/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/controller/cart_controller.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryAddress extends StatefulWidget {
  const DeliveryAddress({super.key});

  @override
  _DeliveryAddressState createState() => _DeliveryAddressState();
}

class _DeliveryAddressState extends State<DeliveryAddress> {
  final CartController cartController = Get.find();
  final AuthService authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  String? name;
  String? address;
  String? phoneNumber;
  bool isLoading = true;
  late GoogleMapController mapController;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    String? accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken == null) {
      return;
    }
    try {
      final userData = await authService.getUser(accessToken);
      if (userData != null) {
        setState(() {
          name = "${userData['first_name']} ${userData['last_name']}";
          address = userData['address'] ?? 'No address provided';
          phoneNumber = userData['phone_number'] ?? 'No phone number available';
          userLocation = LatLng(
            double.parse(userData['lat'] ?? '0'),
            double.parse(userData['long'] ?? '0'),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
     print("User Location: $userLocation");
    return Padding(
      padding: const EdgeInsets.all(5),
      child: SizedBox(
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
                          Container(
                            height: 105,
                            width: 80,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: userLocation!,
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId('user-location'),
                                  position: userLocation!,
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                              },
                              zoomControlsEnabled: false,
                              scrollGesturesEnabled: false,
                              zoomGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name ?? 'Loading...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '$phoneNumber',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$address',
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
                                _fetchUserDetails();
                              }
                            },
                            icon: Icon(Icons.edit_location_alt_outlined,
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
                          onChanged: (value) {
                            cartController.updateRemarks(value);
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
