# 🏋️ FitTrack - Votre Partenaire Santé & Fitness (Version Universitaire)

<div align="center">
  <img src="public/app/onboarding/1.jpg" width="200" style="border-radius: 10px; margin: 5px;">
  <img src="public/app/home/home-populated.jpg" width="200" style="border-radius: 10px; margin: 5px;">
  <img src="public/app/dark-mode/home.jpg" width="200" style="border-radius: 10px; margin: 5px;">
  <img src="public/app/food/full-day.jpg" width="200" style="border-radius: 10px; margin: 5px;">
</div>

<br>

<div align="center">
  <p><strong>Une application Flutter d'avant-garde intégrant une architecture MVC, la gestion d'état réactive via Provider, et des interactions asynchrones sécurisées avec une API REST.</strong></p>
</div>

---

## 📖 Sommaire

1. [Présentation du Projet](#-présentation-du-projet)
2. [Interface Utilisateur & Expérience (UX/UI)](#-interface-utilisateur--expérience-uxui)
3. [Fonctionnalités Détaillées (Galerie de Captures)](#-fonctionnalités-détaillées-et-démonstration-visuelle)
   - [Onboarding & Inscription](#1-onboarding--inscription-multi-étapes)
   - [Tableau de Bord & Profil](#2-tableau-de-bord-dashboard--profil)
   - [Nutrition & Planification des Repas](#3-nutrition--planification-des-repas)
   - [Activités Sportives & Entraînements](#4-activités-sportives--entraînements)
   - [Suivi du Poids & Graphiques](#5-suivi-du-poids--graphiques-fl_chart)
   - [Évolution Corporelle & Appareil Photo](#6-évolution-corporelle--appareil-photo)
4. [Architecture Logicielle & Design Patterns](#-architecture-logicielle--design-patterns)
5. [Modélisation des Données & API](#-modélisation-des-données--api)
6. [Instructions d'Installation et d'Évaluation](#-instructions-dinstallation-et-dévaluation)

---

## 🎯 Présentation du Projet

**FitTrack** a été conçu pour répondre à la problématique de la fragmentation des applications de santé. L'objectif universitaire de ce projet était de construire un écosystème mobile **complet et robuste** réunissant : le calcul biométrique, la journalisation diététique, l'historique sportif, et l'analyse visuelle des progrès.

Le projet a fait l'objet d'une rigueur particulière concernant la qualité du code (Clean Code), la réutilisabilité des composants UI (`widgets/`), et la fluidité des états asynchrones gérés par `ChangeNotifier`.

---

## 🎨 Interface Utilisateur & Expérience (UX/UI)

Le design de l'application a été élaboré pour rivaliser avec les standards de l'industrie (Material Design 3). 
- **Mode Sombre Natif** : L'application bascule automatiquement ou manuellement entre un thème clair épuré et un thème sombre profond (Dark Mode) économiseur d'énergie.
- **Micro-interactions** : Utilisation d'animations implicites, de transitions partagées, et de retours haptiques pour une immersion totale.
- **Typographie** : Combinaison réfléchie des polices `Poppins` (Titres) et `Inter` (Corps de texte) via Google Fonts.

---

## 📱 Fonctionnalités Détaillées et Démonstration Visuelle

### 1. Onboarding & Inscription Multi-Étapes
Un flux de bienvenue interactif captant l'attention de l'utilisateur, suivi d'une inscription biométrique précise. L'application calcule immédiatement l'objectif calorique et l'IMC en fonction des données saisies (poids, taille, date de naissance, genre, objectif final).

<div align="center">
  <img src="public/app/onboarding/2.jpg" width="180">
  <img src="public/app/onboarding/3.jpg" width="180">
  <img src="public/app/register-steps/step1-full.jpg" width="180">
  <img src="public/app/register-steps/step2-age-calender.jpg" width="180">
  <img src="public/app/register-steps/step3-select-weight-loss-goal.jpg" width="180">
</div>

### 2. Tableau de Bord (Dashboard) & Profil
Le centre de contrôle. Il agrège les données issues de tous les autres modules (Repas, Sport, Poids). Il propose des recommandations intelligentes et affiche le statut calorique en temps réel.

<div align="center">
  <img src="public/app/home/first-login.jpg" width="180">
  <img src="public/app/home/home-populated.jpg" width="180">
  <img src="public/app/dark-mode/home.jpg" width="180">
  <img src="public/app/profile/1.jpg" width="180">
  <img src="public/app/dark-mode/profile.jpg" width="180">
</div>

### 3. Nutrition & Planification des Repas
L'un des moteurs les plus complexes de l'application. Les utilisateurs peuvent fouiller dans une vaste base de données d'ingrédients ou sélectionner des "Ready Meals" (Recettes complètes). La barre de progression colorée (CalorieProgressBar) se met à jour réactivement.

<div align="center">
  <img src="public/app/food/today-meals-empty-state.jpg" width="180">
  <img src="public/app/food/logging-food-individual-for-lunch.jpg" width="180">
  <img src="public/app/food/ready-meal.jpg" width="180">
  <img src="public/app/food/full-day.jpg" width="180">
  <img src="public/app/dark-mode/meals-page.jpg" width="180">
</div>

### 4. Activités Sportives & Entraînements
Une bibliothèque d'exercices filtrable par texte. Lorsqu'un utilisateur sélectionne un exercice, un `BottomSheet` interactif calcule instantanément les calories brûlées selon le nombre de minutes entrées (via la variable scalaire de l'exercice).

<div align="center">
  <img src="public/app/exercises/list.jpg" width="180">
  <img src="public/app/exercises/exercise-details-to-save-workout.jpg" width="180">
  <img src="public/app/exercises/message-confirming-workout-saved.jpg" width="180">
  <img src="public/app/exercises/history.jpg" width="180">
</div>

### 5. Suivi du Poids & Graphiques (`fl_chart`)
Un affichage analytique reposant sur des courbes de Bézier pour visualiser les fluctuations corporelles. Les intervalles (30 jours, 3 mois, 6 mois) sont recalculés dynamiquement pour lisser le graphique.

<div align="center">
  <img src="public/app/weight/record-a-weight.jpg" width="180">
  <img src="public/app/weight/stats-30-days.jpg" width="180">
  <img src="public/app/weight/stats-6months.jpg" width="180">
  <img src="public/app/dark-mode/weight-stats.jpg" width="180">
</div>

### 6. Évolution Corporelle & Appareil Photo
La prise de conscience corporelle est renforcée par la capture d'images avant/après. Ce module interagit directement avec le hardware du téléphone (Caméra et Galerie) via `image_picker`. Les images sont converties, optimisées et enregistrées de manière permanente dans le `path_provider` (Directory de l'OS).

<div align="center">
  <img src="public/app/progress/details.jpg" width="180">
  <img src="public/app/progress/save-progress.jpg" width="180">
  <img src="public/app/progress/5.jpg" width="180">
  <img src="public/app/dark-mode/progress-page.jpg" width="180">
</div>

---

## 🏗️ Architecture Logicielle & Design Patterns

L'application respecte les principes **SOLID** et est structurée en respectant un pattern de conception hautement modulable pour garantir scalabilité et maintenabilité.

### L'arbre des dépendances structurelles :
1. **Couche Données (Models)** : Des classes typées fortement (`User`, `Food`, `ActivityLog`) disposant de méthodes de sérialisation / désérialisation JSON (`fromJson`, `toJson`) avec "Null Safety" stricte.
2. **Couche Service (Services)** : `ApiService` est un singleton gérant la communication réseau asynchrone (REST API) avec un algorithme de Timeout et d'interception d'exceptions. `PreferencesService` gère les variables de session.
3. **Couche Contrôle (Controllers)** : Agit comme le pont (ViewModel). Les classes étendent `ChangeNotifier` (`Provider`). Elles injectent l'`ApiService` par constructeur, encapsulent la logique métier complexe (calcul des totaux, filtrage de recherche) et invoquent `notifyListeners()` pour ordonner la mise à jour des widgets.
4. **Couche Présentation (Views)** : UI pure et widgets sans état complexe. Ils écoutent passivement les Controllers (`context.watch()`) et s'adaptent selon l'état actuel de la donnée (loading, succès, erreur).

---

## 🗄️ Modélisation des Données & API

Le projet a migré d'une infrastructure SQLite rigide vers une architecture **Client-Serveur** RESTful en utilisant `json-server`. 
L'application effectue des requêtes HTTP asynchrones (GET, POST, PUT, DELETE).

### Points de terminaison implémentés (`db.json`) :
- `/users` : Gestion des profils, mot de passe hashé, et tokens de session logique.
- `/exercises` : Catalogue des entraînements.
- `/foods` & `/ready_meals` : Bases de données nutritionnelles.
- `/meal_logs` : Historique croisé liant l'utilisateur, l'aliment, le type de repas et la date.
- `/activity_logs` : Historique des sessions d'entraînement.
- `/weight_entries` : Entrées historiques du poids.
- `/progress_comparisons` : Référencement des chemins d'accès locaux (`file:///`) des photos avant/après.

*Sécurité OS : Les configurations Android ont été modifiées (`AndroidManifest.xml`) avec l'autorisation `INTERNET` et `usesCleartextTraffic="true"` pour permettre les appels HTTP vers les adresses IP du serveur local.*

---

## ⚙️ Instructions d'Installation et d'Évaluation

Pour évaluer et exécuter cette application dans les meilleures conditions :

### Prérequis
- SDK Flutter (v3.12.0 ou supérieure)
- Node.js (pour exécuter l'API simulée)

### Étapes de déploiement

1. **Cloner le projet et installer les dépendances Flutter :**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Démarrer le serveur API (Obligatoire) :**
   Le fichier de données `db.json` contient des milliers d'entrées pré-générées pour simuler une application en production. Lancez le serveur local :
   ```bash
   npx json-server --watch db.json --port 3000
   ```
   > ⚠️ **Important pour les jurys/évaluateurs** : Si vous testez l'application sur un **téléphone physique**, vous devez modifier le fichier `lib/services/api_service.dart` pour y inscrire l'adresse IP locale Wi-Fi de la machine hébergeant le `json-server` (ex: `192.168.1.X`), sinon le téléphone ne pourra pas communiquer avec l'API.

3. **Lancer la compilation et l'exécution :**
   ```bash
   flutter run
   ```

---
<div align="center">
  <i>Développé dans le cadre d'un projet universitaire exigeant. Démontre l'expertise en développement mobile cross-platform, l'ingénierie logicielle et le design d'interface (UI/UX).</i>
</div>
