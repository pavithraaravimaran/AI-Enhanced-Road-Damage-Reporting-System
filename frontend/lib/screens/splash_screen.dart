import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import for Firebase initialization

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Check if user is logged in
  void _checkUserStatus() async {
    await Firebase.initializeApp(); // Ensure Firebase is initialized before checking user status
    await Future.delayed(Duration(seconds: 2)); // Simulate splash screen delay

    User? user = FirebaseAuth.instance.currentUser;

    // Navigate based on authentication state
    if (user != null) {
      // If user is logged in, go to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // If user is not logged in, go to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/road_revive_logo.png'), // Splash screen logo
      ),
    );
  }
}
