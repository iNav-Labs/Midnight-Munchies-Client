import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:midnightmunchies/components/general/appbar_app.dart';
import 'package:midnightmunchies/components/general/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class logoutScreen extends StatefulWidget {
  const logoutScreen({super.key});

  @override
  State<logoutScreen> createState() => _logoutScreenState();
}

// ignore: camel_case_types
class _logoutScreenState extends State<logoutScreen> {
  int _selectedIndex = 1;
  bool isShopOpen = true;
  bool _isLoading = false;
  String adminName = '';
  String adminEmail = '';
  String adminPhone = '';
  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadStatus();
  }

  Future<void> _loadUserDetails() async {
    // final prefs = await SharedPreferences.getInstance();
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('customers')
            .where('email', isEqualTo: FirebaseAuth.instance.currentUser?.email)
            .get();
    setState(() {
      adminName = FirebaseAuth.instance.currentUser?.displayName ?? '';
      adminEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      // adminEmail = prefs.getString('admin_email') ?? '';
      if (snapshot.docs.isNotEmpty) {
        var userData = snapshot.docs[0].data() as Map<String, dynamic>;
        adminPhone = userData['phone'] ?? '';
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear any stored tokens or user data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Remove all stored preferences
      // Or selectively clear auth-related preferences:
      // await prefs.remove('user_token');
      // await prefs.remove('user_id');

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // After successful logout, navigate to login screen
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Show error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate to Home
      Navigator.pushReplacementNamed(context, '/home');
    }
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      // Navigate to Profile
      Navigator.pushReplacementNamed(context, '/orders');
    }
  }

  Future<void> _loadStatus() async {
    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('shop_status')
            .get();
    final data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      isShopOpen = data['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBarApp(isShopOpen: isShopOpen),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Details
                _buildProfileField(Icons.person, "Username", adminName),
                _buildProfileField(Icons.email, "Email ID", adminEmail),
                _buildProfileField(Icons.phone, "Phone Number", adminPhone),
                const SizedBox(height: 20),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _logout(context),
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(
                              Icons.logout,
                              size: 18,
                              color: Colors.white,
                            ),
                    label: Text(
                      _isLoading ? "Logging out..." : "Logout",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        onSlideToCart: () {
          Navigator.pushNamed(
            context,
            '/billing',
            arguments: {'orderItems': []}, // Empty cart for profile view
          );
        },
        totalItems: 0, // No items in cart for profile view
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6552FF)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
