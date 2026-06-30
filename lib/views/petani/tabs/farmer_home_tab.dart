import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class FarmerHomeTab extends StatefulWidget {
  const FarmerHomeTab({super.key});

  @override
  State<FarmerHomeTab> createState() => _FarmerHomeTabState();
}

class _FarmerHomeTabState extends State<FarmerHomeTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  String userName = "Petani";
  String? userPhoto;
  String totalArea = "0";
  String lastRecommend = "Belum ada data";
  List<dynamic> historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    String? token = await _storageService.getToken();

    if (token != null) {
      final response = await _apiService.getFarmerStats(token);
      if (response['message'] != null && response['message'].contains('[Success]')) {
        if (mounted) {
          setState(() {
            userName = response['user_info']['nama'];
            userPhoto = response['user_info']['foto_profil'];
            totalArea = (double.tryParse(response['stats']['total_hektar'].toString()) ?? 0.0).toStringAsFixed(2);
            lastRecommend = response['stats']['latest_recommendation'];
            historyData = response['history'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String fullImageUrl = "";
    if (userPhoto != null && userPhoto!.isNotEmpty) {
      fullImageUrl = "${AppConstants.mediaUrl}/$userPhoto?t=${DateTime.now().millisecondsSinceEpoch}";
    }

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : RefreshIndicator(
            onRefresh: _fetchDashboardData,
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo,", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        backgroundImage: fullImageUrl.isNotEmpty 
                            ? NetworkImage(fullImageUrl) 
                            : null,
                        child: fullImageUrl.isEmpty
                            ? const Icon(Icons.person_rounded, color: AppColors.primaryGreen, size: 30)
                            : null,
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  _buildAreaCard(),
                  const SizedBox(height: 15),
                  _buildRecommendationCard(),
                  const SizedBox(height: 30),
                  const Text("Aktivitas Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  historyData.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: historyData.map((item) => _buildActivityItem(item)).toList(),
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  Widget _buildAreaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Lahan Terpantau", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(totalArea, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text("Hektar", style: TextStyle(color: Colors.white70, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: const Text("Update Otomatis", style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.actionOrange.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.eco_rounded, color: AppColors.actionOrange, size: 28),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rekomendasi Terakhir", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  lastRecommend,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildActivityItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.analytics_outlined, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['label_tanah_ai'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(item['tanggal_simpan'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.spa_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Belum ada aktivitas", style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}