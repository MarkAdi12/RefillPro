import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/account/components/edit_profile.dart';
import 'package:customer_frontend/screens/forgot_password/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:customer_frontend/screens/init_screen.dart';
import 'edit_password.dart';
import 'profile_menu.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  final AuthService _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();
  bool _isLoggingOut = false;
  String? name;
  String? address;
  String? phoneNumber;
  String? userName;
  String? email;
  bool isLoading = true;
  LatLng? userLocation;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });

    String? token = await _secureStorage.read(key: 'access_token');

    if (token != null) {
      final response = await _authService.logout(token);

      if (response != null) {
        print('✅ Logout successful');

        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.delete(key: 'refresh_token');
        if (mounted) {
          _authService.cancelLogoutTimer();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      } else {
        print('❌ Logout failed');
      }
    } else {
      print('⚠️ No token found, logging out locally');

      // Clear storage to ensure full logout
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'refresh_token');

      // Redirect to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    }

    setState(() {
      _isLoggingOut = false;
    });
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
        automaticallyImplyLeading: false,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
        actions: [
          TextButton(
            onPressed: isLoading
                ? null // Disable navigation while loading
                : () async {
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
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const ProfilePic(),
                Text(
                  name ?? "N/A",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 32.0),
                Info(infoKey: "Email", info: email ?? "N/A"),
                Info(infoKey: "Address", info: address ?? "N/A"),
                Info(infoKey: "Mobile Number", info: phoneNumber ?? "N/A"),
                ProfileMenu(
                  text: "Change Password",
                  icon: Icons.lock,
                  press: isLoading
                      ? null // Prevent pressing while loading
                      : () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPassword()));
                        },
                ),
                ProfileMenu(
                  text: _isLoggingOut ? "Logging Out..." : "Log Out",
                  icon: Icons.logout_rounded,
                  press: _isLoggingOut ? null : () => _logout(),
                ),
              ],
            ),
          ),
          if (isLoading) ...[
            ModalBarrier(
              dismissible: false, // Prevent user interaction
              color: Colors.black.withOpacity(0.3),
            ),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ],
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
