import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Controllers for the Product Section
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  bool isPopular = false;

  // Controllers for the Big Card Section
  final _bigCardTitleController = TextEditingController();
  final _bigCardDescriptionController = TextEditingController();
  final _bigCardImageUrlController = TextEditingController();
  bool _isVisible = false; // Visibility for "Order Now"
  String? _selectedProductId; // Selected product for "Order Now"
  String _selectedProductName = 'Select Product'; // To display product name

  // Controllers for the Section Management
  final _sectionNameController = TextEditingController();
  List<String> _selectedProductIds = []; // To store selected products for the section

  // Controller for the Category Section
  final _categoryNameController = TextEditingController();
  final _categoryImageUrlController = TextEditingController();

  int _selectedIndex = 0; // To control the sidebar index

  // Holds all products for selection in Big Cards and Sections
  List<Map<String, dynamic>> allProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchAllProducts(); // Fetch products for selecting products in sections and big cards
  }

  // Fetch all products for the "Order Now" selection in Big Cards
  Future<void> _fetchAllProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('products').get();

    List<Map<String, dynamic>> productsList = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
      productsList.add({
        'id': doc.id,
        'name': product['name'],
      });
    }

    setState(() {
      allProducts = productsList;
    });
  }

  // Fetch items (products, big cards, or categories)
  Future<List<Map<String, dynamic>>> _fetchItems(String collection) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // Update Firestore item
  void _updateItem(String collection, String id, Map<String, dynamic> data) {
    FirebaseFirestore.instance.collection(collection).doc(id).update(data);
  }

  // Delete Firestore item
  void _deleteItem(String collection, String id) {
    FirebaseFirestore.instance.collection(collection).doc(id).delete();
  }

  // Add Product to Firestore
  void _addProduct() async {
    FirebaseFirestore.instance.collection('products').add({
      'name': _productNameController.text,
      'price': double.parse(_priceController.text),
      'imageUrl': _imageUrlController.text,
      'category': _categoryController.text,
      'isPopular': isPopular,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully')),
    );

    _productNameController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _categoryController.clear();
    setState(() {
      isPopular = false;
    });
  }

  // Add Big Card to Firestore
  void _addBigCard() async {
    FirebaseFirestore.instance.collection('carousel').add({
      'title': _bigCardTitleController.text,
      'description': _bigCardDescriptionController.text,
      'imageUrl': _bigCardImageUrlController.text,
      'isVisible': _isVisible,
      'productId': _selectedProductId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Big Card added successfully')),
    );

    _bigCardTitleController.clear();
    _bigCardDescriptionController.clear();
    _bigCardImageUrlController.clear();
    setState(() {
      _isVisible = false;
      _selectedProductId = null;
      _selectedProductName = 'Select Product';
    });
  }

  // Add Section to Firestore
  void _addSection() async {
    FirebaseFirestore.instance.collection('sections').add({
      'name': _sectionNameController.text,
      'productIds': _selectedProductIds, // Store selected product IDs
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Section added successfully')),
    );

    _sectionNameController.clear();
    setState(() {
      _selectedProductIds = [];
    });
  }

  // Add Category to Firestore
  void _addCategory() async {
    FirebaseFirestore.instance.collection('categories').add({
      'name': _categoryNameController.text,
      'imageUrl': _categoryImageUrlController.text, // Add image URL for category
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category added successfully')),
    );

    _categoryNameController.clear();
    _categoryImageUrlController.clear();
  }

  // Sidebar Widget with Icons
  Widget _buildSidebar() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Admin Panel', style: TextStyle(fontSize: 24, color: Colors.white)),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          _buildSidebarItem(Icons.shopping_cart, 'Products', 0),
          _buildSidebarItem(Icons.view_carousel, 'Big Cards', 1),
          _buildSidebarItem(Icons.category, 'Categories', 2),
          _buildSidebarItem(Icons.dashboard, 'Sections', 3),
        ],
      ),
    );
  }

  // Sidebar Item Builder
  ListTile _buildSidebarItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close the sidebar
      },
    );
  }

  // Products Form with Display and Edit/Delete Options
  Widget _buildProductsForm() {
    return _buildForm(
      'products',
      _productNameController,
      'Product Name',
      () => _addProduct(),
      _priceController,
      'Price',
      _categoryController,
      'Category',
      _imageUrlController,
      'Image URL',
      isPopular,
      (value) => setState(() => isPopular = value),
    );
  }

  // General Form Builder
  Widget _buildForm(
      String collection,
      TextEditingController nameController,
      String nameLabel,
      Function addFunction,
      TextEditingController? secondaryController,
      String? secondaryLabel,
      TextEditingController? thirdController,
      String? thirdLabel,
      TextEditingController? fourthController,
      String? fourthLabel,
      bool? switchValue,
      Function(bool)? onSwitchChanged) {
    return FutureBuilder(
      future: _fetchItems(collection),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          children: [
            _buildGridView(snapshot.data!, collection),
            const Divider(),
            _buildTextField(nameController, nameLabel),
            if (secondaryController != null && secondaryLabel != null)
              _buildTextField(secondaryController, secondaryLabel, keyboardType: TextInputType.number),
            if (thirdController != null && thirdLabel != null) _buildTextField(thirdController, thirdLabel),
            if (fourthController != null && fourthLabel != null) _buildTextField(fourthController, fourthLabel),
            if (switchValue != null && onSwitchChanged != null)
              SwitchListTile(
                title: const Text('Visible'),
                value: switchValue!,
                onChanged: onSwitchChanged,
              ),
            if (collection == 'carousel')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text('Order Now Product:'),
                  DropdownButton<String>(
                    value: _selectedProductId,
                    hint: Text(_selectedProductName),
                    isExpanded: true,
                    items: allProducts.map((product) {
                      return DropdownMenuItem<String>(
                        value: product['id'],
                        child: Text(product['name']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProductId = newValue;
                        _selectedProductName = allProducts.firstWhere((prod) => prod['id'] == newValue)['name'];
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addFunction(),
              child: Text('Add ${collection[0].toUpperCase()}${collection.substring(1)}'),
            ),
          ],
        );
      },
    );
  }

  // GridView to display items
  Widget _buildGridView(List<Map<String, dynamic>> items, String collection) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _showItemDetails(context, item, collection),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  item['imageUrl'] ?? '',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['name'] ?? '',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // TextField builder
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  // Show details in a dialog with edit and delete options
  void _showItemDetails(BuildContext context, Map<String, dynamic> item, String collection) {
    _productNameController.text = item['name'] ?? '';
    _priceController.text = item['price']?.toString() ?? '';
    _imageUrlController.text = item['imageUrl'] ?? '';
    _categoryController.text = item['category'] ?? '';
    _bigCardTitleController.text = item['title'] ?? '';
    _bigCardDescriptionController.text = item['description'] ?? '';
    _bigCardImageUrlController.text = item['imageUrl'] ?? '';
    _isVisible = item['isVisible'] ?? false;
    _selectedProductId = item['productId'] ?? null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(collection == 'products' ? item['name'] : item['title']),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item['imageUrl'] != null)
                  Image.network(
                    item['imageUrl'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _deleteItem(collection, item['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item deleted')),
                        );
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Delete'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (collection == 'products') {
                          _updateItem(
                            'products',
                            item['id'],
                            {
                              'name': _productNameController.text,
                              'price': double.parse(_priceController.text),
                              'imageUrl': _imageUrlController.text,
                              'category': _categoryController.text,
                            },
                          );
                        } else if (collection == 'categories') {
                          _updateItem(
                            'categories',
                            item['id'],
                            {
                              'name': _categoryNameController.text,
                              'imageUrl': _categoryImageUrlController.text,
                            },
                          );
                        } else {
                          _updateItem(
                            'carousel',
                            item['id'],
                            {
                              'title': _bigCardTitleController.text,
                              'description': _bigCardDescriptionController.text,
                              'imageUrl': _bigCardImageUrlController.text,
                              'isVisible': _isVisible,
                              'productId': _selectedProductId,
                            },
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item updated')),
                        );
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Edit'),
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

  // Big Cards Form with Display and Edit/Delete Options
  Widget _buildBigCardForm() {
    return _buildForm(
      'carousel',
      _bigCardTitleController,
      'Title',
      _addBigCard,
      _bigCardDescriptionController,
      'Description',
      _bigCardImageUrlController,
      'Image URL',
      null,
      null,
      _isVisible,
      (value) => setState(() => _isVisible = value),
    );
  }

  // Categories Form with Display and Edit/Delete Options
  Widget _buildCategoriesForm() {
    return _buildForm(
      'categories',
      _categoryNameController,
      'Category Name',
      _addCategory,
      _categoryImageUrlController,
      'Category Image URL',
      null,
      null,
      null,
      null,
      null,
      null,
    );
  }

  // Section Management Form
  Widget _buildSectionForm() {
    return Column(
      children: [
        FutureBuilder(
          future: _fetchItems('sections'),
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final section = snapshot.data![index];
                return ListTile(
                  title: Text(section['name']),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // Edit section logic here
                  },
                );
              },
            );
          },
        ),
        const Divider(),
        TextField(
          controller: _sectionNameController,
          decoration: const InputDecoration(labelText: 'Section Name'),
        ),
        const Text('Select Products for Section'),
        Wrap(
          children: allProducts.map((product) {
            return FilterChip(
              label: Text(product['name']),
              selected: _selectedProductIds.contains(product['id']),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedProductIds.add(product['id']);
                  } else {
                    _selectedProductIds.remove(product['id']);
                  }
                });
              },
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: _addSection,
          child: const Text('Add Section'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      drawer: _buildSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedIndex == 0
            ? _buildProductsForm()
            : _selectedIndex == 1
                ? _buildBigCardForm()
                : _selectedIndex == 2
                    ? _buildCategoriesForm()
                    : _buildSectionForm(),
      ),
    );
  }
}
