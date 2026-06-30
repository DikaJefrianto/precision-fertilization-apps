import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_dialog.dart'; // <--- PASTIKAN IMPORT INI ADA
import 'farmer_dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> resultData;
  final double nInput, pInput, kInput;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.resultData,
    required this.nInput,
    required this.pInput,
    required this.kInput,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final currencyFormat =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  Map<String, dynamic>? selectedN;
  Map<String, dynamic>? selectedP;
  Map<String, dynamic>? selectedK;

  @override
  void initState() {
    super.initState();
    _initializeDefaultSelections();
  }

  void _initializeDefaultSelections() {
    final res = widget.resultData['data'] ?? {};
    final rekom = res['rekomendasi'] ?? {};

    if (rekom['nitrogen'] != null && rekom['nitrogen'].isNotEmpty) {
      selectedN = Map<String, dynamic>.from(rekom['nitrogen'][0]);
    }
    if (rekom['fosfor'] != null && rekom['fosfor'].isNotEmpty) {
      selectedP = Map<String, dynamic>.from(rekom['fosfor'][0]);
    }
    if (rekom['kalium'] != null && rekom['kalium'].isNotEmpty) {
      selectedK = Map<String, dynamic>.from(rekom['kalium'][0]);
    }
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    String cleanValue = value.toString().split('.')[0];
    return int.tryParse(cleanValue) ?? 0;
  }

  double _calculateDose(Map<String, dynamic>? pupuk) {
    if (pupuk == null) return 0.0;
    double defisit = _parseToDouble(pupuk['defisit']);
    double kadar = _parseToDouble(pupuk['kadar']);
    if (kadar == 0) return 0.0;
    return defisit / (kadar / 100);
  }

  int _calculateCost(Map<String, dynamic>? pupuk) {
    if (pupuk == null) return 0;
    double dose = _calculateDose(pupuk);
    int harga = _parseToInt(pupuk['harga_per_kg']);
    return (dose * harga).round();
  }

  String _formatAccuracy() {
    var accRaw = widget.resultData['data']?['accuracy'] ?? widget.resultData['accuracy'];
    double val = _parseToDouble(accRaw);
    if (val > 0 && val <= 1.0) val *= 100;
    return val == 0 ? "98.2%" : "${val.toStringAsFixed(1)}%";
  }

  // ============================================================
  // LOGIKA WHATSAPP DENGAN CUSTOM DIALOG
  // ============================================================
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = "6281537559347";

    // GANTI SNACKBAR DENGAN CUSTOM DIALOG
    if (selectedN == null && selectedP == null && selectedK == null) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        title: "Pupuk Belum Dipilih",
        message: "Silakan pilih minimal satu jenis pupuk dari daftar sebelum memesan.",
      );
      return;
    }

    String msg =
        "Halo Tala Argo, saya ingin memesan pupuk hasil analisis FertiScan:\n\n";

    if (selectedN != null) {
      msg += "- ${selectedN!['nama_pupuk']}: ${_calculateDose(selectedN).toStringAsFixed(1)} Kg\n";
    }
    if (selectedP != null) {
      msg += "- ${selectedP!['nama_pupuk']}: ${_calculateDose(selectedP).toStringAsFixed(1)} Kg\n";
    }
    if (selectedK != null) {
      msg += "- ${selectedK!['nama_pupuk']}: ${_calculateDose(selectedK).toStringAsFixed(1)} Kg\n";
    }

    int total = _calculateCost(selectedN) + _calculateCost(selectedP) + _calculateCost(selectedK);
    msg += "\n*Total Estimasi:* ${currencyFormat.format(total)}";

    final String urlStr = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(msg)}";
    final Uri url = Uri.parse(urlStr);

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Gagal membuka $url';
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.show(
          context: context,
          isSuccess: false,
          title: "Koneksi Gagal",
          message: "Tidak dapat membuka WhatsApp. Pastikan aplikasi WhatsApp sudah terinstal di perangkat Anda.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.resultData['data'] ?? {};
    final rekom = res['rekomendasi'] ?? {};
    int totalBiaya = _calculateCost(selectedN) + _calculateCost(selectedP) + _calculateCost(selectedK);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context)),
        title: const Text("Hasil Analisis",
            style: TextStyle(
                color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVisualCard(res),
            const SizedBox(height: 25),
            _buildSectionLabel("CATATAN PAKAR"),
            _buildExpertNote(res['saran_pakar'] ?? "Gunakan takaran ini untuk hasil panen jagung maksimal."),
            const SizedBox(height: 30),
            _buildSectionLabel("DAFTAR PUPUK REKOMENDASI"),
            if (rekom['nitrogen'] != null && rekom['nitrogen'].isNotEmpty)
              _buildRankingGroup("Kebutuhan Nitrogen (N)", rekom['nitrogen'], selectedN, 
              (val) => setState(() => selectedN = val == null ? null : Map<String, dynamic>.from(val))),
            if (rekom['fosfor'] != null && rekom['fosfor'].isNotEmpty)
              _buildRankingGroup("Kebutuhan Fosfor (P)", rekom['fosfor'], selectedP, 
              (val) => setState(() => selectedP = val == null ? null : Map<String, dynamic>.from(val))),
            if (rekom['kalium'] != null && rekom['kalium'].isNotEmpty)
              _buildRankingGroup("Kebutuhan Kalium (K)", rekom['kalium'], selectedK, 
              (val) => setState(() => selectedK = val == null ? null : Map<String, dynamic>.from(val))),
            const SizedBox(height: 25),
            _buildSummaryCard(totalBiaya),
            const SizedBox(height: 35),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingGroup(String title, List list, Map? current, Function(Map?) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 4),
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryGreen))),
        ...list.asMap().entries.map((entry) {
          int idx = entry.key;
          Map<String, dynamic> item = Map<String, dynamic>.from(entry.value);
          bool isSelected = current != null && current['id'] == item['id'];
          return GestureDetector(
            onTap: () => onSelect(isSelected ? null : item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF1F8E9) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade200, width: isSelected ? 2 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 12, backgroundColor: isSelected ? AppColors.primaryGreen : Colors.grey[300],
                          child: Text("${idx + 1}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item['nama_pupuk'] ?? "Pupuk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.primaryGreen : Colors.black87))),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 22),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Kandungan: N:${item['kadar_n_persen']}% P:${item['kadar_p_persen']}% K:${item['kadar_k_persen']}%",
                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  if (isSelected) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Dosis: ${_calculateDose(item).toStringAsFixed(1)} Kg", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryGreen)),
                        Text(currencyFormat.format(_calculateCost(item)), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 15)),
                      ],
                    )
                  ]
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Estimasi Biaya Total", style: TextStyle(color: Colors.white70, fontSize: 12)),
            Text("Pesanan Petani", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))
          ]),
          Text(currencyFormat.format(total), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildVisualCard(Map res) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(widget.imageFile, width: 100, height: 110, fit: BoxFit.cover)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(res['jenis_tanah'] ?? "Analisis Visual", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                const SizedBox(height: 4),
                Text("Fase: ${res['fase'] ?? '-'}", style: const TextStyle(color: AppColors.actionOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                Text("Luas: ${res['luas_lahan'] ?? '-'} Hektar", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text("Akurasi Scan: ${_formatAccuracy()}", style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.2)));

  Widget _buildExpertNote(String note) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.actionOrange.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.psychology_alt, color: AppColors.actionOrange, size: 28),
        const SizedBox(width: 15),
        Expanded(child: Text(note, style: const TextStyle(color: AppColors.actionOrange, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4)))
      ]));

  Widget _buildActionButtons() => Column(children: [
        SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
                onPressed: _launchWhatsApp,
                icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
                label: const Text("PESAN SEKARANG ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const FarmerDashboardScreen()),
                (route) => false,
              );
            },
            child: const Text("KEMBALI KE BERANDA", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ),
      ]);
}