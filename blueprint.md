
# Blueprint: DiabeteApp

Ce document sert de feuille de route pour le développement de l'application de gestion du diabète. Il décrit l'architecture, les fonctionnalités et le design de l'application.

## 1. Vue d'ensemble

L'application vise à fournir un assistant complet pour les personnes atteintes de diabète, en particulier celles qui sont sous insulinothérapie. Elle offrira des outils pour le suivi de la glycémie, le calcul des doses d'insuline, le suivi des repas et une assistance pédagogique grâce à l'IA.

## 2. Architecture et Design

- **Framework**: Flutter
- **Backend & Base de données**: Firebase (Firestore, Firebase Auth)
- **State Management**: Provider
- **Design**: Material Design 3, avec une interface claire, moderne et accessible.
- **Navigation**: Un `DashboardScreen` central donnant accès aux différents modules (Correction, Repas, Profil, etc.).

## 3. Fonctionnalités Implémentées et Planifiées

### Étape 1 : Mise en Place du Profil Utilisateur (En cours)

L'objectif est de créer un formulaire de profil complet qui servira de base à tous les calculs de l'application.

#### **Modèle de Données (`UserProfile`)**
Un modèle `UserProfile` contiendra les informations suivantes :
- **Informations générales**: `age`, `poids`, `typeDiabete`, `uniteGlycemie` (mg/dL ou mmol/L).
- **Objectifs**: `glycemieCibleAJeun`, `glycemieCiblePostprandiale`.
- **Traitement Insuline**:
    - Marque et dose de l'insuline **basale** (lente).
    - Marque et dose de l'insuline **bolus** (rapide).
- **Ratios Personnalisés**:
    - `isf` (Facteur de Sensibilité à l'Insuline), modifiable.
    - `icr` (Ratio Insuline/Glucides), modifiable.

#### **Écran Profil (`profile_screen.dart`)**
- Formulaire structuré pour saisir toutes les données du `UserProfile`.
- **Calculs automatiques (pré-remplissage)** :
    - `doseTotale` = dose basale + dose bolus.
    - `isf` pré-rempli avec la formule `1800 / doseTotale`.
    - `icr` pré-rempli avec la formule `500 / doseTotale`.
- **Dropdowns pour les Insulines**:
    - **Basale**: Lantus, Tresiba, Levemir, Toujeo, NPH.
    - **Bolus**: NovoRapid, Humalog, Apidra, Fiasp.
- **Bouton "Calculer mon ISF empirique"**:
    - Ouvre un dialogue pour saisir 3 valeurs : glycémie avant, glycémie après, et dose administrée.
    - Calcule et affiche l'ISF empirique avec un message explicatif.
- **Sauvegarde**: Les données du profil seront sauvegardées dans une collection `users` sur Firestore, liée à l'UID de l'utilisateur.

#### **Assistance IA Pédagogique**
- Des messages explicatifs seront générés et affichés sous les champs ISF et ICR pour aider l'utilisateur à comprendre leur signification.

### Étape 2 : Module de Correction Glycémique

- **Flux**:
    1. L'utilisateur accède à l'écran "Correction Glycémie".
    2. Le système vérifie si le profil (et notamment l'ISF) est rempli.
    3. **Si non**: Affiche un message invitant à remplir le profil, avec un bouton de redirection.
    4. **Si oui**: Affiche le formulaire de correction avec les champs "Glycémie actuelle" et "Glycémie cible".
- **Calcul**: La dose de correction sera calculée avec la formule : `(Glycémie actuelle - Glycémie cible) / ISF (personnalisé)`.
- **Gestion Hyper/Hypoglycémie**: Des conseils spécifiques seront affichés en fonction du résultat.

### Étape 3 : Module de Suivi des Repas (À venir)

- Calcul du bolus de repas basé sur l'ICR de l'utilisateur.
- Base de données alimentaire pour estimer les glucides.

### Étape 4 : Historique et Rapports (À venir)

- Graphiques et listes pour visualiser l'historique des glycémies, des doses d'insuline et des repas.
- Export des données (CSV/PDF).

