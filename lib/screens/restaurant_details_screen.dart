import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midnightmunchies/screens/billing_screen.dart';

import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RestaurantDetailsPage extends StatefulWidget {
  const RestaurantDetailsPage({super.key});

  @override
  _RestaurantDetailsPageState createState() => _RestaurantDetailsPageState();
}

class _RestaurantDetailsPageState extends State<RestaurantDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Restaurant Details Data
  final Map<String, dynamic> restaurantData = {
    'name': 'The Grand Kitchen',
    'address': '123 Main Street, Downtown, City',
    'description':
        'A fine dining experience with authentic cuisine and a cozy atmosphere',
    'rating': 'Trusted',
    'deliveryTime': '30-40 min',
    'isOpen': true,
  };

  final List<String> carouselImages = [
    'assets/images/get.png',
    'assets/images/get.png',
    'assets/images/get.png',
  ];

  final List<String> cuisines = [
    'All',
    'Italian',
    'Mexican',
    'Indian',
    'Chinese',
    'Japanese',
  ];

  final List<Map<String, dynamic>> menuItems = [
    {
      'id': '1',
      'name': 'Margherita Pizza',
      'description': 'Fresh tomatoes, mozzarella, basil',
      'price': 12.99,
      'category': 'Italian',
      'isVeg': true,
    },
    {
      'id': '2',
      'name': 'Chicken Tacos',
      'description': 'Grilled chicken with fresh vegetables',
      'price': 9.99,
      'category': 'Mexican',
      'isVeg': false,
    },
    {
      'id': '3',
      'name': 'Paneer Tikka',
      'description': 'Grilled cottage cheese with spices',
      'price': 11.99,
      'category': 'Indian',
      'isVeg': true,
    },
    {
      'id': '4',
      'name': 'Kung Pao Chicken',
      'description': 'Spicy diced chicken with peanuts',
      'price': 13.99,
      'category': 'Chinese',
      'isVeg': false,
    },
    {
      'id': '11',
      'name': 'Margherita Pizza',
      'description': 'Fresh tomatoes, mozzarella, basil',
      'price': 12.99,
      'category': 'Italian',
      'isVeg': true,
    },
    {
      'id': '12',
      'name': 'Chicken Tacos',
      'description': 'Grilled chicken with fresh vegetables',
      'price': 9.99,
      'category': 'Mexican',
      'isVeg': false,
    },
    {
      'id': '13',
      'name': 'Paneer Tikka',
      'description': 'Grilled cottage cheese with spices',
      'price': 11.99,
      'category': 'Indian',
      'isVeg': true,
    },
    {
      'id': '14',
      'name': 'Kung Pao Chicken',
      'description': 'Spicy diced chicken with peanuts',
      'price': 13.99,
      'category': 'Chinese',
      'isVeg': false,
    },
  ];

  List<Map<String, dynamic>> get filteredMenuItems {
    var items = List<Map<String, dynamic>>.from(menuItems);
    if (selectedCuisine != 'All') {
      items =
          items.where((item) => item['category'] == selectedCuisine).toList();
    }
    items.sort(
      (a, b) =>
          isHighToLow
              ? (b['price'] as double).compareTo(a['price'] as double)
              : (a['price'] as double).compareTo(b['price'] as double),
    );
    return items;
  }

  String selectedCuisine = 'All';
  bool isHighToLow = true;
  final ScrollController _scrollController = ScrollController();
  bool _showStickyNavbar = false;
  bool _isLoading = true;

  // Add these variables for cart tracking
  Map<String, int> cartItems = {};

  int get totalItemCount =>
      cartItems.values.fold(0, (sum, count) => sum + count);
  double get totalAmount => cartItems.entries.fold(0.0, (sum, entry) {
    var menuItem = menuItems.firstWhere((item) => item['id'] == entry.key);
    return sum + (menuItem['price'] * entry.value);
  });

  // Add this getter
  bool get isRestaurantOpen => restaurantData['isOpen'] as bool;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Simulate loading delay
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 180 && !_showStickyNavbar) {
      setState(() {
        _showStickyNavbar = true;
      });
      _animationController.forward();
    } else if (_scrollController.offset <= 180 && _showStickyNavbar) {
      setState(() {
        _showStickyNavbar = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: ColorFiltered(
            colorFilter: ColorFilter.matrix(
              isRestaurantOpen
                  ? [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
                  : [
                    0.2,
                    0.2,
                    0.2,
                    0,
                    0,
                    0.2,
                    0.2,
                    0.2,
                    0,
                    0,
                    0.2,
                    0.2,
                    0.2,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ],
            ),
            child: AbsorbPointer(
              absorbing: !isRestaurantOpen,
              child: _isLoading ? _buildLoadingShimmer() : _buildMainContent(),
            ),
          ),
          bottomNavigationBar:
              isRestaurantOpen && totalItemCount > 0 ? _buildBottomBar() : null,
        ),
        if (!isRestaurantOpen)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_filled_rounded,
                        size: 48,
                        color: Color(0xFF6552FF),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Restaurant is Closed',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1C1E21),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Opening Soon',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 200, color: Colors.white),
            SizedBox(height: 16),
            ...List.generate(5, (index) => _buildShimmerCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildRestaurantCard(),
                  _buildCuisineFilter(),
                  _buildMenuItems(),
                ],
              ),
            ),
          ],
        ),
        _buildStickyHeader(),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: AutoScrollingCarousel(
          imageUrls: carouselImages,
          scrollDuration: Duration(milliseconds: 500),
          pauseDuration: Duration(seconds: 3),
          height: 200,
        ),
      ),
    );
  }

  Widget _buildRestaurantCard() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    restaurantData['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1E21),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF6552FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Trusted',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                // load image of location_icon.ong
                Image.asset(
                  'assets/images/location_icon.png',
                  width: 16,
                  height: 16,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    restaurantData['address'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              restaurantData['description'],
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(bool isVeg, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: isVeg ? Colors.green : Colors.red),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.circle,
            size: 12,
            color: isVeg ? Colors.green : Colors.red,
          ),
        ),
        SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCuisineFilter() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cuisines.length,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          bool isSelected = selectedCuisine == cuisines[index];
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedCuisine = cuisines[index];
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Color(0xFF6552FF).withOpacity(0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Color(0xFF6552FF) : Colors.grey[200]!,
                    ),
                  ),
                  child: Text(
                    cuisines[index],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Color(0xFF6552ff) : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickyHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child:
              _showStickyNavbar
                  ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.white.withOpacity(0.6),
                          padding: EdgeInsets.fromLTRB(16, 40, 16, 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurantData['name'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1C1E21),
                                          ),
                                        ),
                                        Text(
                                          restaurantData['address'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildRatingBadge(),
                                ],
                              ),
                              SizedBox(height: 8),
                              _buildCuisineFilter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  : SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFF6552FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            'Trusted',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSortOptions(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filteredMenuItems.length,
            itemBuilder: (context, index) {
              return AnimatedMenuItemCard(
                item: filteredMenuItems[index],
                delay: index * 100,
                isRestaurantOpen: isRestaurantOpen,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.sort, color: Color(0xFF6552FF), size: 20),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  builder: (context) => _buildSortBottomSheet(),
                );
              },
            ),
          ),
          SizedBox(width: 12),
          Text(
            isHighToLow ? 'Price: High to Low' : 'Price: Low to High',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBottomSheet() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Sort By',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildSortOption('Price: High to Low', isHighToLow, () {
            setState(() => isHighToLow = true);
            Navigator.pop(context);
          }),
          _buildSortOption('Price: Low to High', !isHighToLow, () {
            setState(() => isHighToLow = false);
            Navigator.pop(context);
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: Color(0xFF6552FF),
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isSelected ? Color(0xFF6552FF) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add this method for the bottom bar
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF6552FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF6552FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$totalItemCount ${totalItemCount == 1 ? 'Item' : 'Items'}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              // On press go to billing screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BillingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff6552ff),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(color: Colors.white),
              ),
            ),
            child: Text(
              'Proceed',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class AnimatedMenuItemCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int delay;
  final bool isRestaurantOpen;

  const AnimatedMenuItemCard({
    Key? key,
    required this.item,
    required this.delay,
    required this.isRestaurantOpen,
  }) : super(key: key);

  @override
  _AnimatedMenuItemCardState createState() => _AnimatedMenuItemCardState();
}

