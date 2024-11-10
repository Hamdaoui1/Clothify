// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  void _decreaseQuantity(BuildContext context, String userId, String itemKey, int currentQuantity) {
    final cartRef = FirebaseFirestore.instance.collection('panier').doc(userId);
    if (currentQuantity > 1) {
      cartRef.update({
        '$itemKey.quantity': currentQuantity - 1,
      });
    } else {
      cartRef.update({
        itemKey: FieldValue.delete(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('panier').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null || snapshot.data!.data() == null) {
          return Center(child: Text('Votre Panier est vide.'));
        }

        final cartData = snapshot.data!.data() as Map<String, dynamic>;
        double total = 0;

        List<Widget> cartItems = cartData.entries.map((entry) {
          final item = entry.value as Map<String, dynamic>;

          // Vérifier que les valeurs nécessaires existent et ne sont pas nulles avant de les utiliser
          final double? price = double.tryParse(item['P']?.toString() ?? '');
          final int? quantity = item['quantity'] ?? 0;

          if (price != null && quantity != null) {
            total += price * quantity;
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4,
            child: ListTile(
              leading: Image.network(
                item['URL'] ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
              title: Text(
                '${entry.key} (x${quantity.toString()})',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Taille: ${item['T']} - Prix: ${price != null ? price.toStringAsFixed(2) : 'N/A'} €'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: quantity != null && quantity > 1
                        ? () {
                      _decreaseQuantity(context, userId, entry.key, quantity);
                    }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('panier').doc(userId).update({
                        entry.key: FieldValue.delete(),
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList();

        return Column(
          children: [
            Expanded(
              child: ListView(
                children: cartItems,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$total €',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),

            ),
          ],
        );
      },
    );
  }
}
