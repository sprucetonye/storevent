import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:onielsstore/models/product_model.dart';
import 'package:onielsstore/screens/add_product_screen.dart';
import 'package:onielsstore/screens/product_detail_screen.dart';
import 'package:onielsstore/utils/notifications_utils.dart';

class ProductListScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final double _minPrice = 0.0;
  final double _maxPrice = 10000.0;

  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    // Check for low stock and show notification
    for (var product in box.values) {
      final qty = int.tryParse(product.quantity) ?? 0;
      if (qty < 5) {
        NotificationsManager.showLowStockNotification(product.name);
      }
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Upload inventory",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search item by name",
              ),
              onChanged: (value) {
                // ValueListenableBuilder will rebuild when the box changes;
                // calling setState isn't necessary here because the TextField controller
                // is used in the filtering inside the builder.
              },
            ),
            SizedBox(height: 16),
            // Price Filter
            Row(
              children: [
                Text("Min Price: \$${_minPrice.toStringAsFixed(2)}"),
                SizedBox(width: 16),
                Text("Max Price: \$${_maxPrice.toStringAsFixed(2)}"),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Go to Dashboard"),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<Product> items, _) {
                  final products = items.values.toList().cast<Product>();

                  final filtered = products.where((product) {
                    final matchesSearch = _searchController.text.isEmpty ||
                        product.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase());
                    final price = double.tryParse(product.price) ?? 0.0;
                    final withinPrice = price >= _minPrice && price <= _maxPrice;
                    return matchesSearch && withinPrice;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(child: Text('No products found'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return ListTile(
                        leading: product.imagePath.isNotEmpty
                            ? Image.file(File(product.imagePath), width: 60, height: 60, fit: BoxFit.cover)
                            : Icon(Icons.image_not_supported, size: 40),
                        title: Text(product.name),
                        subtitle: Text(
                            "Qty: ${product.quantity}, Price: \$${(double.tryParse(product.price) ?? 0.0).toStringAsFixed(2)}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProductScreen())
          );
          // The ValueListenableBuilder will automatically update when the box changes
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product saved successfully!'))
            );
          }
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        fixedColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.local_mall_outlined), label: "sale"),
          BottomNavigationBarItem(icon: Icon(Icons.library_add_check_outlined), label: "inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: "purchasing"),
        //  BottomNavigationBarItem(icon: Icon(Icons.library_add_check_outlined), label: "inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "account"),
        ],
      ),
    );
  }
}
