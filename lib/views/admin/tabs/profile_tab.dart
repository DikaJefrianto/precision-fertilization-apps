import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../auth/login_screen.dart';
import '../../profile/edit_profile_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      String? token = await _storageService.getToken();
      if (token != null) {
        final res = await _apiService.getUserProfile(token);
        if (res['message'] != null && res['message'].contains('[Success]') && res['data'] != null) {
          if (mounted) {
            setState(() {
              _user = UserModel.fromJson(res['data']);
              _isLoading = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }
  void _showFullScreenImage(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: Hero(
              tag: 'profile_photo',
              child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white, size: 100),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout() async {
    await _storageService.deleteToken();
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
    String fullImageUrl = "";

    if (_user?.foto_profil != null && _user!.foto_profil!.isNotEmpty) {
      final String foto = _user!.foto_profil!;
      if (foto.startsWith('http')) {
        fullImageUrl = foto;
      } else if (foto.contains('uploads/profiles')) {
        fullImageUrl = "${AppConstants.host}${foto.startsWith('/') ? '' : '/'}$foto";
      } else {
        fullImageUrl = "${AppConstants.mediaUrl}/$foto";
      }
      fullImageUrl = "$fullImageUrl?t=${DateTime.now().millisecondsSinceEpoch}";
    }

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : RefreshIndicator(
            onRefresh: _loadProfile,
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (fullImageUrl.isNotEmpty) {
                              _showFullScreenImage(context, fullImageUrl);
                            }
                          },
                          child: Hero(
                            tag: 'profile_photo',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryGreen, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 70,
                                backgroundColor: Colors.grey[200],
                                child: ClipOval(
                                  child: fullImageUrl.isNotEmpty
                                      ? Image.network(
                                          fullImageUrl,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(Icons.broken_image_outlined, size: 60, color: Colors.redAccent);
                                          },
                                        )
                                      : const Icon(Icons.person, size: 80, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 5,
                          child: CircleAvatar(
                            backgroundColor: AppColors.actionOrange,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                              onPressed: () async {
                                if (_user == null) return;
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      currentName: _user!.name,
                                      currentWA: _user!.whatsapp,
                                      currentPhoto: _user!.foto_profil,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  _loadProfile();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _user?.name ?? "Petani", 
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryBlack)
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _user?.role.toUpperCase() ?? "USER",
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildInfoCard(Icons.email_outlined, "Alamat Email", _user?.email ?? "-"),
                  _buildInfoCard(Icons.phone_android_outlined, "Nomor WhatsApp", _user?.whatsapp ?? "-"),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: AppColors.alertRed),
                      label: const Text(
                        "KELUAR AKUN", 
                        style: TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold)
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.alertRed, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 24),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlack)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}