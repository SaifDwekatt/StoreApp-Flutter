import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: const Center(
          child: Text('You need to log in to view your cart.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: StreamBuilder(
              // Query the cart collection for the current user's items
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: user.uid) // Filter by user ID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else if (snapshot.hasData) {
                  QuerySnapshot<Map<String, dynamic>>? cartItems = snapshot.data;
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> allCartItems = cartItems!.docs;

                  if (allCartItems.isNotEmpty) {
                    num sum = 0;
                    for (var item in allCartItems) {
                      sum += (item['price'] ?? 0) * (item['quantity'] ?? 1);
                    }

                    return Column(
                      children: [
                        Expanded(
                          flex: 6,
                          child: ListView.builder(
                            itemCount: allCartItems.length,
                            padding: const EdgeInsets.all(20),
                            itemBuilder: (context, i) {
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to product details page
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        offset: const Offset(1, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.white,
                                  ),
                                  height: 140,
                                  child: Row(
                                    children: [
                                      // Image Container
                                      Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.network(
                                            allCartItems[i]['imageUrl'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Product Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              allCartItems[i]['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '\₪${allCartItems[i]['price']}',
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                // Decrease quantity button
                                                IconButton(
                                                  color: Colors.grey,
                                                  onPressed: () {
                                                    _decrementQuantity(
                                                        allCartItems[i].id,
                                                        allCartItems[i]['quantity'] ?? 1);
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 18, // Smaller size
                                                  ),
                                                ),
                                                // Quantity display
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Colors.grey.shade400,
                                                  ),
                                                  child: Text(
                                                    '${allCartItems[i]['quantity'] ?? 1}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                // Increase quantity button
                                                IconButton(
                                                  color: Colors.grey,
                                                  onPressed: () {
                                                    _incrementQuantity(
                                                        allCartItems[i].id,
                                                        allCartItems[i]['quantity'] ?? 1);
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 18, // Smaller size
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Delete Button
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(10),
                                              backgroundColor: Colors.red.shade500,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('cart')
                                                  .doc(allCartItems[i].id)
                                                  .delete();
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Total Amount above "Place Order" button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Total Amount: \₪${sum.toInt()}',
                              style: const TextStyle(
                                letterSpacing: 1,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: Icon(
                        Icons.add_shopping_cart,
                        size: 200,
                        color: Colors.grey.shade300,
                      ),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              },
            ),
          ),
          // Place Order button at the bottom
          SizedBox(
            width: double.infinity,
            height: 60, // Fixed height for the button
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              onPressed: () {
                // Handle place order logic here
              },
              child: const Text(
                'Place Order',
                style: TextStyle(
                  
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to handle incrementing the quantity
  void _incrementQuantity(String docId, int currentQuantity) {
    FirebaseFirestore.instance.collection('cart').doc(docId).update({
      'quantity': currentQuantity + 1,
    });
  }

  // Function to handle decrementing the quantity
  void _decrementQuantity(String docId, int currentQuantity) {
    if (currentQuantity > 1) {
      FirebaseFirestore.instance.collection('cart').doc(docId).update({
        'quantity': currentQuantity - 1,
      });
    }
  }
}
