// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
// import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// final GoogleSignIn googleSignIn = GoogleSignIn(
//   clientId:
//       "44734305698-nthitq1dd1ic175c5oo48dn6and1u78f.apps.googleusercontent.com",
//   scopes: ['email', 'profile'],
// );

// class GoogleSignInCard extends StatefulWidget {
//   final VoidCallback onSignInSuccess;

//   const GoogleSignInCard({super.key, required this.onSignInSuccess});

//   @override
//   _GoogleSignInCardState createState() => _GoogleSignInCardState();
// }

// class _GoogleSignInCardState extends State<GoogleSignInCard> {
//   @override
//   void initState() {
//     super.initState();
//     _initializeGoogleSignIn();
//   }

//   void _initializeGoogleSignIn() {
//     googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       if (account != null) _handleSignIn(account);
//     });

//     // Attempt silent sign-in
//     googleSignIn.signInSilently().catchError((error) {
//       if (kDebugMode) {
//         print("Silent sign-in failed: $error");
//       }
//     });
//   }

//   Future<void> _handleSignIn(GoogleSignInAccount googleUser) async {
//     try {
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithCredential(credential);

//       if (userCredential.user != null) {
//         widget.onSignInSuccess();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Google Sign-In failed: $e");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.black.withOpacity(0.3), width: 0.5),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(height: 40),
//             Image.asset(
//               'assets/images/midnightmunchies_logo.png',
//               height: 80,
//               fit: BoxFit.contain,
//             ),
//             const SizedBox(height: 40),
//             Text(
//               'Welcome to midnightmunchies',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF6552FF),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Your favorite meals\nstraight in front of your door.',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 color: Colors.black87,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Column(
//                 children: [
//                   _buildFeatureRow(Icons.timer_outlined, 'Fast Delivery'),
//                   const SizedBox(height: 16),
//                   _buildFeatureRow(
//                     Icons.local_shipping_outlined,
//                     'Live Tracking',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildFeatureRow(
//                     Icons.restaurant_menu_outlined,
//                     'Wide Selection',
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 40),
//             _buildGoogleSignInButton(),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGoogleSignInButton() {
//     return SizedBox(
//       height: 50,
//       child: (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
//           .renderButton(
//             configuration: web.GSIButtonConfiguration(
//               theme: web.GSIButtonTheme.filledBlue,
//               size: web.GSIButtonSize.large,
//             ),
//           ),
//     );
//   }

//   Widget _buildFeatureRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color(0xFF6552FF), width: 0.5),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: const Color(0xFF6552FF)),
//         ),
//         const SizedBox(width: 16),
//         Text(
//           text,
//           style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId:
      "44734305698-nthitq1dd1ic175c5oo48dn6and1u78f.apps.googleusercontent.com",
  scopes: ['email', 'profile'],
);

class GoogleSignInCard extends StatefulWidget {
  final VoidCallback onSignInSuccess;

  const GoogleSignInCard({super.key, required this.onSignInSuccess});

  @override
  _GoogleSignInCardState createState() => _GoogleSignInCardState();
}

class _GoogleSignInCardState extends State<GoogleSignInCard> {
  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) _handleSignIn(account);
    });

    // Attempt silent sign-ie
    googleSignIn.signInSilently().catchError((error) {
      if (kDebugMode) {
        print("Silent sign-in failed: $error");
      }
    });
  }

  Future<void> _handleSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        widget.onSignInSuccess();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign-In failed: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/midnightmunchies_logo_dark.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    textAlign: TextAlign.center,
                    'Welcome to Midnight Munchies',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6552FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your favorite meals\nstraight in front of your door.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.timer_outlined, 'Fast Delivery'),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.local_shipping_outlined,
                          'Live Tracking',
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.restaurant_menu_outlined,
                          'Wide Selection',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildGoogleSignInButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildFooter(), // Footer stays at the bottom
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      height: 50,
      child: (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
          .renderButton(
            configuration: web.GSIButtonConfiguration(
              theme: web.GSIButtonTheme.filledBlue,
              size: web.GSIButtonSize.large,
            ),
          ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF6552FF), width: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6552FF)),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made with ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6552FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.favorite, color: Colors.red, size: 14),
              Text(
                ' by RebelMinds',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6552FF), // Brand color
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String text, String filePath) {
    return GestureDetector(
      onTap: () => _downloadFile(filePath),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw "Could not launch $url";
    }
  }

  void _downloadFile(String filePath) {
    // Implement actual file download logic
    if (kDebugMode) {
      print("Downloading $filePath...");
    }
  }
}
