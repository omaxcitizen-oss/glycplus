# Blueprint de l'Application GlucoGuard

## Aperçu

GlucoGuard est une application mobile conçue pour aider les utilisateurs à suivre et à gérer leur taux de glucose. L'application s'intègre à Firebase pour l'authentification des utilisateurs, le stockage des données et d'autres services back-end.

## Fonctionnalités Implémentées

*   **Nettoyage du Projet :**
    *   Suppression du dossier `glycplus` dupliqué pour une structure de projet propre.
*   **Intégration de Firebase :**
    *   Ajout des dépendances Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`).
    *   Configuration de l'initialisation de Firebase dans `lib/main.dart`.
    *   Vérification de la présence du fichier de configuration Android (`google-services.json`).
*   **Thème et Style :**
    *   Ajout des dépendances `google_fonts` et `provider`.
    *   Mise en place d'un système de thème moderne (Material 3) avec `ColorScheme.fromSeed`.
    *   Définition de thèmes clair et sombre avec une typographie personnalisée via `google_fonts`.
    *   Implémentation d'un `ThemeProvider` pour permettre le changement de thème.
*   **Authentification :**
    *   Création d'un écran d'authentification (`auth_screen.dart`) avec des champs pour l'email et le mot de passe, et la logique pour basculer entre la connexion et l'inscription.
    *   Implémentation d'un `AuthService` pour gérer la communication avec Firebase Auth, y compris les méthodes `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, et `signOut`.
    *   Création d'un écran de tableau de bord (`dashboard_screen.dart`) accessible après la connexion, affichant un message de bienvenue et un bouton de déconnexion.
    *   Mise en place d'un `AuthWrapper` pour gérer la redirection de l'utilisateur en fonction de son état d'authentification.

## Plan d'Action Actuel

*   **Améliorer l'interface utilisateur (UI) du tableau de bord :**
    *   Concevoir un tableau de bord plus informatif et visuellement attrayant pour afficher les données de glucose.
*   **Mettre en place la Logique Métier pour le Glucose :**
    *   Développer les fonctionnalités de lecture, d'écriture, de mise à jour et de suppression des données de glucose dans `firestore_service.dart`.
    *   Créer un modèle de données `GlucoseReading` pour représenter les mesures de glucose.
*   **Ajouter des fonctionnalités de suivi :**
    *   Implémenter la saisie manuelle des données de glucose.
    *   Afficher un historique des mesures de glucose sous forme de liste ou de graphique.

