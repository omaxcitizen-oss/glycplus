
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs moderne et conviviale
    const primaryColor = Color(0xFF6A5AE0); // Un bleu-violet vibrant
    const secondaryColor = Color(0xFF24D8A2); // Un vert menthe frais
    const backgroundColor = Color(0xFFF5F5F7);
    const textColor = Color(0xFF333333);
    const textFieldBackgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Bienvenue",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Connectez-vous à votre compte',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 40),
                // --- Champ Email ---
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: primaryColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- Champ Mot de passe ---
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: primaryColor),
                    filled: true,
                    fillColor: textFieldBackgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: primaryColor, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // --- Bouton Se connecter ---
                ElevatedButton(
                  onPressed: () {
                    // logique Firebase auth (inchangée)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: Text(
                    "Se connecter",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- Bouton Créer un compte ---
                ElevatedButton(
                  onPressed: () {
                    // logique inscription (inchangée)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                    shadowColor: secondaryColor.withOpacity(0.4),
                  ),
                  child: Text(
                    "Créer un compte",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
