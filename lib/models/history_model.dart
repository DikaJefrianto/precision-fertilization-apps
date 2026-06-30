class HistoryModel {
  final int id;
  final String soilLabel;
  final String result;
  final String date;
  final int hst;
  final double area;

  HistoryModel({
    required this.id,
    required this.soilLabel,
    required this.result,
    required this.date,
    required this.hst,
    required this.area,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      soilLabel: json['label_tanah_ai'] ?? "Tanah",
      result: json['rekomendasi_hasil'] ?? "-",
      date: json['tanggal_simpan'] ?? "",
      hst: json['hst_input'] ?? 0,
      area: double.parse((json['luas_lahan'] ?? 0).toString()),
    );
  }
}