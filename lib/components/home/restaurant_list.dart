import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midnightmunchies/models/restaurant.dart';
import 'package:midnightmunchies/screens/restaurant_details_screen.dart';

class RestaurantList extends StatelessWidget {
  const RestaurantList({
    super.key,
    required List<Map<String, dynamic>> restaurants,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(10, (index) {
        return RestaurantCard(
          key: ValueKey(index),
          restaurant: Restaurant(isVeg: true, isNonVeg: false),
          onTap: () {
            // Handle restaurant selection
          },
        );
      }),
    );
  }
}

class RestaurantCard extends StatefulWidget {
  final VoidCallback onTap;
  final Restaurant restaurant;

  const RestaurantCard({
    super.key,
    required this.onTap,
    required this.restaurant,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.98, // Subtle scale animation
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation!,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      'https://blog.coverglassusa.com/hs-fs/hubfs/Untitled%20design%20(32).png?width=1120&name=Untitled%20design%20(32).png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.black26,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urban Dosa House',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kudasan, Gandhinagar',
                            style: GoogleFonts.poppins(
                              color: Colors.black45,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6552FF).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Trusted',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController?.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController?.reverse();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RestaurantDetailsPage()),
    );
  }

  void _handleTapCancel() {
    _animationController?.reverse();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
