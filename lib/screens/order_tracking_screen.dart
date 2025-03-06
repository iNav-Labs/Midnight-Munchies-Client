import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midnightmunchies/components/general/divider.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  static const primaryColor = Color(0xFF6552FF); // Green for success/delivery
  static const accentColor = Color(
    0xFF6552FF,
  ); // Purple for interactive elements
  static const backgroundColor = Colors.white;
  static const textDarkColor = Color(0xFF1C1E21);
  static const textLightColor = Color(0xFF65676B);
  bool _isBillExpanded = false;
  late AnimationController _animationController;

  final Map orderData = {
    'orderStatus': 'Order is on the way',
    'estimatedTime': '16min',
    'restaurant': {
      'name': "Tomato's Diner",
      'phone': '+1 234 567 8900',
      'subtitle': 'Call for any order related inquiry',
    },
    'deliveryPerson': {
      'name': 'Dhirubhai Ambani',
      'phone': '+1 234 567 8901',
      'subtitle': 'Feel free to call for order updates',
    },
    'orderItems': [
      {'name': 'FarmHouse Pizza', 'count': 1, 'price': 105},
      {'name': 'Alfredo Pasta', 'count': 1, 'price': 105},
    ],
    'deliveryAddress': '47, Radhe Homes, Kudasan',
    'total': 210,
    'orderSteps': [
      {'title': 'Order Confirmed', 'completed': true},
      {'title': 'Preparing', 'completed': true},
      {'title': 'On the Way', 'completed': true},
      {'title': 'Delivered', 'completed': false},
    ],
    'billDetails': {
      'subtotal': 210,
      'deliveryCharge': 0,
      'tax': 0,
      'total': 210,
    },
  };
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    Future.microtask(() {
      final args =
          // ignore: use_build_context_synchronously
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        orderData['orderItems'] = args['orderItems'];
        orderData['deliveryAddress'] = args['hostel'];
        orderData['billDetails'] = args['billDetails'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  CustomDivider(text: 'Order Tracking'),
                  SizedBox(height: 20),
                  _buildOrderItems(),
                  SizedBox(height: 24),
                  _buildBillDetails(),
                  // _buildContactCards(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed:
                        () => Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  Text(
                    'Delivering at Hostel',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' | ',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                  Expanded(
                    child: Text(
                      orderData['deliveryAddress'],
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                orderData['orderStatus'],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Arriving in 20-30 min',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.refresh, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children:
            orderData['orderItems'].map<Widget>((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: textDarkColor,
                        ),
                      ),
                    ),
                    Text(
                      '${item['count']} x Rs. ${item['price']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textLightColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildBillDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _isBillExpanded = !_isBillExpanded);
              _isBillExpanded
                  ? _animationController.forward()
                  : _animationController.reverse();
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bill Details',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDarkColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "₹${orderData['billDetails']['total'].toStringAsFixed(2)}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 4),
                      RotationTransition(
                        turns: Tween(
                          begin: 0.0,
                          end: 0.5,
                        ).animate(_animationController),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: textLightColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isBillExpanded)
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Divider(height: 1, color: Color(0xFFE4E6EB)),
                  SizedBox(height: 16),
                  _buildBillRow(
                    'Subtotal',
                    orderData['billDetails']['subtotal'],
                  ),
                  SizedBox(height: 8),
                  _buildBillRow(
                    'Delivery Charge',
                    orderData['billDetails']['deliveryCharge'],
                  ),
                  SizedBox(height: 8),
                  _buildBillRow('Tax', orderData['billDetails']['tax']),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFE4E6EB)),
                  ),
                  _buildBillRow(
                    'Total',
                    orderData['billDetails']['total'],
                    isTotal: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black : textLightColor,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCards() {
    return Column(
      children: [
        _buildContactCard(
          title: 'Delivery Partner',
          name: orderData['deliveryPerson']['name'],
          message: orderData['deliveryPerson']['subtitle'],
          icon: Icons.delivery_dining,
          phone: orderData['deliveryPerson']['phone'],
        ),
        SizedBox(height: 16),
        _buildContactCard(
          title: 'Restaurant',
          name: orderData['restaurant']['name'],
          message: orderData['restaurant']['subtitle'],
          icon: Icons.restaurant,
          phone: orderData['restaurant']['phone'],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String message,
    required IconData icon,
    required String phone,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$title | ',
                        style: GoogleFonts.poppins(
                          color: textDarkColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: name,
                        style: GoogleFonts.poppins(
                          color: textDarkColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textLightColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.phone, color: Colors.white, size: 20),
              onPressed: () {
                // Implement phone call functionality
              },
            ),
          ),
        ],
      ),
    );
  }
}
