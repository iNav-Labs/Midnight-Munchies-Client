import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midnightmunchies/theme/app_theme.dart';

class AnimatedSearchBar extends StatefulWidget {
  const AnimatedSearchBar({Key? key}) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  int _currentPlaceholderIndex = 0;
  bool _isTextFieldEmpty = true;
  final TextEditingController _textController = TextEditingController();

  final List<String> _placeholders = [
    'Search for restaurants...',
    'Craving something specific?',
    'Find your favorite food...',
    'Discover new tastes...',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.7),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _textController.addListener(_onTextChanged);
    _startAnimationLoop();
  }

  void _onTextChanged() {
    setState(() {
      _isTextFieldEmpty = _textController.text.isEmpty;
    });
  }

  void _clearSearch() {
    setState(() {
      _textController.clear();
      _isTextFieldEmpty = true;
    });
  }

  void _startAnimationLoop() async {
    await Future.delayed(const Duration(milliseconds: 300));
    while (mounted) {
      if (_isTextFieldEmpty) {
        await _controller.forward();
        await Future.delayed(const Duration(milliseconds: 500));
        await _controller.reverse();
        setState(() {
          _currentPlaceholderIndex =
              (_currentPlaceholderIndex + 1) % _placeholders.length;
        });
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!_controller.isAnimating) {
          _controller.reset();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // Reduced height

      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white, // Set background color to white
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                if (_isTextFieldEmpty)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Text(
                            _placeholders[_currentPlaceholderIndex],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                TextField(
                  controller: _textController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: const InputDecoration(
                    // Added const
                    border: InputBorder.none,
                    hintText: '',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 8,
                    ), // Added to adjust textfield height
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Animated icon transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child:
                _isTextFieldEmpty
                    ? Image.asset(
                      'assets/images/search_icon.png',
                      width: 20,
                      height: 20,
                      key: const ValueKey('search'),
                    )
                    : GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        Icons.clear,
                        size: 20,
                        color: Colors.grey[600],
                        key: const ValueKey('clear'),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
