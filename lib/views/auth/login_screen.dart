import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_dialog.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../petani/farmer_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isObscure = true;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final apiService = ApiService();
      final storage = StorageService();

      final response = await apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['message'] != null &&
          response['message'].contains('[Success]')) {
        String serverRole = response['user']['role'];

        await storage.saveToken(response['token']);
        await storage.saveRole(response['user']['role']);

        // ignore: use_build_context_synchronously
        CustomDialog.show(
          context: context,
          isSuccess: true,
          title: "Berhasil Masuk",
          message: "Selamat datang kembali, ${response['user']['nama']}",
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            if (serverRole == 'Admin') {
              debugPrint(
                  "Sistem: Login sebagai Admin. Navigasi ke Panel Admin...");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
            } else {
              debugPrint(
                  "Sistem: Login sebagai Petani. Navigasi ke Dashboard Petani...");
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FarmerDashboardScreen()));
            }
          }
        });
      } else {
        CustomDialog.show(
          context: context,
          isSuccess: false,
          title: "Gagal Masuk",
          message: response['message'] ?? "Email atau password salah.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: AppColors.pureWhite,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.lightGray),
                          ),
                          child:
                              Image.asset('assets/images/logo.png', width: 60),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Masuk ke FertiScan",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Text(
                          "Portal Manajemen Agrikultur Terpadu",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 35),
                        _buildLabel("Email"),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "contoh@pertanian.com",
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Email tidak boleh kosong"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Kata Sandi"),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            hintText: "Masukkan kata sandi",
                            prefixIcon:
                                const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                          validator: (value) => value!.isEmpty
                              ? "Kata sandi tidak boleh kosong"
                              : null,
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.actionOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "Masuk →",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            "Belum punya akun? Daftar",
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style:
            const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }
}
