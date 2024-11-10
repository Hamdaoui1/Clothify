# Clothify - Application de Gestion de Vêtements

Bienvenue sur Clothify, une application mobile Flutter pour la gestion de vêtements. Cette application permet d'ajouter des vêtements, de les classifier, et de les gérer au sein d'une base de données Firebase.

## Installation

Pour installer et exécuter le projet localement, suivez les étapes ci-dessous :

### 1. Cloner le dépôt

Clonez ce répertoire en utilisant la commande :
```sh
https://github.com/Hamdaoui1/Clothify.git
```

### 2. Dépendances

Après avoir cloné le projet, assurez-vous de récupérer les dépendances requises dans le fichier `pubspec.yaml` en utilisant la commande suivante :
```sh
flutter pub get
```
Cette commande téléchargera toutes les dépendances nécessaires pour l'application.

### 3. Démarrer l'API Locale

L'application utilise une API locale pour classifier les vêtements et détecter leur catégorie à partir d'une image. Pour démarrer cette API, vous devez exécuter un conteneur Docker localement. Assurez-vous que Docker est installé sur votre machine, puis lancez l'image suivante :

```sh
docker run -p 8080:5000 hamd1/clothing_classifier:latest
```

Cette commande démarrera le serveur de classification de vêtements sur le port 8080.

Le code source de cette API est disponible à l'adresse suivante : [flask_clothing_classifier](https://github.com/Hamdaoui1/flask_clothing_classifier).

### 4. Lancer l'Application Flutter

Maintenant que tout est prêt, vous pouvez lancer l'application Flutter sur votre émulateur ou votre appareil :
```sh
flutter run
```

## Fonctionnalités de l'Application

- **Ajout de Vêtements** : Les utilisateurs peuvent ajouter des articles de vêtements avec des informations telles que le titre, la taille, la marque, le prix, et la photo.
- **Classification Automatique** : L'API locale détecte automatiquement la catégorie d'un vêtement à partir de l'image fournie.
- **Panier Utilisateur** : Possibilité d'ajouter des articles au panier, de les modifier ou de les supprimer.
- **Authentification avec Firebase** : Gestion des utilisateurs avec Firebase Authentication.

## Prérequis

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installé sur votre machine.
- [Docker](https://www.docker.com/get-started) installé pour démarrer l'API locale.
- Accès à Internet pour télécharger les dépendances.

## Tester l'Application

Pour tester l'application, vous pouvez utiliser les comptes de test suivants :

- **Email** : test_1@hamza1.com
  **Mot de passe** : 123456

- **Email** : test_2@hamza1.com
  **Mot de passe** : 123456

## Crédits

L'application a été développée par [Hamza Hamdaoui](https://github.com/Hamdaoui1).

Le serveur d'API de classification de vêtements est également créé et maintenu par Hamza Hamdaoui. Vous pouvez en apprendre davantage en visitant le [dépôt GitHub du serveur](https://github.com/Hamdaoui1/flask_clothing_classifier).

## Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## Questions ?
Si vous avez des questions ou besoin d'aide pour installer ou utiliser l'application, n'hésitez pas à me contacter 
1@hamza.com.

