import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/order_history/order_history_screen.dart';
import 'package:customer_frontend/screens/track_order/track_screen.dart';
import 'package:customer_frontend/screens/home/home_screen.dart';
import 'package:customer_frontend/screens/account/profile_screen.dart';
import 'package:flutter/material.dart';

const Color inActiveIconColor = Color(0xFFB6B6B6);

class InitScreen extends StatefulWidget {
  final int initialIndex;
  

  const InitScreen({super.key, this.initialIndex = 0}); // DEFAULT HOME

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  late int currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = widget.initialIndex;
  }

  void updateCurrentIndex(int index) {
    setState(() {
      currentSelectedIndex = index;
    });
  }

  final pages = [
    const HomeScreen(),
    const OrderTrackingScreen(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: updateCurrentIndex,
        currentIndex: currentSelectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: kPrimaryColor, 
        unselectedItemColor: inActiveIconColor, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined, size: 28),
            activeIcon: Icon(Icons.store_rounded, size: 28),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining_outlined, size: 28),
            activeIcon: Icon(Icons.delivery_dining, size: 28),
            label: "Track",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 28),
            activeIcon: Icon(Icons.history_rounded, size: 28),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, size: 28),
            activeIcon: Icon(Icons.person_2_rounded, size: 28),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
