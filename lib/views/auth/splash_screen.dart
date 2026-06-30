import 'dart:async';
import 'package:fertiscan_app/views/admin/admin_dashboard_screen.dart';
import 'package:fertiscan_app/views/petani/farmer_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/storage_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSessionCheck();
  }

  void _startSessionCheck() async {
    try {
      final storage = StorageService();
      String? token = await storage.getToken();
      String? role = await storage.getRole();

      Timer(const Duration(seconds: 3), () {
        if (!mounted) return;

        if (token == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return;
        }
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const FarmerDashboardScreen()),
          );
        }
      });
    } catch (e) {
      debugPrint("Error Splash: $e");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 160,
                  height: 160,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 80, color: Colors.red);
                  },
                ),
                const SizedBox(height: 24),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                    children: [
                      TextSpan(
                        text: 'Ferti',
                        style: TextStyle(color: AppColors.primaryBlack),
                      ),
                      TextSpan(
                        text: 'Scan',
                        style: TextStyle(color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.lightGray,
                    color: AppColors.primaryGreen.withOpacity(0.6),
                    minHeight: 2,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "SOLUSI CERDAS PERTANIAN",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
