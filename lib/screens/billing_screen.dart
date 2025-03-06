import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:midnightmunchies/components/general/divider.dart';
import 'package:midnightmunchies/screens/splash_screen.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:shimmer/shimmer.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Razorpay _razorpay;

  bool _isLoading = true;
  bool _isBillExpanded = false;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Update color constants
  static const primaryColor = Color(0xFF6552FF);
  static const backgroundColor = Colors.white;
  static const textDarkColor = Color(0xFF1C1E21);
  static const textLightColor = Color(0xFF65676B);
  static const surfaceColor = Colors.white;
  static const dividerColor = Color(0xFFE4E6EB);

  List<Map<String, dynamic>> orderItems = [];
  Map<String, dynamic> billDetails = {
    'subtotal': 0.0,
    'deliveryCharge': 0.0,
    'tax': 0.0,
    'total': 0.0,
  };

  String? _selectedHostel;
  List<String> _hostels = [];

  Map<String, double> calculateBillDetails() {
    double subtotal = orderItems.fold(0.0, (adding, item) {
      return adding + (item['price'] as double) * (item['count'] as int);
    });

    double deliveryCharge = subtotal > 0 ? 2.99 : 0.0;
    double tax = subtotal * 0.10;
    double total = subtotal + deliveryCharge + tax;

    return {
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'deliveryCharge': double.parse(deliveryCharge.toStringAsFixed(2)),
      'tax': double.parse(tax.toStringAsFixed(2)),
      'total': double.parse(total.toStringAsFixed(2)),
    };
  }

  Future<void> _fetchHostels() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('settings')
              .doc('shop_status')
              .get();

      if (doc.exists && doc.data()?['hostels'] != null) {
        setState(() {
          _hostels = List<String>.from(doc.data()?['hostels']);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching hostels: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    print("Razorpay initialized"); // Debug log
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _getUserDetails();
    _fetchHostels();
    Future.microtask(() {
      final args =
          // ignore: use_build_context_synchronously
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        orderItems = List<Map<String, dynamic>>.from(args['orderItems']);
        billDetails = calculateBillDetails();
      });
    });
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) {
  //   if (kDebugMode) {
  //     print("Payment Successful: ${response.paymentId}");
  //   }

  //   // Navigate to SplashScreen after payment success
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => SplashScreen(
  //             orderItems: orderItems,
  //             billDetails: billDetails,
  //             name: _nameController.text,
  //             phone: _phoneController.text,
  //             hostel: _selectedHostel ?? '',
  //           ),
  //     ),
  //   );
  // }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text("Payment Failed!")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print("External Wallet Selected: ${response.walletName}");
    }
  }

  // Callback when Razorpay payment is successful
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      print("Payment successful: ${response.paymentId}");
    }

    // Step 1: Save order details in Firestore
    DocumentReference orderRef = await FirebaseFirestore.instance
        .collection('orders')
        .add({
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'items': orderItems,
          'totalAmount': billDetails['total'],
          'paymentId': response.paymentId,
          'status': 'Paid',
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Step 2: Fetch admin FCM token
    DocumentSnapshot adminSnapshot =
        await FirebaseFirestore.instance
            .collection('admin_tokens')
            .doc('admin')
            .get();
    if (adminSnapshot.exists) {
      String? adminToken = adminSnapshot['token'];

      // Step 3: Send notification to admin
      await sendPushNotification(adminToken!, orderRef.id);
    }
  }

  // void _handlePayment() {
  //   if (kDebugMode) {
  //     print("Place Order button pressed");
  //   }

  //   if (orderItems.isEmpty) {
  //     if (kDebugMode) {
  //       print("Order items are empty, payment not triggered");
  //     }
  //     return;
  //   }

  //   if (_formKey.currentState?.validate() ?? false) {
  //     if (kDebugMode) {
  //       print("Form validated successfully");
  //     }

  //     double totalAmount = billDetails['total'];
  //     if (totalAmount <= 0) {
  //       if (kDebugMode) {
  //         print("Invalid total amount: $totalAmount");
  //       }
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Invalid order amount")));
  //       return;
  //     }

  //     var options = {
  //       'key': 'rzp_test_S9ikUUcVXnwtWZ', // Ensure this is correct
  //       'amount': (totalAmount * 100).toInt(), // Convert to paisa
  //       'currency': 'INR',
  //       'name': 'Midnight Munchies',
  //       'description': 'Food Order Payment',
  //       'prefill': {
  //         'contact': _phoneController.text,
  //         'email': FirebaseAuth.instance.currentUser?.email ?? "",
  //       },
  //       'method': {
  //         'upi': true, // Enables UPI as a payment method
  //       },
  //       'external': {
  //         'wallets': ['paytm'],
  //       },
  //     };

  //     if (kDebugMode) {
  //       print("Opening Razorpay with options: $options");
  //     }

  //     try {
  //       _razorpay.open(options);
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print("Error opening Razorpay: $e");
  //       }
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text("Error opening Razorpay: $e")));
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print("Form validation failed");
  //     }
  //   }
  // }

  void _handlePayment() {
    if (kDebugMode) {
      print("Place Order button pressed");
    }

    if (orderItems.isEmpty) {
      if (kDebugMode) {
        print("Order items are empty, payment not triggered");
      }
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (kDebugMode) {
        print("Form validated successfully");
      }

      double totalAmount = billDetails['total'];
      if (totalAmount <= 0) {
        if (kDebugMode) {
          print("Invalid total amount: $totalAmount");
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid order amount")));
        return;
      }

      var options = {
        'key': 'rzp_test_S9ikUUcVXnwtWZ',
        'amount': (totalAmount * 100).toInt(), // Convert to paisa
        'currency': 'INR',
        'name': 'Midnight Munchies',
        'description': 'Food Order Payment',
        'prefill': {
          'contact': _phoneController.text,
          'email': FirebaseAuth.instance.currentUser?.email ?? "",
        },
        'method': {'upi': true},
        'external': {
          'wallets': ['paytm'],
        },
      };

      if (kDebugMode) {
        print("Opening Razorpay with options: $options");
      }

      try {
        _razorpay.open(options);
      } catch (e) {
        if (kDebugMode) {
          print("Error opening Razorpay: $e");
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error opening Razorpay: $e")));
      }
    } else {
      if (kDebugMode) {
        print("Form validation failed");
      }
    }
  }

  // Function to send FCM push notification
  Future<void> sendPushNotification(String adminToken, String orderId) async {
    const String serverKey =
        "YOUR_FIREBASE_SERVER_KEY"; // Get from Firebase Console (Cloud Messaging)
    final Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final Map<String, dynamic> notificationData = {
      "to": adminToken,
      "notification": {
        "title": "New Order Received",
        "body": "Order #$orderId has been placed successfully!",
        "sound": "default",
      },
    };

    await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$serverKey",
      },
      body: jsonEncode(notificationData),
    );
  }

  Future<void> _getUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData =
            await FirebaseFirestore.instance
                .collection('customers')
                .doc(user.email)
                .get();
        if (userData.exists) {
          setState(() {
            _nameController.text = userData.data()?['name'] ?? '';
            _phoneController.text = userData.data()?['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting user details: $e");
      }
    }
  }

  void _updateBillDetails() {
    double subtotal = 0;
    for (var item in orderItems) {
      subtotal += (item['price'] * item['count']);
    }

    setState(() {
      billDetails['subtotal'] = subtotal;
      billDetails['tax'] = subtotal * 0.1; // 10% tax
      billDetails['total'] =
          subtotal + billDetails['deliveryCharge'] + billDetails['tax'];
    });
  }

  void _updateItemQuantity(int index, int change) {
    setState(() {
      orderItems[index]['count'] += change;

      if (orderItems[index]['count'] <= 0) {
        orderItems.removeAt(index);

        if (orderItems.isEmpty) {
          // Navigate to the home screen when all items are removed
          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }
      _updateBillDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/home',
            ); // Replace with your HomeScreen route
          },
        ),
        title: Text("Billing", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingShimmer() : _buildMainContent(),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 120, color: Colors.white),
            SizedBox(height: 16),
            ...List.generate(
              5,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDivider(text: "Order Items"),
                    SizedBox(height: 30),
                    _buildOrderItems(),
                    SizedBox(height: 30),
                    CustomDivider(text: "Customer Details"),
                    SizedBox(height: 30),
                    _buildCustomerForm(),
                    SizedBox(height: 30),
                    CustomDivider(text: "Bill Details"),
                    SizedBox(height: 30),
                    _buildBillDetails(),
                    SizedBox(height: 16),
                    _buildNote(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderItems.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  color: const Color.fromARGB(180, 228, 230, 235),
                  indent: 16,
                  endIndent: 16,
                ),
            itemBuilder: (context, index) => _buildOrderItemTile(index),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(int index) {
    final item = orderItems[index];
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textDarkColor,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '₹${item['price'].toStringAsFixed(2)}',
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
              color: const Color(0xFF6552FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.remove, color: Colors.white, size: 18),
                  onPressed: () => _updateItemQuantity(index, -1),
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Text(
                    '${item['count']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.add, color: Colors.white, size: 18),
                  onPressed: () => _updateItemQuantity(index, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Full Name', _nameController),
            SizedBox(height: 12),
            _buildTextField(
              'Phone Number',
              _phoneController,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            _buildHostelDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: textDarkColor, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: textLightColor, fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'This field is required';
        }
        if (keyboardType == TextInputType.phone) {
          if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value!)) {
            return 'Please enter a valid phone number';
          }
        }
        return null;
      },
    );
  }

  Widget _buildHostelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Location',
          style: GoogleFonts.poppins(
            color: textLightColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField2<String>(
            value: _selectedHostel,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: primaryColor,
                size: 20,
              ),
              hintText: 'Select your hostel',
              hintStyle: GoogleFonts.poppins(
                color: textLightColor,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: GoogleFonts.poppins(color: textDarkColor, fontSize: 14),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              maxHeight: 300,
              offset: const Offset(0, -10),
            ),
            iconStyleData: IconStyleData(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: textLightColor,
                size: 24,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              selectedMenuItemBuilder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child,
                );
              },
            ),
            items:
                _hostels.map((String hostel) {
                  return DropdownMenuItem<String>(
                    value: hostel,
                    child: Text(
                      hostel,
                      style: GoogleFonts.poppins(
                        color: textDarkColor,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedHostel = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your hostel';
              }
              return null;
            },
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildBillDetails() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
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
                        '₹${billDetails['total'].toStringAsFixed(2)}',
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
                  Divider(height: 1, color: dividerColor),
                  SizedBox(height: 16),
                  _buildBillRow('Subtotal', billDetails['subtotal']),
                  SizedBox(height: 8),
                  _buildBillRow(
                    'Delivery Charge',
                    billDetails['deliveryCharge'],
                  ),
                  SizedBox(height: 8),
                  _buildBillRow('Tax', billDetails['tax']),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: dividerColor),
                  ),
                  _buildBillRow('Total', billDetails['total'], isTotal: true),
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

  Widget _buildNote() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Order cannot be cancelled once placed. Payment will be collected on delivery.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: primaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: orderItems.isEmpty ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              disabledBackgroundColor: primaryColor.withOpacity(0.5),
              elevation: 0,
              minimumSize: Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Place Order • ₹${billDetails['total'].toStringAsFixed(2)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _animationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
