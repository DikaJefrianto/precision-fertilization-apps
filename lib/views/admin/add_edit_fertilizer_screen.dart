import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/fertilizer_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_dialog.dart';

class AddEditFertilizerScreen extends StatefulWidget {
  final Fertilizer? fertilizer;
  const AddEditFertilizerScreen({super.key, this.fertilizer});

  @override
  State<AddEditFertilizerScreen> createState() => _AddEditFertilizerScreenState();
}

class _AddEditFertilizerScreenState extends State<AddEditFertilizerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nController;
  late TextEditingController _pController;
  late TextEditingController _kController;
  late TextEditingController _priceController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fertilizer?.nama_pupuk ?? "");
    _nController = TextEditingController(text: widget.fertilizer?.kadar_n_persen.toString() ?? "");
    _pController = TextEditingController(text: widget.fertilizer?.kadar_p_persen.toString() ?? "");
    _kController = TextEditingController(text: widget.fertilizer?.kadar_k_persen.toString() ?? "");
    _priceController = TextEditingController(text: widget.fertilizer?.harga_per_kg.toString() ?? "");
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      String? token = await StorageService().getToken();

      final data = Fertilizer(
        id: widget.fertilizer?.id ?? 0,
        nama_pupuk: _nameController.text,
        kadar_n_persen: double.parse(_nController.text),
        kadar_p_persen: double.parse(_pController.text),
        kadar_k_persen: double.parse(_kController.text),
        harga_per_kg: double.parse(_priceController.text),
      );

      final api = ApiService();
      final res = widget.fertilizer == null
          ? await api.createFertilizer(token!, data)
          : await api.updateFertilizer(token!, widget.fertilizer!.id, data);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['message'].contains('[Success]')) {
        CustomDialog.show(context: context, isSuccess: true, title: "Berhasil", message: res['message']);
        Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
      } else {
        CustomDialog.show(context: context, isSuccess: false, title: "Gagal", message: res['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.fertilizer != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? "Perbarui Master Pupuk" : "Tambah Master Pupuk"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Spesifikasi Teknis", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text("Kandungan Hara Makro", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildModernInput("Nama Merk Pupuk", _nameController, Icons.label_important_outline, isNum: false),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildModernInput("Kadar N (%)", _nController, Icons.science_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildModernInput("Kadar P (%)", _pController, Icons.science_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildModernInput("Kadar K (%)", _kController, Icons.science_outlined)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildModernInput("Harga per Kilogram", _priceController, Icons.payments_outlined),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.actionOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SIMPAN DATA PUPUK", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInput(String label, TextEditingController controller, IconData icon, {bool isNum = true}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: TextFormField(
        controller: controller,
        keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
        validator: (v) => v == null || v.isEmpty ? "Wajib isi" : null,
      ),
    );
  }
}