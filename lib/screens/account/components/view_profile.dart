import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/account/components/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final _secureStorage = const FlutterSecureStorage();


  String? name;
  String? address;
  String? phoneNumber;
  String? userName;
  String? email;
  bool isLoading = true;
  LatLng? userLocation;

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
        userName = userMap['username'] ?? 'NA';
        email = userMap['email'] ?? 'No email available';
        print("Email after setState: $email");
        userLocation = LatLng(lat, lng);
        isLoading = false;
         print(userData);
      });
    } else {
      setState(() => isLoading = false);
        print(userData);
    }
  }

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          TextButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
              if (updated == true) {
                _loadUserAddress();
              }
            },
            child: const Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(children: [
                const ProfilePic(),
                Text(
                  name ?? "N/A",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 32.0),
                Info(infoKey: "Email", info: email ?? "N/A"),
                Info(infoKey: "Address", info: address ?? "N/A"),
                Info(infoKey: "Mobile Number", info: phoneNumber ?? "N/A"),
              ]),
            ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: const CircleAvatar(
        radius: 50,
        backgroundColor: kPrimaryColor,
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({super.key, required this.infoKey, required this.info});

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                infoKey,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .color!
                      .withOpacity(0.8),
                ),
              ),
              Flexible(
                child: Text(
                  info.length > 20 ? '${info.substring(0, 20)}...' : info,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
        ],
      ),
    );
  }
}
