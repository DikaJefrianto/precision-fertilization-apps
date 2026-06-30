class Fertilizer {
  final int id;
  final String nama_pupuk;
  final double kadar_n_persen;
  final double kadar_p_persen;
  final double kadar_k_persen;
  final double harga_per_kg;

  Fertilizer({
    required this.id,
    required this.nama_pupuk,
    required this.kadar_n_persen,
    required this.kadar_p_persen,
    required this.kadar_k_persen,
    required this.harga_per_kg,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      id: json['id'],
      nama_pupuk: json['nama_pupuk'],
      kadar_n_persen: double.parse(json['kadar_n_persen'].toString()),
      kadar_p_persen: double.parse(json['kadar_p_persen'].toString()),
      kadar_k_persen: double.parse(json['kadar_k_persen'].toString()),
      harga_per_kg: double.parse(json['harga_per_kg'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_pupuk': nama_pupuk,
        'kadar_n_persen': kadar_n_persen,
        'kadar_p_persen': kadar_p_persen,
        'kadar_k_persen': kadar_k_persen,
        'harga_per_kg': harga_per_kg,
      };
}