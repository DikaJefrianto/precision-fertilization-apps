import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import 'tabs/farmer_home_tab.dart';
import 'tabs/detection_tab.dart';
import 'tabs/farmer_history_tab.dart';
import '../admin/tabs/profile_tab.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const FarmerHomeTab(),
    const DetectionTab(),
    const FarmerHistoryTab(),
    const ProfileTab(),
  ];

  void _handleLogout() async {
    await StorageService().deleteToken();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset('assets/images/logo.png'),
        ),
        title: Text(
          _currentIndex == 0
              ? "FertiScan"
              : _currentIndex == 1
                  ? "Deteksi Lahan"
                  : _currentIndex == 2
                      ? "Riwayat Analisis"
                      : "Profil Saya",
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: AppColors.alertRed),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 1;
          });
        },
        backgroundColor: AppColors.primaryGreen,
        elevation: 4,
        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, "Beranda", 0),
              _buildNavItem(Icons.document_scanner, "Deteksi", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.history, "Riwayat", 2),
              _buildNavItem(Icons.person, "Profil", 3),
            ],
          ),
        ),
      ),
      body: _tabs[_currentIndex],
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryGreen : Colors.grey,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primaryGreen : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}