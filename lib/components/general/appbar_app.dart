import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarApp extends StatelessWidget {
  final bool isShopOpen; // Status controlled by admin

  const AppBarApp({super.key, required this.isShopOpen});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                // const Color.fromARGB(255, 222, 217, 255).withOpacity(0.4),
                // const Color.fromARGB(255, 222, 217, 255).withOpacity(0.4),
                const Color(0xFF6552FF),
                const Color(0xFF6552FF),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo Container
                    Container(
                      height: 60,
                      width: 170, // Adjust width as needed for your logo
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            // Color.fromARGB(255, 255, 255, 255),
                            // Color.fromARGB(255, 234, 232, 255),
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: Colors.transparent,
                          width: 0.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/midnightmunchies_logo.png',
                        height: 55,
                      ),
                    ),

                    // Shop Status Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        // color:
                        //     isShopOpen
                        //         ? Colors.green.withOpacity(0.15)
                        //         : Colors.red.withOpacity(0.15),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isShopOpen ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              // backgroundBlendMode: BlendMode.overlay,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isShopOpen ? "Open" : "Closed",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isShopOpen ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
