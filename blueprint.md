### **Blueprint du Projet : Glyc'Plus**

#### **1. Vue d'Ensemble**

**Objectif** : Créer une application mobile, moderne et intuitive pour aider les personnes diabétiques (en particulier de type 1) à gérer leur traitement. L'application se concentrera sur des calculs précis, une interface claire et une aide à la décision pour améliorer le contrôle glycémique au quotidien.

**Principes Clés** : Simplicité, Fiabilité, Éducation, Sécurité des données.

---

#### **2. Identité Visuelle et Design**

*   **Thème** : Moderne, épuré et rassurant. Utilisation de Material Design 3.
*   **Palette de Couleurs** :
    *   **Primaire** : Un bleu médical apaisant.
    *   **Secondaire** : Des touches de vert pour les succès et la santé.
    *   **Alertes** : Orange pour les hypoglycémies, rouge pour les hyperglycémies sévères.
*   **Typographie** : Police claire et lisible (par exemple, Google Fonts `Roboto` ou `Open Sans`).
*   **Iconographie** : Icônes Material claires et compréhensibles.

---

#### **3. Fonctionnalités Principales (MVP - Version 1.0)**

1.  **Authentification Sécurisée** : Connexion via email/mot de passe avec Firebase Auth.
2.  **Profil Utilisateur Personnalisé** :
    *   Saisie des ratios personnels : Facteur de Sensibilité à l'Insuline (ISF), Ratio Glucides/Insuline (ICR).
    *   Type d'insuline utilisée (basale et bolus).
    *   Objectifs glycémiques (cible, seuil hypo/hyper).
3.  **Calculateur de Bolus de Correction** :
    *   L'utilisateur entre sa glycémie actuelle.
    *   L'application calcule la dose d'insuline rapide nécessaire pour revenir à la cible, en se basant sur l'ISF du profil.
4.  **Calculateur de Bolus de Repas (à venir)** :
    *   L'utilisateur entre la quantité de glucides du repas.
    *   L'application calcule la dose d'insuline nécessaire en se basant sur l'ICR.

---

#### **4. Plan d'Action Initial**

1.  **Créer ce fichier `blueprint.md`** et le pousser sur GitHub.
2.  **Nettoyer le projet Flutter initial** pour repartir sur une base propre.
3.  **Intégrer Firebase** (Core, Auth, Firestore) dans le projet.
4.  **Développer l'écran d'authentification** (login/création de compte).
5.  **Développer l'écran du Profil Utilisateur**.
