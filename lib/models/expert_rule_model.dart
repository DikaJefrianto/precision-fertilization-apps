class ExpertRule {
  final int? id;
  final String phaseName; 
  final String soilLabel; // Variabel di Flutter
  final String hstRange;
  final double targetN;
  final double targetP;
  final double targetK;
  final String advice;

  ExpertRule({
    this.id,
    required this.phaseName,
    required this.soilLabel, 
    required this.hstRange,
    required this.targetN,
    required this.targetP,
    required this.targetK,
    required this.advice,
  });

  factory ExpertRule.fromJson(Map<String, dynamic> json) {
    return ExpertRule(
      id: json['id'],
      phaseName: (json['nama_fase'] ?? "Tanpa Fase").toString(),
      // PASTIKAN KEY-NYA 'label_tanah' (sesuai database)
      soilLabel: (json['label_tan_ah'] ?? json['label_tanah'] ?? "Tanah Merah").toString(), 
      hstRange: (json['rentang_hst'] ?? "0-20").toString(),
      targetN: double.tryParse(json['target_n'].toString()) ?? 0.0,
      targetP: double.tryParse(json['target_p'].toString()) ?? 0.0,
      targetK: double.tryParse(json['target_k'].toString()) ?? 0.0,
      advice: (json['saran_pakar'] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'nama_fase': phaseName,
    'label_tanah': soilLabel, 
    'rentang_hst': hstRange,
    'target_n': targetN,
    'target_p': targetP,
    'target_k': targetK,
    'saran_pakar': advice,
  };
}