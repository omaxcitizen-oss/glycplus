import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/meal.dart';
import '../services/firestore_service.dart';

class MealTrackingScreen extends StatefulWidget {
  const MealTrackingScreen({super.key});

  @override
  State<MealTrackingScreen> createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  // Dialog to Add/Edit a Meal
  Future<void> _showMealDialog({Meal? meal}) async {
    final formKey = GlobalKey<FormState>();
    String? description = meal?.description;
    final isEditing = meal != null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Modifier le Repas' : 'Ajouter un Repas'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: description ?? '',
              decoration: const InputDecoration(labelText: 'Description du Repas', hintText: 'Ex: Pâtes au poulet'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une description.';
                }
                return null;
              },
              onSaved: (value) {
                description = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final user = Provider.of<User?>(context, listen: false);
                  final firestoreService = Provider.of<FirestoreService>(context, listen: false);

                  if (user == null) return;

                  if (isEditing) {
                    final updatedMeal = Meal(
                      id: meal.id,
                      description: description!,
                      timestamp: meal.timestamp,
                      userId: user.uid,
                    );
                    await firestoreService.updateMeal(updatedMeal);
                  } else {
                    final newMeal = Meal(
                      description: description!,
                      timestamp: DateTime.now(),
                      userId: user.uid,
                    );
                    await firestoreService.addMeal(newMeal);
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Mettre à jour' : 'Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  // Dialog to confirm deletion
  Future<void> _showDeleteConfirmationDialog(String mealId) async {
    final user = Provider.of<User?>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la Suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce repas ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (user != null) {
                  await firestoreService.deleteMeal(user.uid, mealId);
                }
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Repas'),
      ),
      body: user == null
          ? const Center(child: Text("Veuillez vous connecter."))
          : StreamBuilder<List<Meal>>(
              stream: firestoreService.getMealsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun repas enregistré. Appuyez sur + pour en ajouter un.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final meals = snapshot.data!;

                return ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return _buildMealCard(meal);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMealDialog(),
        tooltip: 'Ajouter un repas',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(meal.description, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat.yMMMd().add_jm().format(meal.timestamp)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
              onPressed: () => _showMealDialog(meal: meal),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _showDeleteConfirmationDialog(meal.id!),
            ),
          ],
        ),
      ),
    );
  }
}
