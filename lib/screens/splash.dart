import 'package:flutter/material.dart';
import 'auth_screen.dart';

/// Splash screen shown briefly on launch.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0E7C5B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore, size: 88, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'NativeGo',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Explore Nairobi with verified locals',
              style: TextStyle(fontSize: 15, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
