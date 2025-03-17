import 'package:customer_frontend/screens/account/components/edit_password.dart';
import 'package:customer_frontend/screens/login/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_service.dart';
import 'components/profile_menu.dart';
import 'components/view_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();
  bool _isLoggingOut = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfileMenu(
              text: "Profile",
              icon: Icons.person_2_rounded,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewProfile()),
                );
              },
            ),
            ProfileMenu(
              text: "Change Password",
              icon: Icons.lock,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditPassword()),
                );
              },
            ),
            ProfileMenu(
              text: "Settings",
              icon: Icons.settings,
              press: () {},
            ),
            ProfileMenu(
              text: _isLoggingOut ? "Logging Out..." : "Log Out",
              icon: Icons.logout_rounded,
              press: _isLoggingOut ? null : () => _logout(),
            ),
          ],
        ),
      ),
    );
  }
}
