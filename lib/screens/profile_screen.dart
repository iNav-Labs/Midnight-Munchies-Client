import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:midnightmunchies/components/general/appbar_app.dart';
import 'package:midnightmunchies/components/general/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _previousOrders = [];
  bool _isLoading = true;
  bool isShopOpen = true;
  @override
  void initState() {
    super.initState();
    _loadPreviousOrders();
    _loadStatus();
  }

  Future<void> _loadPreviousOrders() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where(
                'email',
                isEqualTo: FirebaseAuth.instance.currentUser?.email,
              )
              // .orderBy('orderDate', descending: true)
              .get();

      List<Map<String, dynamic>> tempOrders =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'timestamp': data['orderDate'] as Timestamp,
              'status': data['status'] as String,
              'orderItems': List<Map<String, dynamic>>.from(data['items']),
              'billDetails': Map<String, dynamic>.from(data['billDetails']),
              'name': data['name'] as String,
              'hostel': data['hostel'] as String,
            };
          }).toList();

      tempOrders.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // orders.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      setState(() {
        if (kDebugMode) {
          print(snapshot.docs.length);
        }
        // _previousOrders =
        //     snapshot.docs.map((doc) {
        //       final data = doc.data() as Map<String, dynamic>;
        //       return {
        //         'id': doc.id,
        //         'timestamp': data['orderDate'] as Timestamp,
        //         'status': data['status'] as String,
        //         'orderItems': List<Map<String, dynamic>>.from(data['items']),
        //         'billDetails': Map<String, dynamic>.from(data['billDetails']),
        //         'name': data['name'] as String,
        //         'hostel': data['hostel'] as String,
        //       };
        //     }).toList();
        _previousOrders = tempOrders;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading previous orders: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50';
      case 'pending':
        return '#FFC107';
      case 'cancelled':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacementNamed(context, '/home');
    }
    if (index == 1) {
      // Navigate to Orders
      Navigator.pushReplacementNamed(context, '/profile');
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadStatus() async {
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('shop_status')
            .get();
    final data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      isShopOpen = data['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBarApp(isShopOpen: isShopOpen),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _previousOrders.isEmpty
                      ? Center(
                        child: Text(
                          'No previous orders',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _previousOrders.length,
                        itemBuilder: (context, index) {
                          final order = _previousOrders[index];
                          final timestamp = order['timestamp'] as Timestamp;
                          final date = DateFormat(
                            'MMM d, y',
                          ).format(timestamp.toDate());
                          final time = DateFormat(
                            'h:mm a',
                          ).format(timestamp.toDate());

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          date,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                _getStatusColor(
                                                  order['status'],
                                                ).replaceAll('#', '0xFF'),
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            order['status'].toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      time,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        Text(
                                          'Order Details',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...order['orderItems']
                                            .map<Widget>(
                                              (item) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${item['name']} x${item['count']}',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    Text(
                                                      '₹${(item['price'] * item['count']).toStringAsFixed(2)}',
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        const Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Total',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '₹${order['billDetails']['total'].toStringAsFixed(2)}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF6552FF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onSlideToCart: () {
          Navigator.pushNamed(
            context,
            '/billing',
            arguments: {'orderItems': []}, // Empty cart for profile view
          );
        },
        totalItems: 0, // No items in cart for profile view
      ),
    );
  }
}
