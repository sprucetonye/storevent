import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'package:onielsstore/models/product_model.dart';
import 'package:onielsstore/screens/add_product_screen.dart';
import 'package:onielsstore/screens/product_detail_screen.dart';
import 'package:onielsstore/utils/notifications_utils.dart';
import 'package:onielsstore/utils/csv_export.dart';

class ProductListScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final double _minPrice = 0.0;
  final double _maxPrice = 10000.0;
   ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Product>('products');

    // Check for low stock and show notification
    for(var product in box.values){
      if(int.parse(product.quantity) < 5){
        NotificationsManager.showLowStockNotification(product.name);
      }
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Upload inventory", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),),
        
      ),
      body: Padding(padding: 
      EdgeInsets.all(16.0),
      child: Column(
        // Search Bar
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: "Search item by name",
            ),
            onChanged: (value) {
              // This will trigger a rebuild of the list
            },
          ),
          //Text("Total Products: ${box.length}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16,),
          // Price Filter
          Row(
            children: [
              Text("Min Price: \$${_minPrice.toStringAsFixed(2)}"),
              SizedBox(width: 16,),
              Text("Max Price: \\$_maxPrice.toStringsFixed(2)"),
            ],
          ),
          SizedBox(height: 16,),
          ElevatedButton(onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text("Go to Dashboard")),
          SizedBox(height: 16,),
          Expanded(
            child: ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final product = box.getAt(index)!;
                if(_searchController.text.isNotEmpty && !product.name.toLowerCase().contains(_searchController.text.toLowerCase())){
                  return Container(); // Skip this item
                }
                if (double.parse(product.price) < _minPrice || double.parse(product.price) > _maxPrice){
                  return ListTile(
                    leading: Image.file(File(product.imagePath), width: 60, height: 60),
                    title:  Text(product.name),
                    subtitle: Text("Qty: ${product.quantity}, Price: \$${double.parse(product.price).toStringAsFixed(2)}"),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product), ), );
                    },
                  );
                }
                return null;
                // Apply search and price filter
                // return ListTile(
                //   title: Text(product!.name),
                //   subtitle: Text("Quantity: ${product.quantity}"),
                //   trailing: Text("\$${double.parse(product.price).toStringAsFixed(2)}"),
                //   onTap: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
                //   },
                // );
                // return ListTile(
                //   leading: Image.file(File(product.imagePath), width: 60, height: 60,),
                //   title: Text(product.name),
                //   subtitle: Text("Qty: ${product.quantity}, price: \$${double.parse(product.price).toStringAsFixed(2)}"),
                //   onTap: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));});
                //   },
                
          
              
              }
          ),
          ),
        ],
      )
        
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen()),
        
        );
      }, 
      child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        fixedColor: Colors.deepPurple,
        //selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        //selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        //showUnselectedLabels: false,
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
