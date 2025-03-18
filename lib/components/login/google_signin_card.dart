import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) _handleGoogleSignIn(account);
    });
    googleSignIn.signInSilently().catchError((error) {
      if (kDebugMode) print("Silent sign-in failed: $error");
    });
  }

  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) widget.onSignInSuccess();
    } catch (e) {
      if (kDebugMode) print("Google Sign-In failed: $e");
    }
  }

  Future<void> _handleEmailSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      widget.onSignInSuccess();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Sign in failed");
    }
    setState(() => _isLoading = false);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/midnightmunchies_logo_dark.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Midnight Munchies',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6552FF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your favorite meals, delivered fast!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              _buildFeatureRow(Icons.timer_outlined, 'Fast Delivery'),
              _buildFeatureRow(Icons.local_shipping_outlined, 'Live Tracking'),
              _buildFeatureRow(
                Icons.restaurant_menu_outlined,
                'Wide Selection',
              ),
              const SizedBox(height: 30),
              _buildEmailPasswordFields(),
              const SizedBox(height: 20),
              _buildGoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailPasswordFields() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: _inputDecoration("Email", Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          decoration: _inputDecoration("Password", Icons.lock_outline),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        _isLoading
            ? const CircularProgressIndicator()
            : SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _handleEmailSignIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF6552FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
      ],
    );
  }

Widget _buildGoogleSignInButton() {
  return Align(
    alignment: Alignment.center,
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: (GoogleSignInPlatform.instance as web.GoogleSignInPlugin)
          .renderButton(
            configuration: web.GSIButtonConfiguration(
              theme: web.GSIButtonTheme.filledBlue,
              size: web.GSIButtonSize.large,
            ),
          ),
    ),
  );
}


  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6552FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6552FF), size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
