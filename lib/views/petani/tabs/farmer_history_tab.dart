import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class FarmerHistoryTab extends StatefulWidget {
  const FarmerHistoryTab({super.key});

  @override
  State<FarmerHistoryTab> createState() => _FarmerHistoryTabState();
}

class _FarmerHistoryTabState extends State<FarmerHistoryTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  List<dynamic> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      String? token = await _storageService.getToken();
      if (token != null) {
        final res = await _apiService.getHistory(token);

        if (res['data'] != null && res['data'].isNotEmpty) {
          debugPrint("DATA_ITEM_0: ${res['data'][0]}"); 
        }

        if (mounted) {
          if (res['message'] != null && res['message'].contains('[Success]')) {
            setState(() {
              _historyList = res['data'] ?? [];
              _isLoading = false;
            });
          } else {
            setState(() {
              _historyList = [];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Exception History: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              color: AppColors.primaryGreen,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          "Riwayat Analisis",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          "Daftar hasil rekomendasi pemupukan lahan Anda.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                      ]),
                    ),
                  ),
                  _historyList.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _buildHistoryCard(_historyList[index]);
                              },
                              childCount: _historyList.length,
                            ),
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String? fileName = item['jalur_foto']?.toString(); 
    
    String cleanHost = AppConstants.baseUrl.replaceAll('/api', '');
    String fullSoilUrl = "";
    if (fileName != null && fileName != "null" && fileName.isNotEmpty) {
      fullSoilUrl = "$cleanHost/uploads/soils/$fileName";
      fullSoilUrl += "?v=${DateTime.now().millisecondsSinceEpoch}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: (fullSoilUrl.isNotEmpty)
                  ? Image.network(
                      fullSoilUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint("FAILED_URL: $fullSoilUrl");
                        return const Icon(Icons.broken_image_outlined,
                            color: Colors.grey, size: 30);
                      },
                    )
                  : const Icon(Icons.image_outlined,
                      color: Colors.grey, size: 30),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label_tanah_ai'] ?? "Jenis Tanah",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primaryGreen),
                    ),
                    Text(
                      item['tanggal_simpan']?.toString().split(' ')[0] ?? "",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Hasil: ${item['rekomendasi_hasil'] ?? '-'}",
                  style: TextStyle(
                      color: Colors.grey[800], fontSize: 13, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildInfoBadge("HST: ${item['hst_input'] ?? 0}"),
                    const SizedBox(width: 8),
                    _buildInfoBadge("${item['luas_lahan'] ?? 0} Ha"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            "Belum ada riwayat deteksi",
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _fetchHistory,
            child: const Text("Coba Muat Ulang",
                style: TextStyle(color: AppColors.primaryGreen)),
          )
        ],
      ),
    );
  }
}