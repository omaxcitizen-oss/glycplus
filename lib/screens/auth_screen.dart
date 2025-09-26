import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

import '../services/auth_service.dart';

enum AuthMode { connexion, creationCompte }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  AuthMode _authMode = AuthMode.connexion;
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.connexion ? AuthMode.creationCompte : AuthMode.connexion;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      if (_authMode == AuthMode.connexion) {
        await authService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _rememberMe,
        );
      } else {
        await authService.createUserWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
          _usernameController.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      if(mounted){
        setState(() {
          _errorMessage = e.message; // Display the Firebase error message
        });
      }
    } catch (e) {
       if(mounted){
        setState(() {
          _errorMessage = 'An unknown error occurred.';
        });
      }
    }

    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.connexion ? 'Connexion' : 'Créer un compte'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_authMode == AuthMode.creationCompte)
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Pseudo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un pseudo.';
                      }
                      return null;
                    },
                  ),
                if (_authMode == AuthMode.creationCompte) const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Veuillez entrer une adresse email valide.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères.';
                    }
                    return null;
                  },
                ),
                if (_authMode == AuthMode.connexion)
                  CheckboxListTile(
                    title: const Text('Se souvenir de moi'),
                    value: _rememberMe,
                    onChanged: (newValue) {
                      setState(() {
                        _rememberMe = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(_authMode == AuthMode.connexion ? 'Connexion' : 'Créer un compte'),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      _authMode == AuthMode.connexion ? 'Créer un compte' : 'Se connecter'),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
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
