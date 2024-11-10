// new_clothing_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewClothingPage extends StatefulWidget {
  @override
  _NewClothingPageState createState() => _NewClothingPageState();
}


class _NewClothingPageState extends State<NewClothingPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _category;
  String? _selectedSize;
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _classifyImage(_imageFile!);
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _category = null;
    });
  }

  Future<void> _classifyImage(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8080/classify'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        if (responseBody == "autres") {
          setState(() {
            _imageFile = null;
            _category = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("L'article n'a pas été détecté sur la photo. Veuillez prendre une photo plus claire de votre article.")),
          );
        } else {
          setState(() {
            _category = responseBody;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Catégorie détectée: $_category')),
          );
        }
      } else {
        setState(() {
          _imageFile = null;
          _category = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez choisir un format d\'image correct.')),
        );
      }
    } catch (e) {
      setState(() {
        _imageFile = null;
        _category = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _addClothing() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez sélectionner une image.')),
        );
        return;
      }

      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Catégorie non détectée. Veuillez réessayer.')),
        );
        return;
      }

      try {
        final imagePath = 'images/\${DateTime.now().millisecondsSinceEpoch}.png';
        final ref = firebase_storage.FirebaseStorage.instance.ref().child(imagePath);
        await ref.putFile(_imageFile!);
        final imageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('vetements').add({
          'TT': _titleController.text,
          'T': _selectedSize,
          'M': _brandController.text,
          'P': double.parse(_priceController.text),
          'URL': imageUrl,
          'C': _category,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vêtement ajouté avec succès.')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout du vêtement : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un nouveau vêtement'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Titre',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un titre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSize,
                    items: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].map((String size) {
                      return DropdownMenuItem<String>(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSize = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Taille',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez sélectionner une taille';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: 'Marque',
                      prefixIcon: Icon(Icons.branding_watermark),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une marque';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Prix',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un prix';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Veuillez entrer un nombre valide';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _imageFile == null
                      ? Text('Aucune image sélectionnée')
                      : Image.file(
                    _imageFile!,
                    height: 150,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _imageFile == null ? _pickImage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white70,
                          elevation: 8,
                        ),
                        child: Text(_imageFile == null ? 'Sélectionner une image' : 'Modifier l\'image'),
                      ),
                      if (_imageFile != null)
                        IconButton(
                          icon: Icon(Icons.clear, color: Colors.red),
                          onPressed: _removeImage,
                        ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  _category != null
                      ? Text(
                    'Catégorie détectée: $_category',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                      : Text('Catégorie: Non détectée'),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _addClothing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white70,
                      elevation: 8,
                    ),
                    child: Text('Valider'),
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
