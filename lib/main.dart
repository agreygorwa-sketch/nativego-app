import 'package:flutter/material.dart';
import 'screens/splash.dart';

void main() {
  runApp(const NativeGoApp());
}

class NativeGoApp extends StatelessWidget {
  const NativeGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NativeGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C5B)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
