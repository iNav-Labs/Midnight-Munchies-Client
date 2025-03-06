import 'package:flutter/material.dart';
import 'dart:async';

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
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                // LoadingBuilder for better UX
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, object, stackTrace) {
                  return const Center(
                    child: Text("Error loading image"),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
