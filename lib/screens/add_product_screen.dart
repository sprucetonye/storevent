import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<void> _pickImage(ImageSource source) async {
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
    } on UnimplementedError {
      // Handle unimplemented error for unsupported platforms
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Not Supported'),
            content: Text('Image picking is not fully supported on this platform (${Platform.operatingSystem}). Please try on a mobile device or use a different method to add images.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Show error dialog if image picking fails
      if (mounted) {
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
        child: SingleChildScrollView(
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
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value){
                if (value == null || value.isEmpty){
                  return "Please enter a quantity";
                }
                final qty = int.tryParse(value);
                if (qty == null) {
                  return "Please enter a valid number for quantity";
                }
                if(qty < 0){
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
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                if(value == null || value.isEmpty){
                  return "Please enter a price";
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return "Please enter a valid number for price";
                }
                if (price < 0){
                  return "Price cannot be negative";
                }
                return null;
              },
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (Platform.isLinux) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Camera not available on Linux')),
                          );
                          return;
                        }
                        await _pickImage(ImageSource.camera);
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _pickImage(ImageSource.gallery);
                      },
                      icon: Icon(Icons.photo_library),
                      label: Text("Gallery"),
                    ),
                  ),
                ],
              ),
        const SizedBox(height: 20.0),
        if (_imagePath != null)
          Container(
            height: 200,
            width: 200,
            child: Image.file(File(_imagePath!), fit: BoxFit.contain),
          ),
        const SizedBox(height: 20.0),
        ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if (_imagePath == null && (widget.existingProduct == null || widget.existingProduct!.imagePath.isEmpty)) {
        // Show error if no image is selected for new product
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add an image for the product')),
        );
        return;
      }
      final product = Product(
        name: _nameController.text,
        quantity: _quantityController.text,
        price: _priceController.text,
          // Use the newly picked image if available, otherwise keep the existing product image
          // or fall back to an empty string to avoid null errors.
          imagePath: _imagePath ?? widget.existingProduct?.imagePath ?? '',
      );
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
      // Form is not valid, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fix the errors in the form')),
      );
    }
  },
  child: Text(widget.existingProduct != null ? "Update Product" : "Save Product"),
),
          ],
        ),
      ),
      ),
      ),
    );
  }
}