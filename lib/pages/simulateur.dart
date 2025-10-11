import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class SimulateurPage extends StatefulWidget {
  final double poids;
  final double doseTotale;
  final String typeDiabete;
  final String insulineBasale;
  final String insulineBolus;
  final double isf;
  final double icr;
  final double fg;
  final double iob;

  const SimulateurPage({
    super.key,
    required this.poids,
    required this.doseTotale,
    required this.typeDiabete,
    required this.insulineBasale,
    required this.insulineBolus,
    required this.isf,
    required this.icr,
    required this.fg,
    required this.iob,
  });

  @override
  State<SimulateurPage> createState() => _SimulateurPageState();
}

class _SimulateurPageState extends State<SimulateurPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        title: const Text("Résultats Théoriques"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Voici tes résultats théoriques calculés à partir de ton profil :",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ces valeurs servent de référence. Elles peuvent différer de tes valeurs empiriques. "
              "Il est conseillé de mesurer ton ISF et ton ICR réels (jour/nuit) avant d’utiliser le simulateur de correction.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),

            _buildGraphRow("ISF", widget.isf, Colors.orange, "mg/dL/U",
                "L'ISF (Indice Sensibilité à l'Insuline) indique de combien ta glycémie baisse après une unité d’insuline rapide."),
            _buildGraphRow("ICR", widget.icr, Colors.green, "g/U",
                "L'ICR (Indice de Couverture des Glucides) indique combien de grammes de glucides une unité d’insuline rapide peut couvrir."),
            _buildGraphRow("FG", widget.fg, Colors.pinkAccent, "mg/dL",
                "La glycémie (FG) représente le taux de sucre dans le sang au moment du calcul."),
            _buildGraphRow("IOB", widget.iob, Colors.blueAccent, "U",
                "L'IOB (Insuline On Board) correspond à la quantité d’insuline encore active dans ton corps."),

            const SizedBox(height: 30),

            // 🔹 Boutons actions avec explications
            ElevatedButton.icon(
              icon: const Icon(Icons.bloodtype),
              label: const Text(
                "Calculer ISF Empirique",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showIsfEmpiriquePopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Calcule ton ISF réel à partir de mesures avant/après bolus.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.monitor_heart),
              label: const Text(
                "Simuler Correction Glycémique",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showCorrectionPopup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Simule une correction hyper ou hypoglycémique selon tes valeurs actuelles.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphRow(
      String title, double value, Color color, String unite, String description) {
    double maxValue = title == "FG" ? 300 : 100;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text("${value.round()} $unite",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.start,
                maxY: maxValue,
                minY: 0,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: value,
                        color: color,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
        ],
      ),
    );
  }

  // 🔹 Popup ISF empirique Neumorphic
  void _showIsfEmpiriquePopup(BuildContext context) {
    final glyAvant = TextEditingController();
    final glyApres = TextEditingController();
    final dose = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 8,
            intensity: 0.8,
            color: NeumorphicTheme.baseColor(context),
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Calcul ISF Empirique",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: glyAvant,
                decoration: const InputDecoration(labelText: "Glycémie avant (mg/dL)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: glyApres,
                decoration: const InputDecoration(labelText: "Glycémie après 2h (mg/dL)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dose,
                decoration: const InputDecoration(labelText: "Dose bolus injectée (U)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                "Cette mesure te permet d'obtenir ton ISF réel basé sur tes valeurs réelles.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    style: NeumorphicStyle(
                      color: Colors.grey.shade300,
                      depth: 4,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 12),
                  NeumorphicButton(
                    onPressed: () {
                      double? avant = double.tryParse(glyAvant.text);
                      double? apres = double.tryParse(glyApres.text);
                      double? bolus = double.tryParse(dose.text);
                      if (avant != null && apres != null && bolus != null && bolus > 0) {
                        double isfEmp = (avant - apres) / bolus;
                        Navigator.pop(context);
                        _showResultDialog("ISF Empirique", isfEmp, "mg/dL/U", Colors.orange);
                      }
                    },
                    style: NeumorphicStyle(
                      color: Colors.orange,
                      depth: 4,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: const Text("Calculer", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Popup Correction Glycémique Neumorphic
  void _showCorrectionPopup(BuildContext context) {
    final glyActuelle = TextEditingController();
    final glyCible = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 8,
            intensity: 0.8,
            color: NeumorphicTheme.baseColor(context),
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Correction Glycémique",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: glyActuelle,
                decoration: const InputDecoration(labelText: "Glycémie actuelle (mg/dL)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: glyCible,
                decoration: const InputDecoration(labelText: "Glycémie souhaitée (mg/dL)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                "Cette simulation calcule la dose de correction ou les glucides nécessaires selon ta glycémie cible.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphicButton(
                    onPressed: () => Navigator.pop(context),
                    style: NeumorphicStyle(
                      color: Colors.grey.shade300,
                      depth: 4,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 12),
                  NeumorphicButton(
                    onPressed: () {
                      double? act = double.tryParse(glyActuelle.text);
                      double? cible = double.tryParse(glyCible.text);
                      double isf = widget.isf;
                      if (act != null && cible != null) {
                        if (act > cible) {
                          double dose = (act - cible) / isf;
                          Navigator.pop(context);
                          _showResultDialog("Correction Hyperglycémie", dose, "U", Colors.redAccent);
                        } else if (act < cible) {
                          double glucides = (cible - act) / 5;
                          Navigator.pop(context);
                          _showResultDialog("Correction Hypoglycémie", glucides, "g de glucides", Colors.green);
                        } else {
                          Navigator.pop(context);
                          _showResultDialog("Équilibre", 0, "", Colors.blueAccent);
                        }
                      }
                    },
                    style: NeumorphicStyle(
                      color: Colors.teal,
                      depth: 4,
                      intensity: 0.8,
                      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: const Text("Calculer", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultDialog(String titre, double valeur, String unite, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titre),
        content: Text(
          titre.contains("ISF")
              ? "Ton ISF empirique est de ${valeur.round()} $unite."
              : titre.contains("Hyperglycémie")
                  ? "Dose de correction : ${valeur.round()} $unite."
                  : titre.contains("Hypoglycémie")
                      ? "Consomme environ ${valeur.round()} $unite."
                      : "Ta glycémie est déjà dans la cible.",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
        ],
      ),
    );
  }
}
