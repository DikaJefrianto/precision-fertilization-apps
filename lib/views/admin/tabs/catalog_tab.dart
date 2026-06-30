import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../models/fertilizer_model.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/custom_dialog.dart';
import '../add_edit_fertilizer_screen.dart';

class CatalogTab extends StatefulWidget {
  const CatalogTab({super.key});

  @override
  State<CatalogTab> createState() => _CatalogTabState();
}

class _CatalogTabState extends State<CatalogTab> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  List<Fertilizer> _listPupuk = [];
  List<Fertilizer> _filteredPupuk = [];
  bool _isLoading = true;
  String? _userRole;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    String? token = await _storageService.getToken();
    String? role = await _storageService.getRole();
    
    if (token == null) return;
    setState(() { _userRole = role; });

    final res = await _apiService.getFertilizers(token);
    if (!mounted) return;

    if (res['message'] != null && res['message'].contains('[Success]')) {
      setState(() {
        _listPupuk = (res['data'] as List).map((e) => Fertilizer.fromJson(e)).toList();
        _filteredPupuk = _listPupuk;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _deleteData(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Pupuk"),
        content: const Text("Data ini akan dihapus permanen."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            onPressed: () async {
              Navigator.pop(context);
              String? token = await _storageService.getToken();
              final res = await _apiService.deleteFertilizer(token!, id);
              if (res['message'].contains('[Success]')) {
                _loadData();
                if (mounted) CustomDialog.show(context: context, isSuccess: true, title: "Berhasil", message: "Data dihapus");
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = _userRole == 'Admin';

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
        : RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primaryGreen,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER SECTION
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("DATA MASTER", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        const SizedBox(height: 5),
                        const Text("Katalog Master Pupuk", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 15),
                        TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() {
                            _filteredPupuk = _listPupuk.where((p) => p.nama_pupuk.toLowerCase().contains(v.toLowerCase())).toList();
                          }),
                          decoration: InputDecoration(
                            hintText: "Cari nama pupuk...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditFertilizerScreen()));
                                if (refresh == true) _loadData();
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Tambah Pupuk Baru", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F3F4)),
                      columnSpacing: 25,
                      columns: [
                        const DataColumn(label: Text("NAMA PUPUK", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text("N (%)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text("P (%)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text("K (%)", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        const DataColumn(label: Text("HARGA/KG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        if (isAdmin) const DataColumn(label: Text("AKSI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      ],
                      rows: _filteredPupuk.map((f) {
                        return DataRow(cells: [
                          DataCell(Text(f.nama_pupuk, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(f.kadar_n_persen.toStringAsFixed(0))),
                          DataCell(Text(f.kadar_p_persen.toStringAsFixed(0))),
                          DataCell(Text(f.kadar_k_persen.toStringAsFixed(0))),
                          DataCell(Text("Rp ${f.harga_per_kg.toStringAsFixed(0)}")),
                          if (isAdmin)
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: () async {
                                    final refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditFertilizerScreen(fertilizer: f)));
                                    if (refresh == true) _loadData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () => _deleteData(f.id),
                                ),
                              ],
                            )),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
  }
}