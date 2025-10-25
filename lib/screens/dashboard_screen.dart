import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:onielsstore/models/product_model.dart';
import 'package:onielsstore/screens/product_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');
    // Calculate total products and total value
    int totalProducts = box.length;
    double totalValue = 0.0;
    for (var product in box.values) {
      final price = double.tryParse(product.price.toString()) ?? 0.0;
      final qty = product.quantity is int ? product.quantity as int : int.tryParse(product.quantity.toString()) ?? 0;
      totalValue += price * qty;
    }

    final lowStockProducts = box.values.where((p) {
      final qty = p.quantity is int ? p.quantity as int : int.tryParse(p.quantity.toString()) ?? 0;
      return qty < 10;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        title: Text("Welcome to StoreVent", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Products: $totalProducts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Total Inventory Value: \$${totalValue.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              if (lowStockProducts.isNotEmpty) ...[
                Text(
                  "Low stock products:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: lowStockProducts.length,
                  itemBuilder: (context, index) {
                    final product = lowStockProducts[index];
                    final priceStr = (product.price is double)
                        ? (product.price as double).toStringAsFixed(2)
                        : (double.tryParse(product.price.toString())?.toStringAsFixed(2) ??
                            product.price.toString());
                    final qty = product.quantity;
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text("Quantity: $qty, Price: \$$priceStr"),
                    );
                  },
                ),
                SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen()));
                },
                child: Text("Go to Product List"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}