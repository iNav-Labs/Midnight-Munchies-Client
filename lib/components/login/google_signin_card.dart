import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart' as web;
import 'package:midnightmunchies/components/login/name_phone_register.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();

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
      return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo
                      Image.asset(
                        'assets/images/midnightmunchies_logo_dark.png',
                        height: 110,
                      ),
                      const SizedBox(height: 30),
                      // Welcome text
                      Text(
                        'Welcome to Midnight Munchies',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6552FF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Your favorite meals, delivered fast!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Login form
                      _buildEmailPasswordFields(),
                      const SizedBox(height: 30),
                      // Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Google sign-in
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailPasswordFields() {
    // Add controllers to access field values
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Add state for password visibility and loading state
    final ValueNotifier<bool> passwordVisible = ValueNotifier<bool>(false);
    final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

    // Add form key for validation
    final formKey = GlobalKey<FormState>();

    // Email validation function
    bool isValidEmail(String email) {
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegExp.hasMatch(email);
    }

    // Future<void> loginUser() async {
    //   try {
    //     UserCredential userCredential = await FirebaseAuth.instance
    //         .signInWithEmailAndPassword(
    //           email: _emailController.text,
    //           password: _passwordController.text,
    //         );

    //     final User? user = userCredential.user;

    //     if (user != null) {
    //       final prefs = await SharedPreferences.getInstance();
    //       await prefs.setString('email', user.email ?? '');

    //       if (kDebugMode) {
    //         print('User Logged In: ${user.email}');
    //       }

    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder:
    //               (context) => NamePhoneRegister(onRegistrationComplete: () {}),
    //         ),
    //       );
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     String errorMessage = "An error occurred";
    //     if (e.code == 'user-not-found') {
    //       errorMessage = "No user found with this email. Please sign up.";
    //     } else if (e.code == 'wrong-password') {
    //       errorMessage = "Wrong password. Please try again.";
    //     } else if (e.code == 'invalid-email') {
    //       errorMessage = "Please enter a valid email address.";
    //     }

    //     showDialog(
    //       context: context,
    //       builder:
    //           (context) => AlertDialog(
    //             title: const Text('Login Error'),
    //             content: Text(errorMessage),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('OK'),
    //               ),
    //             ],
    //           ),
    //     );
    //   } finally {}
    // }

    // Future<void> createUser() async {
    //   try {
    //     UserCredential userCredential = await FirebaseAuth.instance
    //         .createUserWithEmailAndPassword(
    //           email: emailController.text,
    //           password: passwordController.text,
    //         );

    //     final User? user = userCredential.user;

    //     if (user != null) {
    //       // Optionally, store additional user data in Firestore or Realtime Database
    //       await FirebaseFirestore.instance
    //           .collection('users')
    //           .doc(user.uid)
    //           .set({
    //             'email': user.email,
    //             'createdAt': FieldValue.serverTimestamp(),
    //           });

    //       final prefs = await SharedPreferences.getInstance();
    //       await prefs.setString('email', user.email ?? '');

    //       if (kDebugMode) {
    //         print('User Created: ${user.email}');
    //       }

    //       Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder:
    //               (context) => NamePhoneRegister(onRegistrationComplete: () {}),
    //         ),
    //       );
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     String errorMessage = "An error occurred";
    //     if (e.code == 'email-already-in-use') {
    //       errorMessage =
    //           "The email address is already in use by another account.";
    //     } else {
    //       errorMessage = e.message ?? "An unknown error occurred";
    //     }

    //     showDialog(
    //       context: context,
    //       builder:
    //           (context) => AlertDialog(
    //             title: const Text('Sign Up Error'),
    //             content: Text(errorMessage),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('OK'),
    //               ),
    //             ],
    //           ),
    //     );
    //   }
    // }

    // Future<void> loginUser() async {
    //   if (!formKey.currentState!.validate()) {
    //     return; // If the form is not valid, return early.
    //   }

    //   isLoading.value = true; // Show loading indicator

    //   try {
    //     // Try to sign in the user
    //     UserCredential userCredential = await FirebaseAuth.instance
    //         .signInWithEmailAndPassword(
    //           email: emailController.text,
    //           password: passwordController.text,
    //         );

    //     final User? user = userCredential.user;

    //     if (user != null) {
    //       final prefs = await SharedPreferences.getInstance();
    //       await prefs.setString('email', user.email ?? '');

    //       if (kDebugMode) {
    //         print('User Logged In: ${user.email}');
    //       }

    //       Navigator.pushReplacement(
    //         // ignore: use_build_context_synchronously
    //         context,
    //         MaterialPageRoute(
    //           builder:
    //               (context) => NamePhoneRegister(onRegistrationComplete: () {}),
    //         ),
    //       );
    //     }
    //   } on FirebaseAuthException catch (e) {
    //     String errorMessage = "An error occurred";
    //     if (e.code == 'user-not-found') {
    //       // If user not found, create a new user
    //       // await createUser();
    //     } else if (e.code == 'wrong-password') {
    //       errorMessage = "Wrong password. Please try again.";
    //     } else if (e.code == 'invalid-email') {
    //       errorMessage = "Please enter a valid email address.";
    //     } else {
    //       errorMessage = e.message ?? "An unknown error occurred";
    //     }

    //     showDialog(
    //       context: context,
    //       builder:
    //           (context) => AlertDialog(
    //             title: const Text('Login Error'),
    //             content: Text(errorMessage),
    //             actions: [
    //               TextButton(
    //                 onPressed: () => Navigator.pop(context),
    //                 child: const Text('OK'),
    //               ),
    //             ],
    //           ),
    //     );
    //   } finally {
    //     isLoading.value = false; // Hide loading indicator
    //   }
    // }
    Future<void> _handleEmailSignIn() async {
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        widget.onSignInSuccess();
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email field with validation
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              hintText: 'Email Address',
              hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF6552FF),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6552FF),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 15),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Password field with functional eye icon
          ValueListenableBuilder<bool>(
            valueListenable: passwordVisible,
            builder: (context, isVisible, _) {
              return TextFormField(
                controller: passwordController,
                obscureText: !isVisible,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  hintText: 'Password',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF6552FF),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      passwordVisible.value = !passwordVisible.value;
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6552FF),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red.shade400),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.red.shade400,
                      width: 1.5,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 15),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              );
            },
          ),
          const SizedBox(height: 30),
          // Sign in button with loading state
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : () => _handleEmailSignIn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6552FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(
                      0xFF6552FF,
                    ).withOpacity(0.7),
                  ),
                  child:
                      loading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              );
            },
          ),
        ],
      ),
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
                theme: web.GSIButtonTheme.filledBlue, // Google's official theme
                size:
                    web
                        .GSIButtonSize
                        .large, // Large button for better visibility
              ),
            ),
      ),
    );
  }
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
