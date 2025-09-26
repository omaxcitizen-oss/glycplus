
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'glucose_management_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = context.watch<User?>();
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tableau de Bord',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            tooltip: 'Profil',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<UserProfile?>(
              stream: firestoreService.getUserProfileStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Créez un profil pour commencer.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 20),
                          ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())), child: const Text('Créer mon profil'))
                        ],
                      ),
                    )
                  );
                }

                final userProfile = snapshot.data!;
                final pseudo = userProfile.pseudo ?? 'cher utilisateur';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        'Bienvenue $pseudo 👋',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Prêt à mieux gérer votre diabète ?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(20.0),
                        childAspectRatio: 0.9, // Adjusted for a slightly taller card
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: <Widget>[
                          _buildDashboardCard(
                            context,
                            title: 'Correction Glycémie',
                            icon: Icons.opacity_outlined, // Modern icon
                            color: const Color(0xFFAEE2FF), // Bleu ciel doux
                            iconColor: const Color(0xFF00796B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GlucoseManagementScreen()),
                              );
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            title: 'Suivi des Repas',
                            icon: Icons.pie_chart_outline, // Modern icon
                            color: const Color(0xFFC8F4C4), // Vert menthe clair
                            iconColor: const Color(0xFFF57C00),
                            onTap: () {
                              // TODO: Navigate to Meal Tracking Screen
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            title: 'Historique',
                            icon: Icons.bar_chart_outlined, // Modern icon
                            color: const Color(0xFFFFD8BE), // Peche pastel
                            iconColor: const Color(0xFF3949AB),
                            onTap: () {
                              // TODO: Navigate to History Screen
                            },
                          ),
                          _buildDashboardCard(
                            context,
                            title: 'Exporter Données',
                            icon: Icons.share_outlined, // Modern icon
                            color: const Color(0xFFE4D9FF), // Lavande lumineuse
                            iconColor: const Color(0xFFFBC02D),
                            onTap: () {
                              // TODO: Implement Export
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required Color iconColor,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 48.0, color: iconColor),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: iconColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
