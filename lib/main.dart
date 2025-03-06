import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:midnightmunchies/screens/billing_screen.dart';
import 'package:midnightmunchies/screens/login_screen.dart';
import 'package:midnightmunchies/screens/home_screen.dart';
import 'package:midnightmunchies/screens/logout_screen.dart';
import 'package:midnightmunchies/screens/order_tracking_screen.dart';
import 'package:midnightmunchies/screens/profile_screen.dart';
import 'package:midnightmunchies/screens/restaurant_details_screen.dart';
import 'package:midnightmunchies/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'midnightmunchies App',
      theme: AppTheme.lightTheme,
      initialRoute: '/login', // Define the initial route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/billing': (context) => BillingScreen(),
        '/restaurant_details': (context) => RestaurantDetailsPage(),
        '/tracking': (context) => OrderTrackingScreen(),
        '/orders': (context) => ProfileScreen(),
        '/profile': (context) => logoutScreen(),
      },
    );
  }
}

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:midnightmunchies/screens/login_screen.dart';
// import 'package:midnightmunchies/screens/home_screen.dart';
// import 'package:midnightmunchies/services/auth_service.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'midnightmunchies',
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: FutureBuilder(
//         future: AuthService().isLoggedIn(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasData && snapshot.data == true) {
//             return const HomeScreen();
//           }
//           return const LoginScreen();
//         },
//       ),
//     );
//   }
// }
