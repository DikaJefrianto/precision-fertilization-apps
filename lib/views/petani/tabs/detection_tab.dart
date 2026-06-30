import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../services/layanan_ai.dart'; 
import '../../../widgets/custom_dialog.dart';
import '../../petani/tabs/input_parameter_screen.dart';

class DetectionTab extends StatefulWidget {
  const DetectionTab({super.key});

  @override
  State<DetectionTab> createState() => _DetectionTabState();
}

class _DetectionTabState extends State<DetectionTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  final LayananAI _layananAI = LayananAI(); 
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;

  Future<void> _processImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });

      try {

        final response = await _apiService.predictSoilImage(pickedFile.path);

        if (!mounted) return;

        if (response['message'] != null && response['message'].contains('[Success]')) {

          String detectedLabel = response['label'];
          

          var accuracyFromAI = response['accuracy']; 
          

          print("AI SCAN SUCCESS: $detectedLabel ($accuracyFromAI%)");

          Map<String, double> haraOtomatis = _layananAI.getHaraOtomatis(detectedLabel);

          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputParameterScreen(
                imageFile: _imageFile!,
                soilData: {
                  "label": detectedLabel,
                  "accuracy": accuracyFromAI, 
                  "n": haraOtomatis['n'], 
                  "p": haraOtomatis['p'],
                  "k": haraOtomatis['k'],
                },
              ),
            ),
          );
        } else {
          setState(() => _isLoading = false);
          CustomDialog.show(
            context: context,
            isSuccess: false,
            title: "Gagal Deteksi",
            message: response['message'] ?? "Gagal terhubung ke AI Server",
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        CustomDialog.show(
          context: context,
          isSuccess: false,
          title: "Error",
          message: "Terjadi kesalahan sistem: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Identifikasi Lahan",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Ambil foto permukaan tanah untuk memulai analisis.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            width: 2),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_outlined,
                                    size: 80, color: Colors.grey),
                                SizedBox(height: 10),
                                Text("Gunakan Kamera atau Upload Gambar",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: "Kamera",
                          icon: Icons.camera_enhance,
                          onTap: () => _processImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          label: "Galeri",
                          icon: Icons.photo_library,
                          onTap: () => _processImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50], 
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.actionOrange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pastikan foto diambil pada siang hari dengan cahaya cukup agar akurasi AI maksimal.",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton(
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.primaryGreen.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}