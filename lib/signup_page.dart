// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importer Firestore
import 'package:flutter/services.dart';
import 'home_page.dart'; // Importer la page d'accueil
import 'login_page.dart'; // Importer la page de connexion pour une meilleure gestion de la déconnexion

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String? _selectedGender;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signup() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String age = _ageController.text;
    String sex = _selectedGender ?? '';
    String email = _emailController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String address = _addressController.text;
    String postalCode = _postalCodeController.text;
    String city = _cityController.text;
    String day = _dayController.text;
    String month = _monthController.text;
    String year = _yearController.text;

    if (email.isNotEmpty && password.isNotEmpty && password == confirmPassword) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Ajouter les informations utilisateur dans Firestore
        await _firestore.collection('client').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'sex': sex,
          'email': email,
          'adresse': address,
          'codePostal': postalCode,
          'ville': city,
          'anniversaire': {
            'J': day, // Jour
            'M': month, // Mois
            'A': year, // Année
          }
        }).then((value) {
          // Inscription réussie, redirection vers la page d'accueil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(user: userCredential.user!)),
          );
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Erreur lors de l'inscription"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur inattendue : $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez vérifier les informations et les mots de passe doivent correspondre'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page d'Inscription"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Créez votre compte',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              _buildTextField(_firstNameController, 'Prénom', Icons.person),
              SizedBox(height: 16.0),
              _buildTextField(_lastNameController, 'Nom', Icons.person_outline),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_ageController, 'Âge', Icons.cake, inputType: TextInputType.number),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    flex: 3,
                    child: _buildGenderDropdown(),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildTextField(_addressController, 'Adresse', Icons.location_on),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_postalCodeController, 'Code Postal', Icons.local_post_office, inputType: TextInputType.number),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: _buildTextField(_cityController, 'Ville', Icons.location_city),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              _buildBirthdayInput(),
              SizedBox(height: 16.0),
              _buildTextField(_emailController, 'Email', Icons.email, inputType: TextInputType.emailAddress),
              SizedBox(height: 16.0),
              _buildTextField(_passwordController, 'Mot de passe', Icons.lock, isPassword: true),
              SizedBox(height: 16.0),
              _buildTextField(_confirmPasswordController, 'Confirmez le mot de passe', Icons.lock_outline, isPassword: true),
              SizedBox(height: 24.0),
              ElevatedButton.icon(
                onPressed: _signup,
                icon: Icon(Icons.app_registration, color: Colors.white),
                label: Text('Inscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white60,
                  foregroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text, bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: inputType,
      obscureText: isPassword,
      inputFormatters: inputType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sexe',
        prefixIcon: Icon(Icons.wc, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        //contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
      value: _selectedGender,
      items: [
        'Masculin',
        'Féminin',
        'Non-binaire',
        'Genre fluide',
        'Préfère ne pas dire'
      ].map((label) => DropdownMenuItem(
        child: Text(label),
        value: label,
      )).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGender = value;
        });
      },
    );
  }

  Widget _buildBirthdayInput() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(_dayController, 'Jour', Icons.calendar_today, inputType: TextInputType.number),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: _buildTextField(_monthController, 'Mois', Icons.calendar_today, inputType: TextInputType.number),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: _buildTextField(_yearController, 'Année', Icons.calendar_today, inputType: TextInputType.number),
        ),
      ],
    );
  }
}
