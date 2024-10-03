import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_page.dart'; // Import the DetailPage
import 'cart_screen.dart'; // Import the CartScreen
import 'category_products_page.dart'; // Import the CategoryProductsPage
import 'section_products_page.dart'; // Import the SectionProductsPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isDarkMode = false;
  List<Map<String, dynamic>> popularProducts = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> bigCards = [];
  List<Map<String, dynamic>> sections = []; // List to store sections

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchCategories();
    _fetchBigCards();
    _fetchSections(); // Fetch sections added by the admin
  }

  Future<void> _fetchProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    List<Map<String, dynamic>> productList = [];
    List<Map<String, dynamic>> popularList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
      productList.add(product);
      if (product['isPopular'] == true) {
        popularList.add(product);
      }
    }

    setState(() {
      products = productList;
      popularProducts = popularList;
    });
  }

  Future<void> _fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();

    List<Map<String, dynamic>> categoryList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> category = doc.data() as Map<String, dynamic>;
      categoryList.add(category);
    }

    setState(() {
      categories = categoryList;
    });
  }

  Future<void> _fetchBigCards() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('carousel').get();

    List<Map<String, dynamic>> bigCardList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> bigCard = doc.data() as Map<String, dynamic>;
      bigCardList.add(bigCard);
    }

    setState(() {
      bigCards = bigCardList;
    });
  }

  // Fetch sections from Firestore
  Future<void> _fetchSections() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('sections').get();

    List<Map<String, dynamic>> sectionList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> section = doc.data() as Map<String, dynamic>;
      List<String> productIds = List<String>.from(section['productIds']);
      sectionList.add({
        'name': section['name'],
        'productIds': productIds,
      });
    }

    setState(() {
      sections = sectionList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212) // A deeper dark background color
          : Colors.grey.shade200,
      appBar: AppBar(
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 33,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.amber
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.shopping_cart,
                    size: 18,
                    color: isDarkMode ? Colors.black : Colors.red,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 33,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.amber
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  icon: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.sunny,
                    size: 18,
                    color: isDarkMode ? Colors.black : Colors.yellow.shade600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        title: Text(
          'Store',
          style: TextStyle(
            color: isDarkMode ? Colors.amber : const Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.w700,
            fontSize: 30,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            // Big Cards section (Carousel)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: bigCards.length,
                itemBuilder: (context, index) {
                  return _buildCarouselItem(
                    bigCards[index],
                  );
                },
              ),
            ),
            // Categories section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 19.0, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryButton(categories[index]);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 35.0, right: 30, top: 20),
              child: Row(
                children: [
                  Text(
                    'Popular Now',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'View All ▶️',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Popular products section
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: popularProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(
                    popularProducts[index],
                  );
                },
              ),
            ),
            // Dynamically generated sections from Firestore
            ...sections.map((section) {
              return _buildSection(section);
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
        future: _getCurrentUserRole(),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading indicator
          }

          if (snapshot.hasData && snapshot.data == 'admin') {
            return FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
              backgroundColor: isDarkMode ? Colors.amber : Colors.red,
              child: const Icon(Icons.admin_panel_settings),
            );
          }

          return Container(); // Return empty container if not admin
        },
      ),
    );
  }

  // Helper to retrieve the current user's role from Firestore
  Future<String?> _getCurrentUserRole() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return snapshot['role']; // Assuming role is stored in 'role' field
    }
    return null;
  }

  // Build section dynamically from Firestore
  Widget _buildSection(Map<String, dynamic> section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 35.0, right: 30, top: 20),
          child: Row(
            children: [
              Text(
                section['name'],
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Navigate to SectionProductsPage when "View All" is clicked
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionProductsPage(
                        sectionName: section['name'],
                        productIds: section['productIds'],
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View All ▶️',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: section['productIds'].length,
            itemBuilder: (context, index) {
              String productId = section['productIds'][index];
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData) {
                    return const Text('Error loading product');
                  }

                  Map<String, dynamic> product =
                      snapshot.data!.data() as Map<String, dynamic>;

                  return _buildProductCard(product); // Your product card builder
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Big card builder (Image as background and title/description on top)
  Widget _buildCarouselItem(Map<String, dynamic> bigCard) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
              blurRadius: 14,
            ),
          ],
          borderRadius: BorderRadius.circular(40),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  bigCard['imageUrl'],
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.3), // Darken the image for readability
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 50,
                    );
                  },
                ),
              ),
              // Text content on top of the image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bigCard['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white, // Text color for readability
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      bigCard['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70, // Text color for readability
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (bigCard['isVisible'] == true) // Check if button should be visible
                      ElevatedButton(
                        onPressed: () {
                          if (bigCard['productId'] != null) {
                            _navigateToProduct(bigCard['productId']);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800, // Button color
                        ),
                        child: const Text(
                          'Order Now',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white, // Button text color
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProduct(String productId) async {
    // Fetch the product from Firestore using productId
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (productSnapshot.exists) {
      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;

      // Navigate to the DetailPage with the fetched product data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DetailPage(),
          settings: RouteSettings(
            arguments: productData, // Pass the product data to DetailPage
          ),
        ),
      );
    }
  }

  // Circular Category button builder
  Widget _buildCategoryButton(Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsPage(
                categoryName: category['name'],
              ),
            ),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(category['imageUrl'] ?? ''),
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                // Handle image error by showing a default image or icon
              },
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: const Offset(0, 3), // Shadow position
              ),
            ],
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Product card builder (Navigate to DetailPage on tap)
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          height: 250,
          width: 180,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                offset: const Offset(1, 2),
                blurRadius: 20,
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return const Icon(
                        Icons.error,
                        color: Color.fromARGB(255, 232, 188, 13),
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Text(
                        product['name'],
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\₪${product['price']}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
