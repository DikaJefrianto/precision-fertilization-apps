import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/expert_rule_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/custom_dialog.dart';
import '../add_edit_rule_screen.dart';

class RulesTab extends StatefulWidget {
  const RulesTab({super.key});

  @override
  State<RulesTab> createState() => _RulesTabState();
}

class _RulesTabState extends State<RulesTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  List<ExpertRule> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    String? token = await _storageService.getToken();
    if (token == null) return;

    final res = await _apiService.getExpertRules(token);
    
    if (!mounted) return;

    if (res['message'] != null && res['message'].contains('[Success]')) {
      setState(() {
        _rules = (res['data'] as List).map((e) => ExpertRule.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _deleteRule(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Aturan Pakar?"),
        content: const Text("Tindakan ini tidak dapat dibatalkan. Seluruh perhitungan dosis untuk fase dan jenis tanah ini akan terhapus."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () async {
              Navigator.pop(context);
              String? token = await _storageService.getToken();
              final res = await _apiService.deleteExpertRule(token!, id);
              if (res['message'].contains('[Success]')) {
                _loadRules();
                if (mounted) {
                  CustomDialog.show(
                    context: context, 
                    isSuccess: true, 
                    title: "Berhasil Dihapus", 
                    message: "Basis pengetahuan telah diperbarui."
                  );
                }
              }
            }, 
            child: const Text("Ya, Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRules,
      color: AppColors.primaryGreen,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("KNOWLEDGE BASE", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  const Text("Kelola Aturan\nHara Jagung", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, height: 1.1, color: AppColors.primaryBlack)),
                  const SizedBox(height: 12),
                  const Text("Sesuaikan target nutrisi NPK berdasarkan fase pertumbuhan dan jenis tanah.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  
                  const SizedBox(height: 25),

                  // Info Panel
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.blue.shade800, size: 24),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Struktur Aturan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blue.shade900)),
                              const SizedBox(height: 4),
                              const Text(
                                "Aturan disusun berdasarkan Jenis Tanah dan Rentang HST. Pastikan tidak ada rentang HST yang tumpang tindih pada jenis tanah yang sama.",
                                style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  _rules.isEmpty 
                    ? _buildEmptyState()
                    : Column(
                        children: _rules.map((rule) => _buildRuleCard(rule)).toList(),
                      ),

                  const SizedBox(height: 20),
                  _buildAddPlaceholder(),
                  const SizedBox(height: 120), 
                ],
              ),
            ),
    );
  }

  Widget _buildRuleCard(ExpertRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BADGE FASE & TANAH
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rule.phaseName.toUpperCase(),
                          style: const TextStyle(color: AppColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rule.soilLabel.toUpperCase(),
                          style: TextStyle(color: Colors.orange.shade900, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 22),
                      onPressed: () async {
                        final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditRuleScreen(rule: rule)));
                        if (refresh == true) _loadRules();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.alertRed, size: 22),
                      onPressed: () => _deleteRule(rule.id!),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          // Rentang HST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(rule.hstRange, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primaryBlack)),
                const SizedBox(width: 8),
                const Text("Hari Setelah Tanam", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1, indent: 20, endIndent: 20),
          
          // Nutrient Info (N, P, K)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientInfo("Target Nitrogen", "${rule.targetN}", "Kg/Ha"),
                _buildNutrientInfo("Target Fosfor", "${rule.targetP}", "Kg/Ha"),
                _buildNutrientInfo("Target Kalium", "${rule.targetK}", "Kg/Ha"),
              ],
            ),
          ),
          
          // Advice Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Text(
              "Saran Ahli: ${rule.advice}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.5, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)),
            const SizedBox(width: 3),
            Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.storage_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          const Text("Belum ada aturan hara", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddPlaceholder() {
    return InkWell(
      onTap: () async {
        final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditRuleScreen()));
        if (refresh == true) _loadRules();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid, width: 2),
        ),
        child: Column(
          children: const [
            Icon(Icons.add_circle_rounded, color: AppColors.primaryGreen, size: 48),
            SizedBox(height: 12),
            Text("Tambah Fase & Jenis Tanah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlack)),
            Text("Buat standar hara baru", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}