import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:onielsstore/models/product_model.dart';
import 'package:path_provider/path_provider.dart';




class CSVExport {
  static Future<void> exportToCSV(BuildContext context) async {
    final box = Hive.box<Product>('products');
    final products = box.values.toList();


    // Create CSV content
    final csvData = <List<String>>[];
    csvData.add(["Name", "Quantity", "Price", "Image Path"]);
    //   ['Product Name', 'Quantity', 'Price'],
    //   ...products.map((product) => [product.name, product.quantity, product.price]),
    // ];
    // final csvString = const ListToCsvConverter().convert(csvData);
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/products.csv');
    // await file.writeAsString(csvString);

    for(var product in products){
      csvData.add([
        product.name,
        product.quantity.toString(),
        product.price.toString(),
        product.imagePath
      ]);

    }
    final csv = const ListToCsvConverter().convert(csvData);
    // Save SCV file to device
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "$directory/inventory.csv";
    final file = File(filePath);
    await file.writeAsString(csv);

    // Show a message to the user

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Inventory exported to $filePath")),);
  }
}
