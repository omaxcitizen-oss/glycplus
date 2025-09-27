import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glycplus/screens/history_screen.dart';
import 'package:glycplus/screens/meal_tracking_screen.dart';
import 'package:glycplus/screens/auth_screen.dart';
import 'package:glycplus/screens/glucose_management_screen.dart';
import 'package:glycplus/screens/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Utilisation d'un message d'accueil plus personnalisé et sécurisé
    final welcomeMessage = user?.displayName?.isNotEmpty == true
        ? 'Bienvenue, ${user!.displayName}!'
        : (user?.email?.isNotEmpty == true ? 'Bienvenue, ${user!.email}!' : 'Bienvenue !');

    return Scaffold(
      backgroundColor: Colors.grey[50], // Un fond légèrement grisé pour un look plus doux
      appBar: AppBar(
        title: Text(
          'Tableau de Bord',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
            tooltip: 'Mon Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.onPrimary),
            tooltip: 'Déconnexion',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Assurer que la redirection se fait correctement sans pouvoir revenir en arrière
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 16),
          Text(
            welcomeMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            "Prêt à mieux gérer votre diabète ?",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 32),

          // --- NOUVELLES CARTES DE NAVIGATION ---
          _buildDashboardCard(
            context,
            title: 'Calculer un Bolus',
            subtitle: 'Correction ou repas',
            icon: Icons.calculate_outlined,
            color: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const GlucoseManagementScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Suivi des Repas',
            subtitle: 'Enregistrer un aliment',
            icon: Icons.restaurant_menu_outlined,
            color: Theme.of(context).colorScheme.secondary,
            onTap: () {
              // NAVIGATION ACTIVÉE
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MealTrackingScreen()));
            },
          ),
          const SizedBox(height: 16),
          _buildDashboardCard(
            context,
            title: 'Mon Historique',
            subtitle: 'Consulter vos données',
            icon: Icons.bar_chart_outlined,
            color: const Color(0xFFF2994A), // Une couleur orange pour la diversité
            onTap: () {
              // NAVIGATION ACTIVÉE
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET DE CARTE AMÉLIORÉ ---
  Widget _buildDashboardCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 48.0, color: color),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
