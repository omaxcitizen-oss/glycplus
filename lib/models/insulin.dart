class Insulin {
  final String brandName;
  final String type; // 'Basal' or 'Bolus'
  final int duration; // in hours
  final int peakTime; // in hours
  final double defaultRatio; // Default ICR
  final double defaultIsf; // Default ISF

  Insulin({
    required this.brandName,
    required this.type,
    required this.duration,
    required this.peakTime,
    required this.defaultRatio,
    required this.defaultIsf,
  });
}

// --- Insulines Basales (Lentes) ---
final List<Insulin> basalInsulins = [
  Insulin(brandName: 'Lantus', type: 'Basal', duration: 24, peakTime: 0, defaultRatio: 0, defaultIsf: 1800),
  Insulin(brandName: 'Tresiba', type: 'Basal', duration: 42, peakTime: 0, defaultRatio: 0, defaultIsf: 1800),
  Insulin(brandName: 'Levemir', type: 'Basal', duration: 20, peakTime: 0, defaultRatio: 0, defaultIsf: 1800),
  Insulin(brandName: 'Toujeo', type: 'Basal', duration: 36, peakTime: 0, defaultRatio: 0, defaultIsf: 1800),
  Insulin(brandName: 'NPH', type: 'Basal', duration: 16, peakTime: 6, defaultRatio: 0, defaultIsf: 1800), // Note: NPH has a peak
];

// --- Insulines Bolus (Rapides) ---
final List<Insulin> bolusInsulins = [
  Insulin(brandName: 'NovoRapid', type: 'Bolus', duration: 4, peakTime: 1, defaultRatio: 500, defaultIsf: 1800),
  Insulin(brandName: 'Humalog', type: 'Bolus', duration: 4, peakTime: 1, defaultRatio: 500, defaultIsf: 1800),
  Insulin(brandName: 'Apidra', type: 'Bolus', duration: 4, peakTime: 1, defaultRatio: 500, defaultIsf: 1800),
  Insulin(brandName: 'Fiasp', type: 'Bolus', duration: 3, peakTime: 1, defaultRatio: 500, defaultIsf: 1800),
];
