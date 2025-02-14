import 'package:flutter/material.dart';
import 'package:customer_frontend/components/custom_appbar.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _secureStorage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? userData;

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Profile Details'),
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
                        title: "Username", value: userData?["username"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                        title: "Full Name",
                        value:
                            "${userData?["first_name"] ?? ""} ${userData?["last_name"] ?? ""}".trim()),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                        title: "Email", value: userData?["email"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                        title: "Mobile Number", value: userData?["phone_number"] ?? "N/A"),
                    const SizedBox(height: 16),
                    _buildProfileCard(
                        title: "Address", value: userData?["address"] ?? "N/A"),
                  ],
                ),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
