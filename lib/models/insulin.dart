
class Insulin {
  final String brandName;
  final String type; // 'Basal' or 'Bolus'
  final String duration;
  final String peak;
  // Valeurs par défaut qui pourraient être utilisées pour une initialisation
  final double? defaultIsf;
  final double? defaultIcr;

  const Insulin({
    required this.brandName,
    required this.type,
    required this.duration,
    required this.peak,
    this.defaultIsf,
    this.defaultIcr,
  });
}

// --- Listes des marques d'insuline ---

const List<String> basalInsulinBrands = [
  'Lantus',
  'Tresiba',
  'Levemir',
  'Toujeo',
  'NPH',
];

const List<String> bolusInsulinBrands = [
  'NovoRapid',
  'Humalog',
  'Apidra',
  'Fiasp',
];
