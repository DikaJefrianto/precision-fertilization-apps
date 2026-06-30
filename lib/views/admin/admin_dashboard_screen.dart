import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/rules_tab.dart'; 
import 'tabs/catalog_tab.dart';
import 'tabs/profile_tab.dart';
import 'add_edit_rule_screen.dart';
import 'add_edit_fertilizer_screen.dart'; 

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const RulesTab(), 
    const CatalogTab(),
    const ProfileTab(),
  ];

  void _handleLogout() async {
    await StorageService().deleteToken();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Data Baru", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryGreen, 
                  child: Icon(Icons.science, color: Colors.white)
                ),
                title: const Text("Master Pupuk"),
                subtitle: const Text("Tambah jenis pupuk baru"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const AddEditFertilizerScreen())
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.actionOrange, 
                  child: Icon(Icons.psychology_alt, color: Colors.white)
                ),
                title: const Text("Aturan Pakar"),
                subtitle: const Text("Tambah logika dosis hara baru"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const AddEditRuleScreen())
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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
              ? "FertiScan Admin" 
              : _currentIndex == 1 
                  ? "Aturan Pakar" 
                  : _currentIndex == 2 
                      ? "Katalog Master" 
                      : "Profil",
          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: AppColors.alertRed),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu, 
        backgroundColor: AppColors.primaryGreen,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
              _buildNavItem(Icons.psychology_alt, "Aturan", 1),
              const SizedBox(width: 40), 
              _buildNavItem(Icons.inventory_2, "Katalog", 2),
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
          Icon(icon, color: isSelected ? AppColors.primaryGreen : Colors.grey, size: 24),
          Text(
            label, 
            style: TextStyle(
              fontSize: 10, 
              color: isSelected ? AppColors.primaryGreen : Colors.grey, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )
          ),
        ],
      ),
    );
  }
}