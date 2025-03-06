import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int totalItems;
  final VoidCallback onSlideToCart;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.totalItems,
    required this.onSlideToCart,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  double _dragOffset = 0.0;
  final double _maxSlide = 280.0; // Increased slide distance

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta ?? 0.0;
      _dragOffset = _dragOffset.clamp(
        0.0,
        _maxSlide + 15,
      ); // Limit slide inside button
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragOffset > _maxSlide - 70) {
      // _navigateToBillingScreen();
      widget.onSlideToCart();
    }
    setState(() {
      _dragOffset = 0.0; // Reset smoothly
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.totalItems > 0)
          GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Wider Green Checkout Button
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity, // Button takes full screen width
                  height: 70, // Slightly taller for better touch
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Slide to Checkout (${widget.totalItems})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Slightly bigger text
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular Arrow Cursor Inside Green Box
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  left: _dragOffset + 30, // Keeps arrow inside the green box
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Bottom Navigation Bar
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6552FF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: widget.selectedIndex,
            onTap: widget.onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 28),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart, size: 28),
                label: 'Orders',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
