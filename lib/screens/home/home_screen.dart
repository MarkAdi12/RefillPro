import 'package:customer_frontend/constants.dart';
import 'package:customer_frontend/screens/cart/cart_screen.dart';
import 'package:customer_frontend/screens/ordering/order.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'AquaZen',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        actions: [  
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
            icon: const Icon(
              Icons.shopping_cart_rounded,
              size: 28,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Order Fresh Water Now',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Delivered Straight to Your Doorstep!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderScreen()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(kPrimaryColor),
                    padding: WidgetStateProperty.all(
                        EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                  ),
                  child: Text(
                    'Order Now',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(height: 12),
                Text('Next Suggested Order: 3 days'), // FORECASTING
                SizedBox(height: 5),

                // ITEMS
                Text('Choose Your Product',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                SizedBox(height: 20),
                ProductCard(
                  title: '5 Round Gallon',
                  description: 'Fresh and pure water in a convenient size.',
                  price: '30.00 Only',
                  onTap: () {
                    // Navigate to order page with this product
                  },
                ),
                SizedBox(height: 20),
                ProductCard(
                  title: '5 Round Gallon',
                  description: 'Great for large families or offices.',
                  price: '30.00 Only',
                  onTap: () {},
                ),
                SizedBox(height: 40),
                // Operational Hours
                Text(
                  'Operational Hours: 9:00 AM - 5:00 PM',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 20),
                Text('What Our Customers Say',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ReviewCard(
                        review: 'Solid Mabilis mag deliver!',
                        customerName: 'Lebronskie',
                      ),
                      SizedBox(width: 10),
                      ReviewCard(
                        review: 'Angas par promise! ',
                        customerName: 'Phal Kups',
                      ),
                      ReviewCard(review: 'Sarap', customerName: 'LBJ'),
                      ReviewCard(
                        review: 'Solid Mabilis mag deliver!',
                        customerName: 'Lebronskie',
                      ),
                      ReviewCard(
                        review: 'Solid Mabilis mag deliver!',
                        customerName: 'Lebronskie',
                      ),
                    ],
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

class ProductCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final VoidCallback onTap;

  const ProductCard(
      {super.key,
      required this.title,
      required this.description,
      required this.price,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 300,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text(description,
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 8),
                Text(price,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String review;
  final String customerName;

  const ReviewCard(
      {super.key, required this.review, required this.customerName});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$review"', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('- $customerName',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
