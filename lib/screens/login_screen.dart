import 'package:flutter/material.dart';
import 'package:midnightmunchies/components/login/google_signin_card.dart';
import 'package:midnightmunchies/components/login/name_phone_register.dart';
import 'package:midnightmunchies/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showNamePhoneRegister = false;

  void onGoogleSignInSuccess() {
    // Check if user needs to register name and phone
    if (true) {
      setState(() {
        showNamePhoneRegister = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                showNamePhoneRegister
                    ? NamePhoneRegister(
                      onRegistrationComplete: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    )
                    : GoogleSignInCard(onSignInSuccess: onGoogleSignInSuccess),
          ),
        ),
      ),
    );
  }
}
