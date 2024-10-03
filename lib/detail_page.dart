import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_screen.dart'; // Import your CartScreen

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> popularProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchPopularProducts(); // Fetch popular products when the page initializes
  }

  // Function to fetch popular products from Firestore
  Future<void> _fetchPopularProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').where('isPopular', isEqualTo: true).get();

    List<Map<String, dynamic>> popularList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
      popularList.add(product);
    }

    setState(() {
      popularProducts = popularList;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Getting the passed product data from navigation arguments
    final Map<String, dynamic> product =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      body: Column(
        children: [
          // Product image filling the top area
          Container(
            color: Colors.red.shade200, // Background color for the image
            child: Image.network(
              product['imageUrl'] ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.45, // Adjust height as needed
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 50);
              },
            ),
          ),
          // Product details below the image
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ), // Optional radius for the container
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView(
                // Scrollable section for content
                children: [
                  Text(
                    product['name'] ?? 'Product Name', // Ensure name is shown
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "\₪${product['price']?.toString() ?? '0'}", // Ensure price is shown
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product['description'] ?? 'No Description Available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _addToCart(product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Corrected backgroundColor
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPopularProductsSection(), // Show popular products below "Add to Cart"
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the popular products section
  Widget _buildPopularProductsSection() {
    if (popularProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Products',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150, // Adjust the height of the product list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularProducts.length,
            itemBuilder: (context, index) {
              return _buildPopularProductCard(popularProducts[index]);
            },
          ),
        ),
      ],
    );
  }

  // Widget to build each popular product card
  Widget _buildPopularProductCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailPage(),
              settings: RouteSettings(
                arguments: product,
              ),
            ),
          );
        },
        child: Container(
          width: 120, // Adjust the width of the product card
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  product['imageUrl'] ?? '',
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 50);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  product['name'] ?? 'Product Name',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "\₪${product['price']?.toString() ?? '0'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to add the product to the cart
  void _addToCart(Map<String, dynamic> product) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Check if the item is already in the cart
      QuerySnapshot existingCartItem = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: user.uid)
          .where('name', isEqualTo: product['name'])
          .get();

      if (existingCartItem.docs.isNotEmpty) {
        // Item already exists, update the quantity
        DocumentSnapshot cartItemDoc = existingCartItem.docs.first;
        int currentQuantity = cartItemDoc['quantity'] ?? 1;
        FirebaseFirestore.instance
            .collection('cart')
            .doc(cartItemDoc.id)
            .update({'quantity': currentQuantity + 1});
      } else {
        // Item does not exist, add a new entry
        await FirebaseFirestore.instance.collection('cart').add({
          'userId': user.uid,
          'name': product['name'],
          'price': product['price'],
          'imageUrl': product['imageUrl'],
          'quantity': 1,
        });
      }

      // Show confirmation dialog with options
      _showAddToCartDialog();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to log in to add items to the cart.')),
        );
      }
    }
  }

  // Function to show a dialog for confirmation
  void _showAddToCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // Adjust width
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 60,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Added Successfully!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Go to Cart',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
