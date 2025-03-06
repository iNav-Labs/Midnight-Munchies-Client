import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midnightmunchies/components/search_screen/animated_search_bar.dart';

import 'package:midnightmunchies/components/home/restaurant_list.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isAppBarVisible = true;
  final double _appBarHeight = 180.0;
  double _lastScrollPosition = 0;
  String _searchQuery = '';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  // Example data - Replace with your actual data source
  final List<Map<String, dynamic>> _allRestaurants = [
    {
      'id': '1',
      'name': 'Pizza Palace',
      'rating': 4.5,
      'cuisine': ['Italian', 'Pizza'],
      'dishes': ['Margherita Pizza', 'Pepperoni Pizza'],
      'image': 'assets/images/restaurant1.jpg',
      'location': 'Downtown, City',
      'isVeg': true,
      'isNonVeg': true,
    },
    {
      'name': 'Curry House',
      'id': '2',
      'rating': 4.3,
      'cuisine': ['Indian', 'Curry'],
      'dishes': ['Butter Chicken', 'Paneer Tikka'],
      'image': 'assets/images/restaurant2.jpg',
      'location': 'Uptown, City',
      'isVeg': true,
      'isNonVeg': false,
    },
    // Add more restaurants...
  ];

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0.0, end: _appBarHeight - 90).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_listenToScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _listenToScroll() {
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll > _lastScrollPosition &&
        _isAppBarVisible &&
        currentScroll > 50) {
      setState(() {
        _isAppBarVisible = false;
        _animationController.forward();
      });
    } else if (currentScroll < _lastScrollPosition && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
        _animationController.reverse();
      });
    }
    _lastScrollPosition = currentScroll;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _handleSearch(_searchQuery);
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = [];
        return;
      }

      _isLoading = true;
    });

    // Debounce the search to prevent too many updates
    Future.delayed(Duration(milliseconds: 300), () {
      if (!mounted) return;

      final searchTerms = query.toLowerCase().split(' ');
      final results =
          _allRestaurants.where((restaurant) {
            // Check restaurant name
            final name = restaurant['name'].toString().toLowerCase();
            if (searchTerms.any((term) => name.contains(term))) return true;

            // Check cuisine types
            final cuisines =
                (restaurant['cuisine'] as List)
                    .map((c) => c.toString().toLowerCase())
                    .toList();
            if (searchTerms.any(
              (term) => cuisines.any((cuisine) => cuisine.contains(term)),
            ))
              return true;

            // Check dishes
            final dishes =
                (restaurant['dishes'] as List)
                    .map((d) => d.toString().toLowerCase())
                    .toList();
            if (searchTerms.any(
              (term) => dishes.any((dish) => dish.contains(term)),
            ))
              return true;

            // Additional keywords or tags if available
            final keywords =
                (restaurant['keywords'] as List?)
                    ?.map((k) => k.toString().toLowerCase())
                    .toList() ??
                [];
            if (searchTerms.any(
              (term) => keywords.any((keyword) => keyword.contains(term)),
            ))
              return true;

            return false;
          }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -_animation.value),
              child: Container(
                height: _appBarHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF6552FF).withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedSearchBar(
                      controller: _searchController,
                      onSearch: _handleSearch,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(children: [Expanded(child: _buildSearchResults())]),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6552FF)),
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'Search for your favorite food or restaurant',
              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      children: [RestaurantList(restaurants: _searchResults)],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listenToScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
