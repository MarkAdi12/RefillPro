import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/account/components/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:customer_frontend/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
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
                _fetchUserData(); 
              }
            },
            child: Text('Edit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const ProfilePic(),
                  Text(
                    userData?["first_name"] != null &&
                            userData?["last_name"] != null
                        ? "${userData?["first_name"]} ${userData?["last_name"]}"
                        : "N/A",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 32.0),
                  Info(
                      infoKey: "Username",
                      info: userData?["username"] ?? "N/A"),
                  Info(infoKey: "Address", info: userData?["address"] ?? "N/A"),
                  Info(
                      infoKey: "Mobile Number",
                      info: userData?["phone_number"] ?? "N/A"),
                  Info(
                      infoKey: "Email Address",
                      info: userData?["email"] ?? "N/A"),
                  const SizedBox(height: 16.0),
                ],
              ),
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
  const Info({
    super.key,
    required this.infoKey,
    required this.info,
  });

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
              Text(
                info.length > 20 ? '${info.substring(0, 20)}...' : info,
                style: const TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.visible,
              )
            ],
          ),
          SizedBox(height: 14),
          Divider(),
        ],
      ),
    );
  }
}
