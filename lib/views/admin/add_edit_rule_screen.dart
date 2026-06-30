import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../models/expert_rule_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_dialog.dart';

class AddEditRuleScreen extends StatefulWidget {
  final ExpertRule? rule;
  const AddEditRuleScreen({super.key, this.rule});

  @override
  State<AddEditRuleScreen> createState() => _AddEditRuleScreenState();
}

class _AddEditRuleScreenState extends State<AddEditRuleScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _hstController;
  late TextEditingController _nController;
  late TextEditingController _pController;
  late TextEditingController _kController;
  late TextEditingController _saranController;
  
  // Variabel untuk Fase
  String _selectedPhase = 'Vegetatif Awal';
  final List<String> _listFase = [
    'Vegetatif Awal',
    'Vegetatif Aktif',
    'Generatif',
    'Pengisian Biji'
  ];

  // Variabel untuk Jenis Tanah (BARU)
  String _selectedSoil = 'Tanah Merah';
  final List<String> _listSoil = [
    'Tanah Aluvial',
    'Tanah Hitam',
    'Tanah Laterit',
    'Tanah Merah'
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _hstController = TextEditingController(text: widget.rule?.hstRange ?? "");
    _nController = TextEditingController(text: widget.rule?.targetN.toString() ?? "");
    _pController = TextEditingController(text: widget.rule?.targetP.toString() ?? "");
    _kController = TextEditingController(text: widget.rule?.targetK.toString() ?? "");
    _saranController = TextEditingController(text: widget.rule?.advice ?? "");
    
    if (widget.rule != null) {
      _selectedPhase = widget.rule!.phaseName;
      _selectedSoil = widget.rule!.soilLabel; // Inisialisasi data tanah jika mode edit
    }
  }

  @override
  void dispose() {
    _hstController.dispose();
    _nController.dispose();
    _pController.dispose();
    _kController.dispose();
    _saranController.dispose();
    super.dispose();
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final storage = StorageService();
      String? token = await storage.getToken();
      
      // MEMASUKKAN DATA SOIL LABEL KE MODEL
      final ruleData = ExpertRule(
        phaseName: _selectedPhase,
        soilLabel: _selectedSoil, // <--- DATA TANAH DISERTAKAN
        hstRange: _hstController.text,
        targetN: double.tryParse(_nController.text) ?? 0.0,
        targetP: double.tryParse(_pController.text) ?? 0.0,
        targetK: double.tryParse(_kController.text) ?? 0.0,
        advice: _saranController.text,
      );

      final api = ApiService();
      final res = widget.rule == null 
          ? await api.createRule(token!, ruleData)
          : await api.updateRule(token!, widget.rule!.id!, ruleData);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res['message'] != null && res['message'].contains('[Success]')) {
        CustomDialog.show(
          context: context, 
          isSuccess: true,
          title: "Berhasil Tersimpan", 
          message: "Aturan untuk $_selectedSoil fase $_selectedPhase berhasil diperbarui.",
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, true);
        });
      } else {
        CustomDialog.show(
          context: context, 
          isSuccess: false, 
          title: "Gagal", 
          message: res['message'] ?? "Terjadi kesalahan sistem.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.rule != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? "Perbarui Aturan" : "Aturan Baru"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primaryBlack,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Konfigurasi Parameter", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Text(
                    isEdit ? "Edit Aturan Pakar" : "Tambah Aturan Pakar",
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // INPUT JENIS TANAH
                    _buildSectionHeader("Identifikasi Jenis Tanah"),
                    _buildDropdown(
                      value: _selectedSoil,
                      items: _listSoil,
                      icon: Icons.landscape_rounded,
                      onChanged: (val) => setState(() => _selectedSoil = val!),
                    ),
                    const SizedBox(height: 25),

                    // INPUT FASE
                    _buildSectionHeader("Kategori Fase Pertumbuhan"),
                    _buildDropdown(
                      value: _selectedPhase,
                      items: _listFase,
                      icon: Icons.layers_outlined,
                      onChanged: (val) => setState(() => _selectedPhase = val!),
                    ),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Periode Tanaman"),
                    _buildModernInput(
                      label: "Rentang HST",
                      hint: "Misal: 10-20",
                      controller: _hstController,
                      icon: Icons.calendar_today_rounded,
                      isNumeric: false,
                    ),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Target Nutrisi (Kg/Ha)"),
                    Row(
                      children: [
                        Expanded(child: _buildModernInput(label: "N", hint: "0", controller: _nController, icon: Icons.science_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildModernInput(label: "P", hint: "0", controller: _pController, icon: Icons.science_outlined)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildModernInput(label: "K", hint: "0", controller: _kController, icon: Icons.science_outlined)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    _buildSectionHeader("Instruksi Pakar"),
                    _buildModernInput(
                      label: "Saran Tambahan",
                      hint: "Tuliskan rekomendasi teknis...",
                      controller: _saranController,
                      icon: Icons.comment_bank_outlined,
                      isNumeric: false,
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.actionOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade600, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required IconData icon, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        ),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildModernInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isNumeric = true,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.isEmpty ? "Wajib isi" : null,
      ),
    );
  }
}