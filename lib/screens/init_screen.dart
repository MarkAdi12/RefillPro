import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/account/components/view_profile.dart';
import 'package:customer_frontend/screens/order_history/order_history_screen.dart';
import 'package:customer_frontend/screens/track_order/track_screen.dart';
import 'package:customer_frontend/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  final int initialIndex;

  const InitScreen({super.key, this.initialIndex = 0}); // DEFAULT HOME

  @override
  State<InitScreen> createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> {
  late int currentSelectedIndex;
  bool isNavigationDisabled = false; // Prevent navigation when true

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = widget.initialIndex;
  }

  void updateCurrentIndex(int index) {
    if (!isNavigationDisabled) {
      setState(() {
        currentSelectedIndex = index;
      });
    }
  }

  void setNavigationDisabled(bool value) {
    setState(() {
      isNavigationDisabled = value;
    });
  }

  final pages = [
    HomeScreen(),
    OrderTrackingScreen(),
    const OrderHistoryScreen(),
    const ViewProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: IgnorePointer(
        ignoring: isNavigationDisabled, // Disable navigation if true
        child: BottomNavigationBar(
          onTap: updateCurrentIndex,
          currentIndex: currentSelectedIndex,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: inActiveIconColor,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined, size: 22),
              activeIcon: Icon(Icons.store_rounded, size: 26),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining_outlined, size: 22),
              activeIcon: Icon(Icons.delivery_dining, size: 26),
              label: "Track",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, size: 22),
              activeIcon: Icon(Icons.history_rounded, size: 26),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin, size: 22),
              activeIcon: Icon(Icons.person_pin, size: 26),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
