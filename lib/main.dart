import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';

void main() {
  runApp(const FertiScanApp());
}

class FertiScanApp extends StatelessWidget {
  const FertiScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FertiScan',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), 
    );
  }
}