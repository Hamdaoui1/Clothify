// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_page.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({Key? key}) : super(key: key);

  void addToCart(BuildContext context, String userId, Map<String, dynamic> itemData) async {
    final cartRef = FirebaseFirestore.instance.collection('panier').doc(userId);
    final cartSnapshot = await cartRef.get();

    if (cartSnapshot.exists) {
      final cartData = cartSnapshot.data() as Map<String, dynamic>;
      if (cartData.containsKey(itemData['TT'])) {
        // Si l'article existe déjà, augmenter la quantité
        int currentQuantity = cartData[itemData['TT']]['quantity'];
        cartRef.update({
          '${itemData['TT']}.quantity': currentQuantity + 1,
        });
      } else {
        // Ajouter un nouvel article
        cartRef.update({
          itemData['TT']: {
            'M': itemData['M'],
            'P': itemData['P'],
            'T': itemData['T'],
            'URL': itemData['URL'],
            'quantity': 1,
          },
        });
      }
    } else {
      // Créer un nouveau panier avec le premier article
      cartRef.set({
        itemData['TT']: {
          'M': itemData['M'],
          'P': itemData['P'],
          'T': itemData['T'],
          'URL': itemData['URL'],
          'quantity': 1,
        },
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Article ajouté au panier')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('vetements').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun vêtement disponible'));
        }

        List<Map<String, dynamic>> clothingData = snapshot.data!.docs.map((document) {
          return document.data() as Map<String, dynamic>;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            itemCount: clothingData.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Deux articles par ligne
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.8, // Ratio de l'image pour adapter la hauteur des cartes
            ),
            itemBuilder: (context, index) {
              final data = clothingData[index];
              if (data.containsKey('M') && data.containsKey('P') && data.containsKey('T') && data.containsKey('URL')) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailPage(itemData: data, userId: FirebaseAuth.instance.currentUser!.uid),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
                            child: Image.network(
                              data['URL'],
                              fit: BoxFit.cover,
                              height: 200,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['M'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Taille: ${data['T']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Prix: ${data['P']} €',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Certaines données sont manquantes pour cet article',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
//      _birthdayController.text = "${userData['anniversaire']['J']}/${userData['anniversaire']['M']}/${userData['anniversaire']['A']}";
