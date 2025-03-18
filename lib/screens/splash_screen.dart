import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.orderItems,
    required this.billDetails,
    required this.name,
    required this.phone,
    required this.hostel,
  });
  final List<Map<String, dynamic>> orderItems;
  final Map<String, dynamic> billDetails;
  final String name;
  final String phone;
  final String hostel;

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      // Fetch Hindi names for all items
      List<Map<String, dynamic>> orderItemsWithHindi = [];

      await Future.wait(
        widget.orderItems.map((item) async {
          // Query Firestore to get the Hindi name for this item
          final itemName = item['name'];
          final querySnapshot =
              await FirebaseFirestore.instance
                  .collection('items')
                  .where('name', isEqualTo: itemName)
                  .limit(1)
                  .get();

          String hindiName = '';
          if (querySnapshot.docs.isNotEmpty) {
            hindiName = querySnapshot.docs.first.data()['hindiName'] ?? '';
          }

          // Add the item with Hindi name to the list
          orderItemsWithHindi.add({
            'name': item['name'],
            'count': item['count'],
            'price': item['price'],
            'hindiName': hindiName,
          });
        }),
      );

      // Now create the order with the Hindi names included
      await FirebaseFirestore.instance.collection('orders').add({
        'email': FirebaseAuth.instance.currentUser?.email,
        'items': orderItemsWithHindi,
        'billDetails': widget.billDetails,
        'name': widget.name,
        'phone': widget.phone,
        'hostel': widget.hostel,
        'orderDate': FieldValue.serverTimestamp(),
        'status': 'cooking',
        'price': widget.billDetails['total'],
      });

      Navigator.pushReplacementNamed(
        context,
        '/tracking',
        arguments: {
          'orderItems': widget.orderItems,
          'billDetails': widget.billDetails,
          'name': widget.name,
          'phone': widget.phone,
          'hostel': widget.hostel,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6552FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/doodle.json', // Add your Lottie animation file
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Preparing Your Order',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
