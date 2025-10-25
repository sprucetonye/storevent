import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:onielsstore/models/product_model.dart';
import 'package:onielsstore/screens/add_product_screen.dart';



class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),

      ),
      body: Padding(padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(File(product.imagePath)),
          SizedBox(height: 16,),
          Text("Name: ${product.name}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Quantity: ${product.quantity}", style: TextStyle(fontSize: 16,)),
          Text("Price: \$${double.parse(product.price).toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
        ],
      ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: (){
              // TODO Implement edit functionality
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddProductScreen(
                // Pass the existing product to the AddProductScreen for editing
                existingProduct: product,
              ),),
              
              );
              
            },
            child: Icon(Icons.edit),
          ),
          SizedBox(width: 16,),
          FloatingActionButton(onPressed: () async {
            final box = Hive.box<Product>('products');
            final index = box.values.toList().indexOf(product);
            if (index != -1) {
              await box.deleteAt(index);
            }
            Navigator.pop(context);
            // TODO: Implement delete functionality
          },
          child: Icon(Icons.delete),
          )
        ],
      ),
    );
  }
}