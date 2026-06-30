import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';
import '../../core/constants.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentWA;
  final String? currentPhoto;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentWA,
    this.currentPhoto,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _waController;
  File? _image;
  final _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _waController = TextEditingController(text: widget.currentWA);
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _handleSaveAll() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final api = ApiService();
    final storage = StorageService();
    String? token = await storage.getToken();

    try {
      final resProfile = await api.updateProfile(
          token!, _nameController.text.trim(), _waController.text.trim());
      
      if (resProfile['message'].contains('[Success]')) {
        // Jika ada foto baru yang dipilih, unggah ke server
        if (_image != null) {
          final resPhoto = await api.uploadProfilePhoto(token, _image!.path);
          if (!resPhoto['message'].contains('[Success]')) {
            throw Exception(resPhoto['message']);
          }
        }
        
        if (!mounted) return;
        CustomDialog.show(
            context: context,
            isSuccess: true,
            title: "Berhasil",
            message: "Profil diperbarui.");
            
        // Kembali ke halaman profil dan memberitahu untuk refresh data
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.pop(context, true));
      } else {
        throw Exception(resProfile['message']);
      }
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(
          context: context,
          isSuccess: false,
          title: "Gagal",
          message: e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Membangun URL gambar lama dari server (menggunakan mediaUrl dari constants)
    String serverImageUrl = "";
    if (widget.currentPhoto != null && widget.currentPhoto!.isNotEmpty) {
      serverImageUrl = "${AppConstants.mediaUrl}/${widget.currentPhoto}?v=${DateTime.now().millisecondsSinceEpoch}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("Edit Profil"),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryBlack,
          elevation: 0.5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[200],
                      // LOGIKA PREVIEW GAMBAR:
                      // 1. Jika ada foto baru dipilih dari HP (_image), tampilkan FileImage.
                      // 2. Jika tidak ada, tapi ada foto lama dari server, tampilkan NetworkImage.
                      // 3. Jika keduanya kosong, tampilkan null (akan memicu icon di 'child').
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (serverImageUrl.isNotEmpty)
                              ? NetworkImage(serverImageUrl) as ImageProvider
                              : null,
                      child: (_image == null && serverImageUrl.isEmpty)
                          ? const Icon(Icons.person, size: 80, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                            backgroundColor: AppColors.actionOrange,
                            radius: 22,
                            child: Icon(Icons.camera_alt,
                                color: Colors.white, size: 20)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                  label: "Nama Lengkap",
                  controller: _nameController,
                  icon: Icons.person_outline),
              const SizedBox(height: 20),
              _buildTextField(
                  label: "Nomor WhatsApp",
                  controller: _waController,
                  icon: Icons.phone_android_outlined,
                  isPhone: true),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSaveAll,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("SIMPAN PERUBAHAN",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }
}