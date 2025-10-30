import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
//import 'package:onielsstore/models/product_list_screen.dart';
import 'package:onielsstore/models/product_model.dart';
import 'package:path_provider/path_provider.dart';



class AddProductScreen extends StatefulWidget {
  final Product? existingProduct;
  
  const AddProductScreen({super.key, this.existingProduct});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _priceController = TextEditingController();
    String? _imagePath;
  @override

   void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _nameController.text = widget.existingProduct!.name;
      _quantityController.text = widget.existingProduct!.quantity.toString();
      _priceController.text = widget.existingProduct!.price.toString();
      _imagePath = widget.existingProduct!.imagePath;
    }
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingProduct != null ? "Edit Product" : "Add Product"),
      ),
      body: Padding(padding: 
      EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name'
              ),
              validator: (value) {
                if (value == null || value.isEmpty){
                  return "Please enter a product name";
                }
                return null;
              },
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity"
              ),
              keyboardType: TextInputType.number,
              validator: (value){
                if (value == null || value.isEmpty){
                  return "Please enter a quantity";
                }
                if(int.parse(value) < 0){
                  return "Quantity cannot be negative";
                }
                return null;
              },
        
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price"
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if(value == null || value.isEmpty){
        return "Please enter a price";
                }
                if (double.parse(value)< 0){
                  return "Price cannot be";
                }
                return null;
              },
              ),
              SizedBox(height: 20,),
             ElevatedButton.icon(
          onPressed: () async {
            final ImageSource? source = await showDialog<ImageSource>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Select Image Source'),
                actions: <Widget>[
                  if (!Platform.isLinux) // Camera option not available on Linux
                    TextButton(
                      child: const Text('Camera'),
                      onPressed: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  TextButton(
                    child: const Text('Gallery'),
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            );
            
            if (source != null) {
              try {
                final pickedFile = await ImagePicker().pickImage(
                  source: source,
                  imageQuality: 70,
                );
                
                if (pickedFile != null) {
                  File imageFile = File(pickedFile.path);
                  Uint8List? compressedData;
                  
                  if (Platform.isLinux) {
                    // On Linux, read the file and compress the bytes directly
                    final bytes = await imageFile.readAsBytes();
                    compressedData = await FlutterImageCompress.compressWithList(
                      bytes,
                      quality: 70,
                      minWidth: 800,
                      minHeight: 800,
                    );
                  } else {
                    // On other platforms, use compressWithFile
                    compressedData = await FlutterImageCompress.compressWithFile(
                      pickedFile.path,
                      quality: 70,
                      minWidth: 800,
                      minHeight: 800,
                    );
                  }
                  
                  if (compressedData != null) {
                    final directory = await getApplicationDocumentsDirectory();
                    final imagePath = "${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
                    final file = File(imagePath);
                    await file.writeAsBytes(compressedData);
                    setState(() {
                      _imagePath = imagePath;
                    });
                  }
                }
              } catch (e) {
                // Show error dialog if image picking fails
                showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text('Failed to pick image: $e'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          icon: Icon(Icons.add_photo_alternate),
          label: Text("Add Image"),
        ),
        SizedBox(height: 20,),
        if(_imagePath != null)
        Image.file(File(_imagePath!)),
        SizedBox(height: 20),
        ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      print('Form is valid');
      final product = Product(
        name: _nameController.text,
        quantity: _quantityController.text,
        price: _priceController.text,
          // Use the newly picked image if available, otherwise keep the existing product image
          // or fall back to an empty string to avoid null errors.
          imagePath: _imagePath ?? widget.existingProduct?.imagePath ?? '',
      );
      print('Product: $product');
      final box = Hive.box<Product>('products');
      if (widget.existingProduct != null) {
        // Update the existing product
        box.putAt(box.values.toList().indexOf(widget.existingProduct!), product);
      } else {
        box.add(product);
      }
      // Pop with true to indicate successful save
      Navigator.pop(context, true);
    } else {
      print('Form is not valid');
    }
  },
  child: Text(widget.existingProduct != null ? "Update Product" : "Save Product"),
),
          ],
        ),
      ),
      ),
    );
  }
}