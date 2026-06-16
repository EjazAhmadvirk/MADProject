import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final bool inCart = cartProvider.isInCart(book);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          book['title'],
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Image
            SizedBox(
              height: 250,
              width: double.infinity,
              child: book['imageurl'] != null &&
                  book['imageurl'].toString().isNotEmpty
                  ? Image.network(
                book['imageurl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.brown.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.brown),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      color: Colors.brown.shade100,
                      child: const Icon(Icons.book,
                          size: 120, color: Colors.brown),
                    ),
              )
                  : Container(
                color: Colors.brown.shade100,
                child: const Icon(Icons.book,
                    size: 120, color: Colors.brown),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author
                  Text(
                    'By ${book['authore'] ?? ''}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    'Rs. ${book['price']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book['description'] ??
                        'This is a great book that covers all the important topics in detail. A must read for every student and professional.',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        inCart ? Colors.grey : Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        inCart ? Icons.check : Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      label: Text(
                        inCart ? 'Added to Cart' : 'Add to Cart',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          Navigator.pushNamed(context, '/login');
                        } else {
                          if (!inCart) {
                            cartProvider.addToCart(book);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added to cart!'),
                                backgroundColor: Colors.brown,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}