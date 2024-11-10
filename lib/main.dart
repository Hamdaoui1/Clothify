// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importer les options générées par FlutterFire CLI
import 'login_page.dart'; // Importer la page de login
import 'home_page.dart'; // Importer la page d'accueil
import 'package:firebase_auth/firebase_auth.dart';
import 'package:network_info_plus/network_info_plus.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _handleAuthState(), // Utiliser la page de login ou d'accueil en fonction de l'authentification
    );
  }

  Widget _handleAuthState() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomePageWithIP(user: snapshot.data!); // Passer l'objet User avec IP
        } else {
          return const LoginPage();
        }
      },
    );
  }

  Future<String?> _getLocalIpAddress() async {
    final info = NetworkInfo();
    String? ipAddress = await info.getWifiIP();
    return ipAddress;
  }
}

class HomePageWithIP extends StatelessWidget {
  final User user;

  const HomePageWithIP({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: MyApp()._getLocalIpAddress(), // Récupérer l'adresse IP locale
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Page d\'Accueil'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Page d\'Accueil'),
            ),
            body: Center(child: Text('Erreur: ${snapshot.error}')),
          );
        }

        String? ipAddress = snapshot.data;

        return HomePage(user: user, ipAddress: ipAddress); // Passer l'IP à la HomePage
      },
    );
  }
}