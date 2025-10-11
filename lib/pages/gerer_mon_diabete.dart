import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'simulateur.dart';

class GererMonDiabetePage extends StatefulWidget {
  const GererMonDiabetePage({super.key});

  @override
  State<GererMonDiabetePage> createState() => _GererMonDiabetePageState();
}

class _GererMonDiabetePageState extends State<GererMonDiabetePage> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController poidsController = TextEditingController();
  final TextEditingController insulineTotaleController = TextEditingController();

  String typeDiabete = 'Type 1';
  String insulineBasale = 'Lantus';
  String insulineBolus = 'NovoRapid';

  double isf = 0;
  double icr = 0;
  double fg = 0;
  double iob = 0;

  @override
  Widget build(BuildContext context) {
    final baseColor = NeumorphicTheme.baseColor(context);

    return NeumorphicBackground(
      child: Scaffold(
        backgroundColor: baseColor,
        appBar: NeumorphicAppBar(
          title: const Text(
            "Gérer mon diabète",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: NeumorphicButton(
            style: const NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              depth: 4,
            ),
            padding: const EdgeInsets.all(8),
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: const Text(
                  "Personnalisez vos paramètres",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: const Text(
                  "Renseignez vos informations pour estimer vos facteurs personnels (ISF, ICR, FG, IOB).",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.5, color: Colors.black54, height: 1.4),
                ),
              ),
              const SizedBox(height: 25),

              _buildNeumorphicTextField(ageController, "Âge (années)", Icons.cake),
              const SizedBox(height: 15),
              _buildNeumorphicTextField(poidsController, "Poids (kg)", Icons.monitor_weight),
              const SizedBox(height: 15),

              _buildStyledDropdown(
                label: "Type de diabète",
                value: typeDiabete,
                items: ['Type 1', 'Type 2 insulino-dépendant', 'LADA'],
                onChanged: (val) => setState(() => typeDiabete = val!),
              ),
              const SizedBox(height: 15),
              _buildStyledDropdown(
                label: "Insuline basale",
                value: insulineBasale,
                items: ['Lantus', 'Tresiba', 'Levemir', 'Toujeo'],
                onChanged: (val) => setState(() => insulineBasale = val!),
              ),
              const SizedBox(height: 15),
              _buildStyledDropdown(
                label: "Insuline bolus",
                value: insulineBolus,
                items: ['NovoRapid', 'Humalog', 'Apidra', 'Fiasp'],
                onChanged: (val) => setState(() => insulineBolus = val!),
              ),
              const SizedBox(height: 15),

              _buildNeumorphicTextField(insulineTotaleController, "Dose totale d’insuline (U)", Icons.bloodtype),
              const SizedBox(height: 25),

              FadeInUp(
                delay: const Duration(milliseconds: 500),
                child: NeumorphicButton(
                  onPressed: _lancerSimulateur,
                  style: NeumorphicStyle(
                    depth: 8,
                    intensity: 0.8,
                    color: Colors.deepPurple,
                    boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: const Center(
                    child: Text(
                      "Lancer le simulateur",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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

  // === Widgets Neumorphic ===
  Widget _buildNeumorphicTextField(TextEditingController controller, String label, IconData icon) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -4,
        intensity: 0.7,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  // === Dropdown stylé avec dropdown_button2 simple (compatible v2.3.9) ===
  Widget _buildStyledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              value: value,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  void _lancerSimulateur() {
    final double poids = double.tryParse(poidsController.text) ?? 0;
    final double doseTotale = double.tryParse(insulineTotaleController.text) ?? 1;

    isf = 1800 / doseTotale;
    icr = 500 / doseTotale;
    fg = 0.8 * poids;
    iob = doseTotale * 0.25;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SimulateurPage(
          poids: poids,
          doseTotale: doseTotale,
          typeDiabete: typeDiabete,
          insulineBasale: insulineBasale,
          insulineBolus: insulineBolus,
          isf: isf,
          icr: icr,
          fg: fg,
          iob: iob,
        ),
      ),
    );
  }
}
