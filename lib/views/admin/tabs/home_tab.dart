import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  int totalUser = 0;
  int totalDetect = 0;
  int totalRecommend = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    String? token = await _storageService.getToken();

    if (token != null) {
      final response = await _apiService.getAdminStats(token);
      if (response['message'] != null && response['message'].contains('[Success]')) {
        setState(() {
          totalUser = response['data']['total_users'];
          totalDetect = response['data']['total_detections'];
          totalRecommend = response['data']['total_saved'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        debugPrint(response['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchStats,
      color: AppColors.primaryGreen,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const Text(
                  "Ringkasan Aktivitas",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                ),
                const Text(
                  "Data statistik sistem FertiScan saat ini.",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // Grid Statistik
                _buildStatCard(
                  "Total Petani",
                  totalUser.toString(),
                  Icons.people_alt_rounded,
                  Colors.green.shade800,
                ),
                _buildStatCard(
                  "Total Pemindaian",
                  totalDetect.toString(),
                  Icons.document_scanner_rounded,
                  AppColors.actionOrange,
                ),
                _buildStatCard(
                  "Rekomendasi Diberikan",
                  totalRecommend.toString(),
                  Icons.auto_awesome_rounded,
                  const Color(0xFFAD1457), 
                ),

                const SizedBox(height: 30),
                const Text(
                  "Status Server",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.primaryGreen),
                      SizedBox(width: 15),
                      Text(
                        "Sistem Backend Terhubung (MySQL)",
                        style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Icon Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}