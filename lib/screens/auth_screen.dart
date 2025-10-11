import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'dashboard_neumorphic.dart';
import 'sign_up_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌆 Image de fond
          Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.4)),

          // 🌙 Contenu principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔝 Logo en haut
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 90 * 3, // ×3 pour agrandir
                        ),
                      ),

                      // 📝 Texte de présentation
                      Column(
                        children: const [
                          SizedBox(height: 10),
                          Text(
                            "Découvrez comment les glucides influencent votre glycémie et votre énergie.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              height: 1.5,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "GLYC+ vous aide à mieux comprendre et gérer votre métabolisme au quotidien.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 🟡 Bouton + texte bas
                      Column(
                        children: [
                          const SizedBox(height: 30),
                          NeumorphicButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DashboardNeumorphic()),
                              );
                            },
                            style: NeumorphicStyle(
                              color: const Color(0xFFFFC107), // Jaune tournesol
                              depth: 0, // supprime l'ombre
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(25),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                            child: SizedBox(
                              width: double.infinity, // texte centré
                              child: Text(
                                "COMMENCER",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Vous avez déjà un compte ? ",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                                  );
                                },
                                child: const Text(
                                  "Se connecter",
                                  style: TextStyle(
                                    color: Color(0xFF00BFFF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
