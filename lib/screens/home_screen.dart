import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:midnightmunchies/components/general/appbar_app.dart';
import 'package:midnightmunchies/components/general/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _foodItems = [];
  late final AnimationController _listController;
  bool isShopOpen = true;
  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadFoodItems();
    _loadStatus();
  }

  @override
  void dispose() {
    _shopStatusSubscription.cancel();
    _listController.dispose();
    super.dispose();
  }

  late final StreamSubscription<DocumentSnapshot> _shopStatusSubscription;

  Future<void> _loadStatus() async {
    _shopStatusSubscription = FirebaseFirestore.instance
        .collection('settings')
        .doc('shop_status')
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            setState(() {
              isShopOpen = data['status'] ?? false;
            });
          }
        });
  }

  Future<void> _loadFoodItems() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('items').get();

      setState(() {
        _foodItems =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                ...data,
                'image': data['imageUrl'] as String,
                'count': 0,
                'available': true,
                'price': double.parse(data['price']),
                'animation': Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _listController,
                    curve: Curves.easeIn,
                  ),
                ),
              };
            }).toList();
      });
      _listController.forward();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading food items: $e');
      }
      // Handle error appropriately
    }
  }

  void _incrementItem(int index) {
    if (_foodItems[index]['available']) {
      setState(() {
        _foodItems[index]['count']++;
      });
    }
  }

  void _decrementItem(int index) {
    if (_foodItems[index]['available'] && _foodItems[index]['count'] > 0) {
      setState(() {
        _foodItems[index]['count']--;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigate to Profile
      Navigator.pushReplacementNamed(context, '/profile');
      return;
    }
    if (index == 2) {
      // Navigate to Orders
      Navigator.pushReplacementNamed(context, '/orders');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBarApp(isShopOpen: isShopOpen),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _foodItems.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 80.0),
                        itemCount: _foodItems.length,
                        itemBuilder: (context, index) {
                          final item = _foodItems[index];
                          final isAvailable = item['available'] as bool;

                          return FadeTransition(
                            opacity: item['animation'],
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 8,
                              shadowColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // if (isAvailable) {
                                  //   _incrementItem(index);
                                  //   HapticFeedback.lightImpact();
                                  // }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient:
                                        isAvailable
                                            ? LinearGradient(
                                              colors: [
                                                Colors.white,
                                                Colors.grey.shade50,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                            : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: 'food_${item['name']}',
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  isAvailable
                                                      ? Colors.transparent
                                                      : Colors.grey,
                                                  isAvailable
                                                      ? BlendMode.multiply
                                                      : BlendMode.saturation,
                                                ),
                                                child: Image.network(
                                                  item['image'] as String,
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      width: 120,
                                                      height: 120,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons.fastfood,
                                                        size: 40,
                                                        color: Colors.grey,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'] as String,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '₹${(item['price'] as double).toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: Colors.green[700],
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              AnimatedOpacity(
                                                duration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                opacity:
                                                    isAvailable ? 1.0 : 0.5,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          25,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed:
                                                            isAvailable
                                                                ? () =>
                                                                    _decrementItem(
                                                                      index,
                                                                    )
                                                                : null,
                                                        icon: const Icon(
                                                          Icons.remove,
                                                        ),
                                                        color: Colors.red[700],
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                            ),
                                                        child: Text(
                                                          item['count']
                                                              .toString(),
                                                          style: Theme.of(
                                                                context,
                                                              )
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed:
                                                            isAvailable
                                                                ? () =>
                                                                    _incrementItem(
                                                                      index,
                                                                    )
                                                                : null,
                                                        icon: const Icon(
                                                          Icons.add,
                                                        ),
                                                        color:
                                                            Colors.green[700],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
          if (isShopOpen) {
            final selectedItems =
                _foodItems.where((item) => item['count'] > 0).toList();

            if (selectedItems.isNotEmpty) {
              Navigator.pushNamed(
                context,
                '/billing',
                arguments: {'orderItems': selectedItems},
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select at least one item.'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Shop is closed')));
          }
        },
        totalItems: _foodItems.fold(
          0,
          (previousValue, element) => previousValue + (element['count'] as int),
        ),
      ),
    );
  }
}
