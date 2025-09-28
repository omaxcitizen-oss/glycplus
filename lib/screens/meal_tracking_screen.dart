import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glycplus/services/firestore_service.dart';
import 'package:glycplus/models/meal.dart';
import 'package:provider/provider.dart';

class MealTrackingScreen extends StatefulWidget {
  const MealTrackingScreen({super.key});

  @override
  _MealTrackingScreenState createState() => _MealTrackingScreenState();
}

class _MealTrackingScreenState extends State<MealTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();
  final _carbsController = TextEditingController();
  Meal? _selectedMeal;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final user = Provider.of<User?>(context);

    if (user == null) {
      // Handle the case where the user is not logged in
      return const Scaffold(
        body: Center(
          child: Text("Veuillez vous connecter pour voir vos repas."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Repas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _foodController,
                    decoration: const InputDecoration(labelText: 'Aliment'),
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    decoration:
                        const InputDecoration(labelText: 'Glucides (g)'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? 'Champ requis' : null,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final meal = Meal(
                          id: _selectedMeal?.id,
                          food: _foodController.text,
                          carbohydrates: int.parse(_carbsController.text),
                          timestamp: _selectedMeal?.timestamp ?? DateTime.now(),
                        );
                        if (_selectedMeal != null) {
                          await firestoreService.updateMeal(user.uid, meal);
                        } else {
                          await firestoreService.addMeal(user.uid, meal);
                        }
                        _clearForm();
                      }
                    },
                    child: Text(
                        _selectedMeal != null ? 'Mettre à jour' : 'Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Meal>>(
                stream: firestoreService.getMealsStream(user.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final meals = snapshot.data!;
                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return ListTile(
                        title: Text(meal.food),
                        subtitle: Text('${meal.carbohydrates}g de glucides'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await firestoreService.deleteMeal(
                                user.uid, meal.id!);
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _selectedMeal = meal;
                            _foodController.text = meal.food;
                            _carbsController.text =
                                meal.carbohydrates.toString();
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _selectedMeal = null;
      _foodController.clear();
      _carbsController.clear();
    });
  }
}
