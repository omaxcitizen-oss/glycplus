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
    _formKey.currentState?.reset();
    setState(() {
      _authMode = _authMode == AuthMode.connexion
          ? AuthMode.creationCompte
          : AuthMode.connexion;
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
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Une erreur inconnue est survenue.';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnecting = _authMode == AuthMode.connexion;

    // Common style for input fields
    final inputDecoration = InputDecoration(
      labelStyle: const TextStyle(color: Colors.grey),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2D9CDB), width: 2.0),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Page Title
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D9CDB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isConnecting ? "Bienvenue" : "Créez votre compte",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isConnecting
                        ? "Connectez-vous pour continuer"
                        : "Rejoignez-nous en quelques étapes",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Username Field (only for account creation)
                  if (!isConnecting) ...[
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF333333)),
                      decoration: inputDecoration.copyWith(
                        labelText: 'Pseudo',
                        prefixIcon: const Icon(Icons.person_outline,
                            color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un pseudo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Adresse e-mail',
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.grey),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          !value.contains('@') ||
                          !value.contains('.')) {
                        return 'Veuillez entrer une adresse email valide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xFF333333)),
                    decoration: inputDecoration.copyWith(
                      labelText: 'Mot de passe',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Remember Me Checkbox
                  if (isConnecting)
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (newValue) {
                            setState(() {
                              _rememberMe = newValue!;
                            });
                          },
                          activeColor: const Color(0xFF2D9CDB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Text('Se souvenir de moi',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700])),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Error Message Display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // Loading Indicator or Submit Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D9CDB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor:
                                const Color(0xFF2D9CDB).withOpacity(0.4),
                          ),
                          onPressed: _submit,
                          child: Text(
                            isConnecting ? 'Se connecter' : 'Créer un compte',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                  const SizedBox(height: 16),

                  // Switch Auth Mode Button
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      isConnecting
                          ? "Vous n'avez pas de compte ? S'inscrire"
                          : "Vous avez déjà un compte ? Se connecter",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