class _AnimatedMenuItemCardState extends State<AnimatedMenuItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  void _updateCart(bool increment) {
    final _restaurantDetailsState =
        context.findAncestorStateOfType<_RestaurantDetailsPageState>();

    if (_restaurantDetailsState != null) {
      setState(() {
        if (increment) {
          quantity++;
          _restaurantDetailsState.cartItems[widget.item['id']] = quantity;
        } else {
          quantity--;
          if (quantity == 0) {
            _restaurantDetailsState.cartItems.remove(widget.item['id']);
          } else {
            _restaurantDetailsState.cartItems[widget.item['id']] = quantity;
          }
        }
      });

      // Trigger rebuild of parent to update bottom bar
      _restaurantDetailsState.setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          margin: EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildVegIcon(),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1E21),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.item['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '₹${widget.item['price'].toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6552FF),
                        ),
                      ),
                      Spacer(),
                      _buildQuantityControl(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVegIcon() {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 0.5,
          color: widget.item['isVeg'] ? Colors.green : Colors.red,
        ),
      ),
      child: Icon(
        widget.item['isVeg'] ? Icons.eco : Icons.whatshot,
        size: 20,
        color: widget.item['isVeg'] ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildQuantityControl() {
    return quantity == 0
        ? ElevatedButton(
          onPressed: widget.isRestaurantOpen ? () => _updateCart(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                widget.isRestaurantOpen
                    ? Color(0xFF6552FF).withOpacity(0.1)
                    : Colors.grey,
            foregroundColor:
                widget.isRestaurantOpen ? Color(0xFF6552FF) : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side:
                  widget.isRestaurantOpen
                      ? BorderSide(color: Color(0xFF6552FF), width: 0.5)
                      : BorderSide.none,
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: Text(
            widget.isRestaurantOpen ? 'ADD' : 'CLOSED',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            color: widget.isRestaurantOpen ? Color(0xFF6552FF) : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuantityButton(
                icon: Icons.remove,
                onPressed:
                    widget.isRestaurantOpen ? () => _updateCart(false) : null,
              ),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onPressed:
                    widget.isRestaurantOpen ? () => _updateCart(true) : null,
              ),
            ],
          ),
        );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
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

class AutoScrollingCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Duration scrollDuration;
  final Duration pauseDuration;
  final double height;

  const AutoScrollingCarousel({
    Key? key,
    required this.imageUrls,
    this.scrollDuration = const Duration(milliseconds: 500),
    this.pauseDuration = const Duration(seconds: 3),
    this.height = 200.0,
  }) : super(key: key);

  @override
  State<AutoScrollingCarousel> createState() => _AutoScrollingCarouselState();
}

class _AutoScrollingCarouselState extends State<AutoScrollingCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.pauseDuration, (Timer timer) {
      if (_pageController.page == widget.imageUrls.length - 1) {
        _currentPage = 0;
      } else {
        _currentPage++;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: widget.scrollDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: widget.imageUrls[index],
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(child: CircularProgressIndicator()),
                ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
        },
      ),
    );
  }
}
