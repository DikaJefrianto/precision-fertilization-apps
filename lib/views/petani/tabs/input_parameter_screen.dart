import 'dart:io';
import 'package:flutter/material.dart';
import '/core/app_colors.dart';
import '/services/api_service.dart';
import '/services/storage_service.dart';
import '/widgets/custom_dialog.dart';
import '../result_screen.dart'; 

class InputParameterScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> soilData;

  const InputParameterScreen({super.key, required this.imageFile, required this.soilData});

  @override
  State<InputParameterScreen> createState() => _InputParameterScreenState();
}

class _InputParameterScreenState extends State<InputParameterScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  late double _hst;
  late double _n;
  late double _p;
  late double _k;
  final _areaController = TextEditingController(text: "1.0");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("DEBUG: Data Scan dari Flask -> ${widget.soilData}");

    _hst = 15;
    _n = _parseToDouble(widget.soilData['n']);
    _p = _parseToDouble(widget.soilData['p']);
    _k = _parseToDouble(widget.soilData['k']);
  }

  double _parseToDouble(dynamic val) {
    if (val == null) return 0.0;
    return double.tryParse(val.toString()) ?? 0.0;
  }

  void _handleFinalAnalysis() async {
    if (_areaController.text.isEmpty) {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        title: "Data Kosong",
        message: "Silakan masukkan luas lahan terlebih dahulu.",
      );
      return;
    }

    setState(() => _isLoading = true);
    String? token = await _storageService.getToken();

    String accuracyFromFlask = (widget.soilData['accuracy'] ?? "0").toString();

    print("DEBUG: Mengirim Akurasi ke Backend -> $accuracyFromFlask");

    final response = await _apiService.calculateFertilizer(
      token: token!,
      labelTanah: widget.soilData['label'] ?? "Tanah Merah",
      n: _n,
      p: _p,
      k: _k,
      hst: _hst.toInt(),
      area: double.tryParse(_areaController.text) ?? 1.0,
      imagePath: widget.imageFile.path, 
      accuracy: accuracyFromFlask, 
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response['message'] != null && response['message'].contains('[Success]')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            imageFile: widget.imageFile,
            resultData: response,
            nInput: _n,
            pInput: _p,
            kInput: _k,
          ),
        ),
      );
    } else {
      CustomDialog.show(
        context: context,
        isSuccess: false,
        title: "Gagal Analisis",
        message: response['message'] ?? "Terjadi kesalahan koneksi.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text("FertiScan", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Input Parameter Tanah &\nTanaman", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: Colors.grey.shade200)
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(widget.imageFile, width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Jenis Tanah Terdeteksi:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          widget.soilData['label'] ?? "Tanah", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryGreen)
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildSlider("Usia Tanaman (HST)", _hst, 0, 120, "Hari", (v) => setState(() => _hst = v)),
            _buildSlider("Kadar Nitrogen (N)", _n, 0, 5, "%", (v) => setState(() => _n = v)),
            _buildSlider("Kadar Fosfor (P)", _p, 0, 5, "%", (v) => setState(() => _p = v)),
            _buildSlider("Kadar Kalium (K)", _k, 0, 5, "%", (v) => setState(() => _k = v)),
            
            const Text("Luas Lahan Aktif", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _areaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: "Contoh: 1.5",
                      filled: true, 
                      fillColor: Colors.white, 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                  child: const Text("Hektar\n(Ha)", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleFinalAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Analisis & Hitung Rekomendasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double val, double min, double max, String unit, Function(double) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), 
            Text("${val.toStringAsFixed(2)} $unit", style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold))
          ],
        ),
        Slider(
          value: val, 
          min: min, 
          max: max, 
          activeColor: AppColors.primaryGreen, 
          onChanged: onChanged
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}