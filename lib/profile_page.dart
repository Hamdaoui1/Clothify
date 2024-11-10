import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Importer la page de login
import 'new_clothing_page.dart';

class ProfilePage extends StatefulWidget {
  final String? ipAddress;
  final User user;

  const ProfilePage({Key? key, this.ipAddress, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userId = widget.user.uid;
    final userSnapshot = await FirebaseFirestore.instance.collection('client').doc(userId).get();
    final userData = userSnapshot.data() as Map<String, dynamic>;

    setState(() {
      _emailController.text = userData['email'] ?? '';
      _addressController.text = userData['adresse'] ?? '';
      _postalCodeController.text = userData['codePostal'] ?? '';
      _cityController.text = userData['ville'] ?? '';
     _birthdayController.text = "${userData['anniversaire']['J']}/${userData['anniversaire']['M']}/${userData['anniversaire']['A']}";
    });
  }

  void _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final userId = widget.user.uid;
      await FirebaseFirestore.instance.collection('client').doc(userId).update({
        'adresse': _addressController.text,
        'codePostal': _postalCodeController.text,
        'ville': _cityController.text,
        'anniversaire': {
          'J': _birthdayController.text.split('/')[0],
          'M': _birthdayController.text.split('/')[1],
          'A': _birthdayController.text.split('/')[2],
        },
      });
      if (_passwordController.text.isNotEmpty) {
        try {
          // Re-authenticate the user before updating the password
          final credential = EmailAuthProvider.credential(
            email: _emailController.text,
            password: _passwordController.text,
          );
          await widget.user.reauthenticateWithCredential(credential);
          await widget.user.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mot de passe mis à jour avec succès')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour du mot de passe: ${e.toString()}')));
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Données mises à jour avec succès')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Login',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        enabled: false, // Empêche toute modification
                        style: TextStyle(
                          color: Colors.grey, // Texte grisé pour indiquer qu'il est non modifiable
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _birthdayController,
                        decoration: InputDecoration(
                          labelText: 'Anniversaire (JJ/MM/AAAA)',
                          prefixIcon: Icon(Icons.cake),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Adresse',
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _postalCodeController,
                        decoration: InputDecoration(
                          labelText: 'Code Postal',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'Ville',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white70, // Couleur du bouton
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24), // Plus d'espace pour un look plus premium
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Coins plus arrondis
                  ),
                  elevation: 8, // Ombre pour un effet de profondeur
                ),
                icon: Icon(Icons.save, size: 20, color: Colors.blueAccent), // Icône avant le texte
                label: Text(
                  'Valider',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: _saveUserData,
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 8,
                ),
                icon: Icon(Icons.add, color: Colors.green),
                label: Text('Ajouter un nouveau vêtement',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    )),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewClothingPage()),
                  );
                },
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white70,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 8,
                ),
                icon: Icon(Icons.logout, color: Colors.redAccent),
                label: Text('Se déconnecter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.redAccent,
                    )),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
