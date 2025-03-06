// custom_widgets/custom_divider.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDivider extends StatelessWidget {
  final String text;

  const CustomDivider({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 0.5,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.2),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              height: 0.5,
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}