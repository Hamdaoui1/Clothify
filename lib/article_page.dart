// article_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vitrine/shopping_page.dart';

class ArticlePage extends StatelessWidget {
  final String title;
  final String category;
  final String size;
  final String brand;
  final String price;
  final String imageUrl;

  const ArticlePage({
    Key? key,
    required this.title,
    required this.category,
    required this.size,
    required this.brand,
    required this.price,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Text(
              'Marque: $brand',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Catégorie: $category',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Taille: $size',
              style: TextStyle(fontSize: 16.0),
            ),
            Text(
              'Prix: $price €',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Ajouter au panier'),
            ),
          ],
        ),
      ),
    );
  }
}


class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String userId;

  const ArticleDetailPage({Key? key, required this.itemData, required this.userId}) : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItemQuantity();
  }

  Future<void> _loadCartItemQuantity() async {
    final cartDoc = await FirebaseFirestore.instance.collection('panier').doc(widget.userId).get();
    //print(cartDoc.id);
    if (cartDoc.exists) {
      final cartData = cartDoc.data() as Map<String, dynamic>;
      if (cartData.containsKey(widget.itemData['TT'])) {
        setState(() {
          quantity = cartData[widget.itemData['TT']]['quantity'] ?? 0;
        });
      }
    }
  }

  void _updateCartQuantity(BuildContext context, int change) async {
    final cartRef = FirebaseFirestore.instance.collection('panier').doc(widget.userId);
    final cartSnapshot = await cartRef.get();

    if (cartSnapshot.exists) {
      final cartData = cartSnapshot.data() as Map<String, dynamic>;
      if (cartData.containsKey(widget.itemData['TT'])) {
        final currentQuantity = cartData[widget.itemData['TT']]['quantity'] ?? 0;
        final newQuantity = currentQuantity + change;

        if (newQuantity > 0) {
          await cartRef.update({'${widget.itemData['TT']}.quantity': newQuantity});
        } else {
          await cartRef.update({widget.itemData['TT']: FieldValue.delete()});
        }
      } else {
        if (change > 0) {
          // Ajouter un nouvel article s'il n'existe pas encore dans le panier
          await cartRef.update({
            widget.itemData['TT']: {
              'id': cartSnapshot.id,
              'M': widget.itemData['M'],
              'P': widget.itemData['P'],
              'T': widget.itemData['T'],
              'URL': widget.itemData['URL'],
              'quantity': 1,
            },
          });
        }
      }
    } else {
      // Créer un nouveau document de panier avec le premier article
      await cartRef.set({
        widget.itemData['TT']: {
          'id': cartSnapshot.id,
          'M': widget.itemData['M'],
          'P': widget.itemData['P'],
          'T': widget.itemData['T'],
          'URL': widget.itemData['URL'],
          'quantity': 1,
        },
      });
    }

    setState(() {
      quantity = (quantity + change).clamp(0, double.infinity).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.itemData['M'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: AspectRatio(
                  aspectRatio: 1, // Assure que l'image est carrée
                  child: Image.network(
                    widget.itemData['URL'],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              widget.itemData['TT'],
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Marque:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.itemData['M'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Taille:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.itemData['T'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catégorie:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.itemData['C'],
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prix:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.itemData['P']} €',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (quantity > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () => _updateCartQuantity(context, -1),
                  ),
                  Text(
                    'Quantité: $quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: () => _updateCartQuantity(context, 1),
                  ),
                ],
              )
            else
              Center(
                child: ElevatedButton(
                  onPressed: () => _updateCartQuantity(context, 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Ajouter au panier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
