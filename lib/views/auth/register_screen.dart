import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_dialog.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _waController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure = true;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final apiService = ApiService();
      final response = await apiService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _waController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response['message'] != null && response['message'].contains('[Success]')) {
        CustomDialog.show(
          context: context,
          isSuccess: true,
          title: "Berhasil Daftar",
          message: response['message'],
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        });
      } else {
        CustomDialog.show(
          context: context,
          isSuccess: false,
          title: "Gagal Daftar",
          message: response['message'] ?? "Terjadi kesalahan pendaftaran.",
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColors.pureWhite,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
                          child: Image.asset('assets/images/logo.png', width: 50),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Daftar Akun Petani",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Text(
                          "Lengkapi data untuk mulai menggunakan FertiScan",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 30),
                        
                        _buildLabel("Nama Lengkap"),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Masukkan nama lengkap",
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (value) => value!.isEmpty ? "Nama wajib diisi" : null,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel("Email"),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "contoh@email.com",
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          validator: (value) => value!.isEmpty ? "Email wajib diisi" : null,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel("Nomor WhatsApp"),
                        TextFormField(
                          controller: _waController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: "0812xxxx",
                            prefixIcon: Icon(Icons.phone_android_outlined, size: 20),
                          ),
                          validator: (value) => value!.isEmpty ? "Nomor WA wajib diisi" : null,
                        ),
                        const SizedBox(height: 18),

                        _buildLabel("Kata Sandi"),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            hintText: "Minimal 8 karakter",
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) return "Sandi wajib diisi";
                            if (value.length < 8) return "Sandi minimal 8 karakter";
                            return null;
                          },
                        ),
                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.actionOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading 
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  "Daftar Sekarang",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Sudah punya akun? Masuk",
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
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 13),
      ),
    );
  }
}