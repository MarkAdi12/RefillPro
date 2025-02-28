import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/cart/cart_screen.dart';
import 'package:customer_frontend/screens/ordering/order.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _address;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    String? userData = await _secureStorage.read(key: 'user_data');
    if (userData != null) {
      final userMap = jsonDecode(userData);
      setState(() {
        _address = userMap['address'] ?? 'No address available';
      });
    } else {
      setState(() {
        _address = 'No address available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: const [
                Icon(
                  Icons.water_drop_sharp,
                  size: 23,
                ),
                SizedBox(width: 10),
                Text(
                  'AquaZen',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
              icon: const Icon(
                Icons.shopping_cart_rounded,
                size: 23,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                color: kPrimaryColor,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Delivering To',
                            style:
                                TextStyle(fontSize: 13, color: Colors.white)),
                        Text(
                          _address != null && _address!.length > 30
                              ? '${_address!.substring(0, 30)}...'
                              : _address ?? 'No address available',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 615,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              12), // Ensure image is also clipped
                          child: Image.asset(
                            'assets/banner.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Most Selected Item',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w400),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderScreen()),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color.fromARGB(255, 82, 107, 131)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 105,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/default.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Slim Water Gallon',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  Row(children: [
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      size: 18,
                                      color: kPrimaryColor,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ]),
                                  SizedBox(height: 8),
                                  Text(
                                    '5 Gallon',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'PHP 35.00',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: kPrimaryColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderScreen()),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 16),
                                            child: Text('Order Now',
                                                style: TextStyle(
                                                    color: kPrimaryColor)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ))
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 105,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/default.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Round Water Gallon',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w200),
                                  ),
                                  Row(children: [
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: kPrimaryColor,
                                      size: 18,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      size: 18,
                                      color: kPrimaryColor,
                                    ),
                                    Icon(
                                      Icons.water_drop_rounded,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                  ]),
                                  SizedBox(height: 8),
                                  Text(
                                    '5 Gallon',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'PHP 35.00',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: kPrimaryColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderScreen()),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4, horizontal: 16),
                                            child: Text('Order Now',
                                                style: TextStyle(
                                                    color: kPrimaryColor)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
