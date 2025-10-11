import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // 🔹 Thème Neumorphic
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_neumorphic.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>(create: (_) => AuthService(FirebaseAuth.instance)),
        StreamProvider<User?>(
          create: (_) => AuthService(FirebaseAuth.instance).authStateChanges,
          initialData: null,
        ),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<StorageService>(create: (_) => StorageService()),
      ],

      // 🌗 Application avec thème Neumorphic global
      child: NeumorphicApp(
        debugShowCheckedModeBanner: false,
        title: 'Glyc+',

        // 🌈 Thème clair principal
        themeMode: ThemeMode.light,
        theme: const NeumorphicThemeData(
          baseColor: Color(0xFFE0E5EC), // Couleur de fond douce
          lightSource: LightSource.topLeft,
          depth: 6,
          intensity: 0.6,
          shadowLightColor: Color(0xFFFFFFFF),
          shadowDarkColor: Color(0xFFA3B1C6),
          defaultTextColor: Colors.black87,
        ),

        // 🌒 Thème sombre
        darkTheme: const NeumorphicThemeData(
          baseColor: Color(0xFF2C2C2C),
          lightSource: LightSource.topLeft,
          depth: 4,
          intensity: 0.8,
          shadowLightColor: Color(0xFF3A3A3A),
          shadowDarkColor: Color(0xFF1C1C1C),
          defaultTextColor: Colors.white70,
        ),

        // 🏠 Page principale selon état Firebase
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // 🔹 Utilisateur connecté → Dashboard Neumorphic
          return const DashboardNeumorphic();
        } else {
          // 🔸 Utilisateur non connecté → Page d'authentification
          return const AuthPage();
        }
      },
    );
  }
}
