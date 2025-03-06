import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NamePhoneRegister extends StatefulWidget {
  final VoidCallback onRegistrationComplete;

  const NamePhoneRegister({super.key, required this.onRegistrationComplete});

  @override
  State<NamePhoneRegister> createState() => _NamePhoneRegisterState();
}

class _NamePhoneRegisterState extends State<NamePhoneRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkExistingUserData();
  }

  Future<void> _checkExistingUserData() async {
    final user = _auth.currentUser;
    if (user?.email != null) {
      try {
        final docSnapshot =
            await _firestore.collection('customers').doc(user!.email).get();

        if (docSnapshot.exists) {
          if (mounted) {
            widget.onRegistrationComplete();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error checking user data. Please try again.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          // Logo
          Image.asset(
            'assets/images/midnightmunchies_logo.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          _buildCustomDivider('ENTER YOUR DETAILS'),
          const SizedBox(height: 24),
          // Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: _buildInputDecoration(
                      'Name',
                      'Enter your full name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Phone Number Field
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+91',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: _buildInputDecoration(
                            'Phone Number',
                            'Enter your phone number',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length != 10) {
                              return 'Phone number must be 10 digits';
                            }
                            if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                              return 'Please enter a valid Indian mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  try {
                                    final user = _auth.currentUser;
                                    if (user?.email != null) {
                                      await _firestore
                                          .collection('customers')
                                          .doc(user!.email)
                                          .set({
                                            'name': _nameController.text.trim(),
                                            'phone':
                                                _phoneController.text.trim(),
                                            'email': user.email,
                                          });

                                      if (mounted) {
                                        widget.onRegistrationComplete();
                                      }
                                    }
                                  } catch (e) {
                                    print(e);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Failed to update profile. Please try again.',
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                    }
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6552FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Submit',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.black.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6552FF), width: 1.0),
      ),
    );
  }

  Widget _buildCustomDivider(String text) {
    return Row(
      children: [
        const SizedBox(width: 32),
        Expanded(
          child: Container(height: 0.5, color: Colors.black.withOpacity(0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 0.5, color: Colors.black.withOpacity(0.3)),
        ),
        const SizedBox(width: 32),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
