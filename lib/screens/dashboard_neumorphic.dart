import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glycplus/screens/auth_screen.dart';
import 'package:glycplus/pages/gerer_mon_diabete.dart';

class DashboardNeumorphic extends StatelessWidget {
  const DashboardNeumorphic({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = NeumorphicTheme.baseColor(context);

    // Afficher le popup au lancement de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimer(context);
    });

    return NeumorphicTheme(
      themeMode: ThemeMode.light,
      child: NeumorphicBackground(
        child: Scaffold(
          backgroundColor: baseColor,
          appBar: NeumorphicAppBar(
            title: const Text(
              "Espace Santé+",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            centerTitle: true,
            actions: [
              NeumorphicButton(
                style: const NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.stadium(),
                  depth: 4,
                ),
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                },
                child: const Icon(Icons.logout, color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 700),
                  child: const Text(
                    "Bienvenue 👋",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    "Optimisez votre bien-être avec vos outils intelligents personnalisés.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15.5, color: Colors.black54, height: 1.4),
                  ),
                ),
                const SizedBox(height: 25),

                _moduleRow(
                  context,
                  icon: Icons.health_and_safety_rounded,
                  title: "Gérer mon diabète",
                  description:
                      "Calculez vos ISF, ICR, FG et IOB pour simuler votre équilibre glycémique.",
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GererMonDiabetePage()),
                    );
                  },
                  delay: 250,
                ),
                _moduleRow(
                  context,
                  icon: Icons.restaurant_rounded,
                  title: "Calculer mes glucides",
                  description:
                      "Analysez vos repas et estimez vos apports en glucides facilement.",
                  color: Colors.orangeAccent,
                  onTap: () {},
                  delay: 400,
                ),
                _moduleRow(
                  context,
                  icon: Icons.fitness_center_rounded,
                  title: "Mode sportif",
                  description:
                      "Ajustez votre alimentation selon votre activité physique.",
                  color: Colors.green,
                  onTap: () {},
                  delay: 550,
                ),
                _moduleRow(
                  context,
                  icon: Icons.monitor_weight_rounded,
                  title: "Atteindre mon poids idéal",
                  description:
                      "Suivez vos progrès et atteignez votre poids de forme.",
                  color: Colors.pinkAccent,
                  onTap: () {},
                  delay: 700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _moduleRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: GestureDetector(
        onTap: onTap,
        child: Neumorphic(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16),
          style: NeumorphicStyle(
            depth: 10,
            intensity: 0.75,
            color: NeumorphicTheme.baseColor(context),
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
          ),
          child: Row(
            children: [
              Neumorphic(
                style: NeumorphicStyle(
                  depth: 6,
                  intensity: 0.85,
                  color: color.withOpacity(0.15),
                  boxShape: const NeumorphicBoxShape.stadium(),
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Important",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Les calculs et simulations ont une vocation éducative et informative. "
                  "Ils ne remplacent pas un avis médical.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  "En utilisant cette application, vous acceptez les conditions et la responsabilité associée.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NeumorphicButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: NeumorphicStyle(
                        color: Colors.green,
                        depth: 4,
                        intensity: 0.8,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: const Text(
                        "ACCEPTER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

