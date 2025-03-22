import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
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
  bool showBanner = false;
  late Timer _timer;
  String _selectedCategory = "All"; // Default category is "All"
  List<String> _categories = ["All"]; // Initialize with "All" category

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadFoodItems();
    _loadStatus();
    _checkBannerVisibility();

    // Update banner visibility every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkBannerVisibility();
    });
  }

  @override
  void dispose() {
    _shopStatusSubscription.cancel();
    _listController.dispose();
    _timer.cancel();
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

        // Extract unique categories from food items
        _extractCategories();
      });
      _listController.forward();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading food items: $e');
      }
      // Handle error appropriately
    }
  }

  // Extract unique categories from food items
  void _extractCategories() {
    Set<String> uniqueCategories = {"All"};
    for (var item in _foodItems) {
      if (item.containsKey('category') && item['category'] != null) {
        uniqueCategories.add(item['category'] as String);
      }
    }
    _categories = uniqueCategories.toList();
  }

  // Filter items based on selected category
  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedCategory == "All") {
      return _foodItems;
    } else {
      return _foodItems
          .where((item) => item['category'] == _selectedCategory)
          .toList();
    }
  }

  void _incrementItem(int index) {
    // Find the actual index in the _foodItems list
    final filteredItems = _getFilteredItems();
    final item = filteredItems[index];
    final originalIndex = _foodItems.indexOf(item);

    if (_foodItems[originalIndex]['available']) {
      setState(() {
        _foodItems[originalIndex]['count']++;
      });
    }
  }

  void _decrementItem(int index) {
    // Find the actual index in the _foodItems list
    final filteredItems = _getFilteredItems();
    final item = filteredItems[index];
    final originalIndex = _foodItems.indexOf(item);

    if (_foodItems[originalIndex]['available'] &&
        _foodItems[originalIndex]['count'] > 0) {
      setState(() {
        _foodItems[originalIndex]['count']--;
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

  void _checkBannerVisibility() {
    final now = TimeOfDay.now();
    setState(() {
      showBanner = (now.hour == 23 && now.minute >= 0) || (now.hour == 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

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
            if (showBanner)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  height: 40,
                  color: Colors.red.shade800,
                  child: Marquee(
                    text: "⚠️ No New Order Will Be Taken After 11:30 PM ⚠️",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    blankSpace: 50.0,
                    velocity: 50.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(seconds: 1),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
              ),

            // Category selector horizontal scrollable list
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.7),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            Expanded(
              child:
                  _foodItems.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 80.0),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
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
