import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';

class CategoryProductsPage extends StatefulWidget {
  final String categoryName;

  const CategoryProductsPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  _CategoryProductsPageState createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  List<Map<String, dynamic>> categoryProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: widget.categoryName)
        .get();

    List<Map<String, dynamic>> productList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
      productList.add(product);
    }

    setState(() {
      categoryProducts = productList;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProducts.isEmpty
              ? const Center(child: Text('No products found in this category.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in grid
                    childAspectRatio: 0.7, // Adjust the height based on your design
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categoryProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(categoryProducts[index]);
                  },
                ),
    );
  }

  // Reuse the same product card design from HomePage
  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        // Navigate to the product detail page
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
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(1, 2),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  product['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    ); // Fallback icon if the image fails to load
                  },
                ),
              ),
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
